# Plotting faces

Being a package focused on detecting faces of special polytopes with certain (combinatorial or geometric) 
properties, *Spindles.jl* provides a function to visualize 2-faces. Often drawings help understand these 
properties, which is why these documentation pages try to visualize as much as possible.

!!! note "Implementation note"

    The implementation in *Spindles.jl* heavily relies on [Plots](https://docs.juliaplots.org/stable/),
    much like the visualization utilities of [Polyhedra](https://juliapolyhedra.github.io/Polyhedra.jl/stable/plot/).
    In fact, there is nothing specific to spindles in the implementation of the plotting function described below;
    it would work for 2-faces of any polytope. However, the reason for including a bespoke visualization tool
    in *Spindles.jl* is the package design decision to offer lean solutions that serve the initial purpose
    of supporting theoretical explorations without much coding overhead.

The plotting function of *Spindles.jl* is called [`plot2face`](@ref) and is best described using an example. 

## Example
We will use the following simple spindle, a square in 2D.

```@example plots
using Spindles #hide
square = Spindle([1 0; 0 1; -1 0; 0 -1], [1, 1, 1, 1])
vertices(square)
```

Since `square` is two-dimensional already, the most basic form of calling `plot2face` 
just takes as arguments the spindle and a list of inequality/facet indices that define the face to be drawn.
In our example, this list is empty to get the maximal face, the spindle itself:
```@example plots
plot2face(square, Int[])
```
By default, vertices are labeled by their index in `vertices(square)`. The edge labels indicate which facet-defining inequalities for `square` define the edge. We may relabel vertices and edges using the keyword 
arguments `vertexlabels` and `ineqlabels` as follows:

```@example plots
plot2face(square, Int[]; vertexlabels=["a", "b", "c", "d"], ineqlabels=["^", "*", "+", "-"])
```

If we are only interested in the combinatorics of `square` (which of course isn't all too interesting),
we can tell `plot2face` to make a plot of the graph of `square`, where vertices are placed equidistantly
on a cycle. In our example, this of course does not change too much:
```@example plots
plot2face(square, Int[]; usecoordinates=false)
```

Another option that has its origins in the theoretical analysis of 2-faces allows for marking up a pair of edges.
To see the effect, let us drop the edge labels for the moment. This is achieved by setting `ineqlabels` to
`nothing`.
```@example plots
plot2face(square, Int[]; ineqlabels=nothing, directed_edges=([1,3], [2,4]))
```

Now perturb the square slightly so that those two edges are no longer parallel.
```@example plots
perturbed_square = Spindle([1 -1//8; 0 1; -1 -1//8; 0 -1], [9//8, 1, 9//8, 1])
vertices(perturbed_square)
```

```@example plots
plot2face(perturbed_square, Int[]; ineqlabels=nothing, directed_edges=([1,3], [2,4]))
```

## Full reference

```@docs
plot2face
```
