# Plotting faces

To visualize 2-faces of polytopes, a `Polytope` object can be passed to the [`plot`](https://docs.juliaplots.org/dev/api/#RecipesBase.plot) command from [Plots.jl](https://github.com/JuliaPlots/Plots.jl).

## Basic usage
The basic form of the `plot` command is
````julia
plot(p::Polytope, indices; kw...)
````

This creates a plot of the face of `p` that is defined by the inequalities in `indices`,
provided that this face is 2-dimensional. If not, `plot` throws an error.
To add to an existing plot, use `plot!`.

The plot can be customized using keywords in `kw...`. The following keywords are supported:

###### 1. Plot type and labels
* `usecoordinates`: If `true` (default), plot a 2D projection onto a coordinate subspace.
  `false` ignores vertex coordinates and arranges the vertices on a cycle.
* `vertexlabels`: An indexable collection (such as `AbstractVector` or `AbstractDict`) of strings, 
  or `nothing` to disable vertex labels. If not `nothing`, the label of vertex `i` is 
  `vertexlabels[i]`, where missing values are treated as `""`. 
  If unspecified, use vertex indices as default labels.
* `ineqlabels`: Like `vertexlabels`, but for facet/inequality labels.
  If unspecified, use inequality indices as default labels.

###### 2. Attributes from Plots.jl
Can be any [series](https://docs.juliaplots.org/latest/generated/attributes_series/),
[plot](https://docs.juliaplots.org/latest/generated/attributes_plot/),
[subplot](https://docs.juliaplots.org/latest/generated/attributes_subplot/),
or [axis attributes](https://docs.juliaplots.org/latest/generated/attributes_axis/) defined by Plots.jl.
See also the [Plots.jl documentation](https://docs.juliaplots.org/latest/attributes/) on attributes and aliases.
Note that not all available attributes have an effect for plotting polytopes, though. 

Among the supported series attributes, fill attributes such as `fillalpha`, `fillcolor`, `fillstyle` 
apply to the face itself. Line attributes such as `linealpha`, `linecolor`, `linestyle`, `linewidth` 
apply to its edges and marker attributes such as `markersize`, `markeralpha`, `markercolor` 
apply to vertex markers (see also the examples below).

!!! note "Hardcoded attributes"
    Currently, label attributes (font, size, colour) cannot be modified. 
    By default, the edge colour (`linecolor`) is also used for all edge labels.

###### 3. Marking up edges
* `markup_edges`: A tuple or vector of two edges `s,t` and `u,v` to be marked up in the plot. 
  Non-parallel edges are drawn as directed edges in the following way: 
  If the inequality ``\langle a,x \rangle \le \beta`` defines the first edge between `s` and `t`, 
  then the second edge is directed from `u` to `v` if and only if 
  ``\langle a, v-u \rangle < 0`` (and vice versa with the roles of the edges switched).
  Here, ``u`` and ``v`` refer to the actual coordinates of the respective vertices, regardless of
  whether `usecoordinates` is `true` or `false`.

* `markup_headsize`: Size of the arrowhead for directed edges.
* `markup_headpos`: A number between 0 and 1 that is taken as a relative offset of the arrow tip:
  1 means that the tip is drawn at the sink (default), and 0 means it is drawn at the source of the directed edge.
* Line attributes (or aliases) prefixed by `markup_` apply to the marked up edges only. For example, their
  width is set with `markup_linewidth` (or `markup_lw` or any other alias).

## Examples
Examples are best to demonstrate the usage of `plot`.
Further examples can also be found in [this tutorial](@ref "Spindles and the Hirsch conjecture I").

We use the following polytope, a perturbed cube, as an example.
````@example plots
using Spindles #hide
A = [  1   0      0
       0   1  -1//8
       0   0      1
      -1   0      0
       0  -1  -1//8
       0   0     -1 ]
b = [1, 9//8, 1, 1, 9//8, 1]

p = Polytope(A, b);
nothing #hide
````

### Default plots
First, let's create the simplest of all plots for one of the facets of `p`. (Note that all facets of `p` are
2-faces since `p` is 3-dimensional.)
````@example plots
using Plots
plot(p, [1])
````

By default, vertices are labeled by their indices and edges by the indices of their incident facets.
The 2-face itself, i.e., the facet `1`, also gets a label. It is made up of the labels of its incident facets 
(of which there is only one in this case, of course).

The axis labels indicate onto which subset of coordinates the facet was projected to obtain a planar drawing.
The labels tells us that the four vertices of facet `1` were positioned at the following coordinates:
````@example plots
for i in incidentvertices(p, [1])
    println(i, "  ", collect(vertices(p))[i][2:3])
end
````
Since these coordinates are difficult to check without any axis ticks, let's add them to the plot:
````@example plots
plot(p, [1]; grid=true, ticks=-2:2)
````

To ignore the geometry altogether, do
````@example plots
plot(p, [1]; usecoordinates=false)
````
Now the vertices are placed equidistantly on a cycle.

Pairs of edges can be marked up as follows:
````@example plots
plot(p, [1]; markup_edges=([2,5], [7,8]))
````
The two edges passed as a tuple in `markup_edges` are drawn as directed edges in such a way that the arrows point away from each other. If they were parallel, such as the other two edges of facet `1`, they would not have gotten arrowheads:
````@example plots
plot(p, [1]; markup_edges=([2,7], [5,8]))
````

### Customization
All plots can be customized using various attributes. The following example features some of them,
sometimes with their full name, sometimes with aliases (such as `lw` for `linewidth` or `fc` for `fillcolor`).

````@example plots
plot(p, [1];
    vertexlabels=nothing,             # no vertex labels
    ineqlabels=["a", "b", "c", "d"],  # custom edge labels

    lw=5, lc=:purple,                 # appearance of edges
    fc=:gold, fillstyle=:/,           # face colour and fill pattern
    markersize=10,                    # size of vertex markers

    markup_edges=([2,5], [7,8]),      # appearance of marked up edges
    markup_lw=2.5, markup_lc=:turquoise3,
    markup_ls=:dash,
    markup_headsize=42,               # size of arrowheads

    grid=true, ticks=-2:0.5:2,        # coordinate axes
    size=(350,250),                   # plot size
    aspect_ratio=:equal,              # set unit aspect ratio
    title="A fancy plot"              # custom title
)
````
Note that we provided `ineqlabels` only for the first four facets above. Missing labels are treated as `""`.
