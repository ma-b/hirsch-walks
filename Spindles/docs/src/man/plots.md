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

The plot can be customized using keywords in `kw...`. There are two types of keywords: attributes
that are inherited from [Plots.jl](https://github.com/JuliaPlots/Plots.jl), and custom attributes defined
by *Spindles.jl*.
The following attributes are supported:

###### Custom attributes
* `usecoordinates`: If `true` (default), plot a 2D projection onto a coordinate subspace.
  `false` ignores vertex coordinates and arranges the vertices on a cycle.
* `vertexlabels`: An indexable collection (such as `AbstractVector` or `AbstractDict`) of strings, 
  or `nothing` to disable vertex labels. If not `nothing`, the label of vertex `i` is 
  `vertexlabels[i]`, where missing values are treated as `""`. 
  If unspecified, use vertex indices as default labels.
* `ineqlabels`: Like `vertexlabels`, but for facet/inequality labels.
  If unspecified, use inequality indices as default labels.
* `markup_edges`: An optional tuple of edges `([s,t], [u,v])` to be marked up in the plot. 
  Non-parallel edges are drawn as directed edges in the following way: 
  If the inequality ``\langle a,x \rangle \le \beta`` defines the edge `[s,t]`, 
  then the other edge `[u,v]` is directed from `u` to `v` if and only if 
  ``\langle a, v-u \rangle < 0`` (and vice versa).

* `markup_linecolor`, `markup_linewidth` and everything prefixed by `markup_`. 
  Note that aliases like `lc` or `lw` for the unprefixed attributes are currently not supported.


###### Notable attributes from Plots.jl
* Series attributes such as `linewidth`, `linecolor`, `linealpha`, ...
  `markersize`, `markercolor`, `markeralpha`, ... to customize vertex markers,
  `fillcolor`, `fillalpha`, ... to customize the polygon shape,
* Plot attributes such as `size`, ...
* Subplot attributes such as `aspect_ratio`, `title`, ...
* Axis attributes such as `grid`, `ticks`, ...

See also the [Plots.jl documentation pages](https://docs.juliaplots.org/latest/attributes/) 
for a list of all available attributes and their aliases. Not all of them have an effect for plotting polytopes, though.

!!! note "Hardcoded attributes"
    Currently hardcoded: label attributes (font, size, colour)

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
All plots can be customized using various attributes. In the following example, some of them are set 
to override the default behaviour. Note that we use aliases like `lw` for `linewidth`, `lc` for `linecolor`, or `fc` for `fillcolor`.

````@example plots
plot(p, [1];
    vertexlabels=nothing,             # no vertex labels
    ineqlabels=["a", "b", "c", "d"],  # custom edge labels

    lw=5, lc=:purple,                 # appearance of edges
    fc=:gold,                         # face colour
    markersize=10,                    # size of vertex markers

    markup_edges=([2,5], [7,8]),    # appearance of marked up edges
    markup_linewidth=2.5, markup_linecolor=:turquoise3,

    grid=true, ticks=-2:0.5:2,        # 
    size=(350,250),                   # plot size
    aspect_ratio=:equal,              # set unit aspect ratio
    title="A fancy plot"              # custom title
)
````
Also note that we provided `ineqlabels` only for the first four facets above. Missing labels are treated as `""`.
