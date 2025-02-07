# First steps
This tutorial demonstrates the basic usage of *Spindles.jl* to create spindles and query basic properties.

## Creating a spindle
Recall that the special property of a spindle is the existence of two vertices (the apices) whose incident facets partition the set of all facets. In this tutorial, we will be working with one of the simplest examples of a spindle: a cube. For example, the unit cube in 3D is given by all points $(x_1,x_2,x_3)$ that satisfy 
```math
-1 \le x_1 \le 1, \quad -1 \le x_2 \le 1, \quad -1 \le x_3 \le 1
```

In matrix notation, this is equivalent to the system $Ax \le b$ where

```@example cube
A = [1 0 0; -1 0 0; 0 1 0; 0 -1 0; 0 0 1; 0 0 -1]
```
and
```@example cube
b = [1, 1, 1, 1, 1, 1]
```

*Spindles.jl* provides a data type for representing and analyzing spindles: [`Spindles.Spindle`](@ref). We may create an object of this type from our data `A` and `b` as follows:

```@example cube
push!(LOAD_PATH, "../../../src") # hide
using Spindles # hide
cube = Spindle(A, b)
```

!!! warning

    Currently, [`Spindle`](@ref Spindles.Spindle) only supports **full-dimensional polytopes** given by **irredundant** inequality descriptions.

Even though `cube` is of type [`Spindle`](@ref Spindles.Spindle), this does not automatically mean that it is indeed a spindle in the polyhedral sense. For this, it must have two apices. To see whether it does, let us first list all (eight) vertices of `cube`.

```@example cube
vertices(cube)
```

!!! note

    By default, *Spindles.jl* uses exact rational arithmetic. Note that the components of each vertex returned by [`Spindles.vertices`](@ref) are of type `Rational` with numerators and denominators of type `BigInt` to avoid integer overflows (see the Julia documentation pages on [rational numbers](https://docs.julialang.org/en/v1/manual/complex-and-rational-numbers/#Rational-Numbers) and [arbitrary-precision arithmetic](https://docs.julialang.org/en/v1/manual/integers-and-floating-point-numbers/#Arbitrary-Precision-Arithmetic)).

The existence of two apices may be checked using the function [`Spindles.apices`](@ref), which returns the indices of two vertices of `cube` that act as apices:

```@example cube
apices(cube)
```

So the first and last vertex in the list above can take the role of apices. However, these two are not unique. In fact, for a cube there are many possible pairs of apices: take an arbitrary vertex and its antipodal one, i.e., the vertex obtained by flipping the sign of each component. If we want to prescribe an apex, we can tell [`Spindles.apices`](@ref) to use a given vertex as the first apex and try to find a matching second one:

```@example cube
apices(cube, 3)
```

## Working with the graph
We may even compute the distance between those two apices in the graph of `cube`:

```@example cube
dist_toapex(cube, apices(cube)...)
```

Behind the scenes, the call to [`Spindles.dist_toapex`](@ref) first computes the graph of `cube`. The graph can also be accessed directly using [`Spindles.graph`](@ref), which returns a graph of a type defined by the [*Graphs.jl*](https://juliagraphs.org/Graphs.jl/) package. 
For instance, we may verify the well-known fact that cubes are simple by using the function [`Graphs.degree`](https://juliagraphs.org/Graphs.jl/stable/core_functions/core/#Graphs.degree):

```@example cube
using Graphs: degree
all(degree(graph(cube)) .== 3)
```

## Counting and enumerating faces
*Spindles.jl* also provides functions to count and enumerate the faces of `cube`. The following call to [`Spindles.facesofdim`](@ref) returns a list of all two-dimensional faces, each one given by the indices of its incident facets.

!!! note

    Facet indices refer to the corresponding rows of the coefficient matrix `A`. 

```@example cube
facesofdim(cube, 2)
```

Given that the two-dimensional faces of `cube` are precisely the six facets, this should not be too surprising. 

!!! tip

    To count the faces of a given dimension without explicitly producing a list, use the function [`Spindles.nfacesofdim`](@ref).

Let us list all vertices contained in the first facet.

```@example cube
for v in Spindles.incidentvertices(cube, [1])
    println(collect(vertices(cube))[v])
end
```

As expected, we obtain precisely those four vertices whose first component is equal to one.

!!! note

    Both [`vertices`](@ref Spindles.vertices) and [`incidentvertices`](@ref Spindles.incidentvertices) return iterators. To access a specific element, use [`collect`](https://docs.julialang.org/en/v1/base/collections/#Base.collect-Tuple{Any}) as in the code above.
