# # First steps

#md # [![](https://img.shields.io/badge/show-nbviewer-579ACA.svg)](@__NBVIEWER_ROOT_URL__/tutorials/First steps.ipynb)

# This tutorial demonstrates the basic usage of *Spindles.jl* to create spindles 
# and query basic properties.

#md # !!! note
#md #     This tutorial is also available as a Jupyter notebook. 
#md #     Click on the badge above to view it in [nbviewer](https://nbviewer.jupyter.org/).

#src ==========================
# ## Creating a spindle

# Recall that the special property of a spindle is the existence of two vertices 
# (the apices) whose incident facets partition the set of all facets. In this tutorial, 
# we will be working with one of the simplest examples of a spindle: a cube. 
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

# *Spindles.jl* provides a data type for representing and analyzing spindles: 
# [`Spindle`](@ref). We may create an object of this type from our data `A` and `b` as follows:

using Spindles # hide
cube = Spindle(A, b)

# The [`Spindle`](@ref) constructor already computes two apices. They may be inspected by running
apices(cube)

# This returns the two indices of the apices as they appear in the list of all (eight) vertices 
# of `cube`. We may list the vertices explicitly as follows:
vertices(cube)

# !!! note
#     By default, *Spindles.jl* uses exact rational arithmetic. Note that the components of each 
#     vertex returned by [`vertices`](@ref Spindles.vertices) are of type `Rational` with numerators 
#     and denominators of type `BigInt` to avoid integer overflows (see the Julia documentation pages on
#     [rational numbers](https://docs.julialang.org/en/v1/manual/complex-and-rational-numbers/#Rational-Numbers) and
#     [arbitrary-precision arithmetic](https://docs.julialang.org/en/v1/manual/integers-and-floating-point-numbers/#Arbitrary-Precision-Arithmetic)).

# So the first and last vertex in the list above can take the role of the apices `cube`.
# However, these two are not unique. In fact, for a cube there are many possible pairs of apices: 
# Take an arbitrary vertex and its antipodal one, i.e., the vertex obtained by flipping the sign 
# of each component. If we want to prescribe an apex, we can use the function [`setapex!`](@ref) 
# that takes as input the index of a vertex of our choice and tries to find a matching second one
# for a pair of apices:
setapex!(cube, 3)

# !!! warning
#     [`setapex!`](@ref) overwrites the previously computed apices. 

# Calling the function [`apices`](@ref) again now returns
apices(cube)

#src ==========================
# ## Working with the graph

# We may even compute the distance between those two apices in the graph of `cube`:
dist(cube, apices(cube)...)

# !!! note
#     Calling [`dist`](@ref) always refers to the current apices as returned by [`apices`](@ref). 
#     For example, the above call computes the distance between `3` and `6` (and not between `1` and `8`).

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

# Given that the two-dimensional faces of `cube` are precisely the six facets, 
# this should not be too surprising. 

# !!! tip
#     To count the faces of a given dimension without explicitly producing a list, 
#     use the function [`nfacesofdim`](@ref).

# Let us list all vertices contained in the first facet.

for v in incidentvertices(cube, [1])
    println(collect(vertices(cube))[v])
end

# As expected, we obtain precisely the four vertices whose first component is equal to one.

# !!! note
#     [`vertices`](@ref Spindles.vertices) returns an iterator. To access a specific element, 
#     use [`collect`](https://docs.julialang.org/en/v1/base/collections/#Base.collect-Tuple{Any}) 
#     as in the code above.