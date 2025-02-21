# # First steps

#md # [![](https://img.shields.io/badge/show-nbviewer-579ACA.svg)](@__NBVIEWER_ROOT_URL__/tutorials/First steps.ipynb)

# This tutorial demonstrates the basic usage of *Spindles.jl* to create spindles 
# and query basic properties.

#md # !!! note
#md #     This tutorial is also available as a Jupyter notebook. 
#md #     Click on the badge above to view it in [nbviewer](https://nbviewer.jupyter.org/).

#src ==========================
# ## Creating a spindle

# In this tutorial, we will be working with one of the simplest examples of a spindle: a cube. 
# For example, the unit cube in 3D is given by all points $(x_1,x_2,x_3)$ that satisfy 
# ```math
# \begin{aligned}
# -1 \le x_1 &\le 1 \\
# -1 \le x_2 &\le 1 \\
# -1 \le x_3 &\le 1
# \end{aligned}
# ```

# In matrix notation, this is equivalent to the system $Ax \le b$ where
A = [1 0 0; -1 0 0; 0 1 0; 0 -1 0; 0 0 1; 0 0 -1]
# and
b = [1, 1, 1, 1, 1, 1]

# *Spindles.jl* provides a data type for representing and analyzing polytopes: 
# [`Polytope`](@ref). We may create an object of this type from our data `A` and `b` as follows:

using Spindles # hide
cube = Polytope(A, b)

# What sets a spindle apart from a general polytope is the existence of two vertices 
# (the apices) whose incident facets partition the set of all facets. 
# We may check `cube` for the existence of such a pair of vertices by running
apices(cube)

# This returns the two indices of the apices as they appear in the list of all (eight) vertices 
# of `cube`. To list the vertices explicitly, do
vertices(cube)

# !!! note
#     By default, *Spindles.jl* uses exact rational arithmetic. Note that the components of each 
#     vertex returned by [`vertices`](@ref Spindles.vertices) are of type `Rational` with numerators 
#     and denominators of type `BigInt` to avoid integer overflows (see the Julia documentation pages on
#     [rational numbers](https://docs.julialang.org/en/v1/manual/complex-and-rational-numbers/#Rational-Numbers) and
#     [arbitrary-precision arithmetic](https://docs.julialang.org/en/v1/manual/integers-and-floating-point-numbers/#Arbitrary-Precision-Arithmetic)).

# So the first and last vertex in the list above can take the role of the apices of `cube`.
# However, these two are not unique. In fact, for a cube there are many possible pairs of apices: 
# Take an arbitrary vertex and its antipodal one, i.e., the vertex obtained by flipping the sign 
# of each component. To prescribe an apex, pass its index as an additional argument
# to the function [`apices`](@ref), which then tries to find a matching second apex:
apx = apices(cube, 3)


#src ==========================
# ## Working with the graph

# We may even compute the distance between those two apices in the graph of `cube`:
dist(cube, apx...)

# Behind the scenes, the call to [`dist`](@ref) first computes the graph of `cube`. 
# The graph can also be accessed directly using [`graph`](@ref), which returns a graph 
# of a type defined by the [*Graphs.jl*](https://juliagraphs.org/Graphs.jl/) package. 
# For instance, we may verify the well-known fact that cubes are simple by using the 
# functions [`dim`](@ref Spindles.dim) and [`Graphs.degree`](https://juliagraphs.org/Graphs.jl/stable/core_functions/core/#Graphs.degree):
using Graphs: degree
all(degree(graph(cube)) .== dim(cube))

#src ==========================
# ## Counting and enumerating faces

# *Spindles.jl* also provides functions to count and enumerate the faces of `cube`. The following call to 
# [`facesofdim`](@ref) returns a list of all two-dimensional faces, each one given by the indices of its 
# incident facets.

# !!! note
#     Note here that facet indices refer to the corresponding rows of the coefficient matrix `A`. 

facesofdim(cube, 2)

# Given that the two-dimensional faces of a cube are precisely its six facets, 
# this should not be too surprising. 

# To count the faces of a given dimension without explicitly producing a list, 
# use the function [`nfacesofdim`](@ref). For example, we may compute
# the [f-vector](https://en.wikipedia.org/wiki/Polyhedral_combinatorics#Faces_and_face-counting_vectors) 
# of `cube` as follows.
nfacesofdim.(cube, 0:(dim(cube)-1))

# This tells us that `cube` has 8 vertices, 12 edges, and 6 facets.

# Next, let's list all vertices that are incident to the first facet.

for v in incidentvertices(cube, [1])
    println(collect(vertices(cube))[v])
end

# As expected, we obtain precisely the four vertices whose first component is equal to one.

# !!! note
#     [`vertices`](@ref Spindles.vertices) returns an iterator. To access a specific element, 
#     use [`collect`](https://docs.julialang.org/en/v1/base/collections/#Base.collect-Tuple{Any}) 
#     as in the code above.