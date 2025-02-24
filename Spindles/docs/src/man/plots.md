# Plotting faces

Since the initial purpose of *Spindles.jl* is the detection of special 2-faces, 
the package provides a function to visualize those.

!!! note "Implementation note"

    The implementation in *Spindles.jl* relies on [Plots.jl](https://github.com/JuliaPlots/Plots.jl).
    Polygons such as 2-faces of polytopes may also be visualized, more generally, 
    using [Polyhedra.jl](https://github.com/JuliaPolyhedra/Polyhedra.jl).

The plotting function of *Spindles.jl* is called [`plot2face`](@ref) and is best described using an example. 

## Example
We will use the following simple polytope, a square in 2D given by
```math
\begin{aligned}
-1 \le x_1 &\le 1 \\
-1 \le x_2 &\le 1
\end{aligned}
```

```@example plots
using Spindles #hide
square = Polytope([1 0; 0 1; -1 0; 0 -1], [1, 1, 1, 1])
vertices(square)
```

Since `square` is two-dimensional already, the most basic form of calling `plot2face` 
just takes as arguments the polytope and a list of inequality indices that define the face to be drawn.
In our example, this list is empty to get the maximal face, the polytope itself:
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
perturbed_square = Polytope([1 -1//8; 0 1; -1 -1//8; 0 -1], [9//8, 1, 9//8, 1])
vertices(perturbed_square)
```

```@example plots
plot2face(perturbed_square, Int[]; ineqlabels=nothing, directed_edges=([1,3], [2,4]))
```

## Full reference

```@docs
plot2face
```
