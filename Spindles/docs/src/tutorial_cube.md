# A simple spindle

This tutorial demonstrates the basic usage of *Spindles.jl* to create spindles and query basic properties.

```@meta
DocTestSetup = quote
    #push!(LOAD_PATH, "../../src")  # no effect?
    #using Spindles
end
```
## What is a spindle?
A **spindle** is a polytope that has two distinguished vertices such that each facet is incident to exactly one of them. These two vertices are called the **apices** of the spindle.

## Creating a spindle
A simple example of a spindle is a cube. For example, take the unit cube in 3D. It is given by all points $x$ in 3D that satisfy $Ax \le b$, where
```@example
A = [1 0 0; 0 1 0; 0 0 1; -1 0 0; 0 -1 0; 0 0 -1]
```
and
```@example
b = [1, 1, 1, 1, 1, 1]
```

*Spindles.jl* provides a data type for representing and analyzing spindles: [`Spindles.Spindle`](@ref). We can create an object of this type from our data `A` and `b` as follows:
```@example
push!(LOAD_PATH, "../../src") # hide
using Spindles # hide
A = [1 0 0; 0 1 0; 0 0 1; -1 0 0; 0 -1 0; 0 0 -1] # hide
b = [1, 1, 1, 1, 1, 1] # hide
cube = Spindle(A, b)
```

Even though `cube` is of type [`Spindles.Spindle`](@ref), this does not mean that it is indeed a spindle in the mathematical sense. For this, it must have two apices. To see whether it does, let us first list all (eight) vertices of `cube`.

```@example
push!(LOAD_PATH, "../../src") # hide
using Spindles # hide
A = [1 0 0; 0 1 0; 0 0 1; -1 0 0; 0 -1 0; 0 0 -1] # hide
b = [1, 1, 1, 1, 1, 1] # hide
cube = Spindle(A, b) # hide
vertices(cube)
```

The existence of two apices may be checked using the function [`Spindles.apices`](@ref), which returns the indices of two vertices of `cube` that act as apices:

```@example
push!(LOAD_PATH, "../../src") # hide
using Spindles # hide
A = [1 0 0; 0 1 0; 0 0 1; -1 0 0; 0 -1 0; 0 0 -1] # hide
b = [1, 1, 1, 1, 1, 1] # hide
cube = Spindle(A, b) # hide
apices(cube)
```

So the first and last vertex in the list above can take the role of apices. However, these two are not unique. In fact, for a cube there are many possible pairs of apices: take an arbitrary vertex and its antipodal one, i.e., the vertex obtained by flipping the sign of each component. If we want to prescribe an apex, we can tell [`Spindles.apices`](@ref) to use a given vertex as the first apex and try to find a matching second one:

```@example
push!(LOAD_PATH, "../../src") # hide
using Spindles # hide
A = [1 0 0; 0 1 0; 0 0 1; -1 0 0; 0 -1 0; 0 0 -1] # hide
b = [1, 1, 1, 1, 1, 1] # hide
cube = Spindle(A, b) # hide
apices(cube, 3)
```

## Working with the graph
We may even compute the distance between those two apices in the graph of `cube`:

```@example
push!(LOAD_PATH, "../../src") # hide
using Spindles # hide
A = [1 0 0; 0 1 0; 0 0 1; -1 0 0; 0 -1 0; 0 0 -1] # hide
b = [1, 1, 1, 1, 1, 1] # hide
cube = Spindle(A, b) # hide
dist_toapex(cube, apices(cube)...)
```

Behind the scenes, the call to [`Spindles.dist_toapex`](@ref) first computes the graph of `cube`. The graph can also be accessed directly using [`Spindles.graph`](@ref), which returns a graph of a type defined by the [*Graphs.jl*](https://juliagraphs.org/Graphs.jl/) package. 
For instance, we may verify the well-known fact that cubes are simple by using the function [`Graphs.degree`](https://juliagraphs.org/Graphs.jl/stable/core_functions/core/#Graphs.degree):

```@example
push!(LOAD_PATH, "../../src") # hide
using Spindles # hide
A = [1 0 0; 0 1 0; 0 0 1; -1 0 0; 0 -1 0; 0 0 -1] # hide
b = [1, 1, 1, 1, 1, 1] # hide
cube = Spindle(A, b) # hide
using Graphs: degree
all(degree(graph(cube)) .== 3)
```

## Counting and enumerating faces
*Spindles.jl* also provides functions to count and enumerate the faces of `cube`. The following call to [`Spindles.facesofdim`](@ref) returns a list of all two-dimensional faces, each one given by the indices of its incident facets.

!!! note

    Facet indices refer to the corresponding rows of the coefficient matrix `A`. 

```@example
push!(LOAD_PATH, "../../src") # hide
using Spindles # hide
A = [1 0 0; 0 1 0; 0 0 1; -1 0 0; 0 -1 0; 0 0 -1] # hide
b = [1, 1, 1, 1, 1, 1] # hide
cube = Spindle(A, b) # hide
facesofdim(cube, 2)
```

Given that the two-dimensional faces of `cube` are precisely the six facets, this should not be too surprising. 

!!! tip

    To count the faces of a given dimension without explicitly producing a list, use the function [`Spindles.nfacesofdim`](@ref).

Let us list all vertices contained in the first facet.

```@example
push!(LOAD_PATH, "../../src") # hide
using Spindles # hide
A = [1 0 0; 0 1 0; 0 0 1; -1 0 0; 0 -1 0; 0 0 -1] # hide
b = [1, 1, 1, 1, 1, 1] # hide
cube = Spindle(A, b) # hide
for v in Spindles.incidentvertices(cube, [1])
    println(collect(vertices(cube))[v])
end
```

As expected, we obtain precisely those four vertices whose first component is equal to one.
