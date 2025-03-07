# Plotting faces

As one of the initial purposes of *Spindles.jl* was the detection of special 2-faces, 
the package includes a visualization function.

```@docs
plot2face
```

###### Examples
Consider the following polytope, a perturbed cube:
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

Let's create a custom plot of facets `1` and `6` of `p` (note that all facets of `p` are 2-faces):
````@example plots
plot_arr = [
    plot2face(p, [i];
        grid=true, ticks=-2:2, aspect_ratio=:equal, 
        title="Facet $i",
    ) for i in [6,1]
]

using Plots
plot(plot_arr..., layout=grid(1,2), size=(500,250), plot_title="Example")
````

By default, the axes of each subplot are labeled by the two coordinates onto which the face was projected.
For example, the second subplot for facet `1` shows the four vertices at the following coordinates:
````@example plots
for i in incidentvertices(p, [1])
    println(i, "  ", collect(vertices(p))[i][2:3])
end
````

To turn off axis labels, pass the keywords `xguide=""` and `yguide=""` to [`plot2face`](@ref).
Note that these are [axis attributes of Plots.jl](https://docs.juliaplots.org/latest/generated/attributes_axis/)
and overwrite the default values used in `plot2face`.

Pairs of edges can be marked up as follows:

````@example plots
plot_arr = [
    plot2face(p, [i]; ineqlabels=nothing,
        grid=true, ticks=-2:2, aspect_ratio=:equal, 
        title="Facet $i",
        directed_edges = i==6 ? ([1,3],[2,7]) : ([2,5],[7,8])
    ) for i in [6,1]
]

using Plots
plot(plot_arr..., layout=grid(1,2), size=(500,250), plot_title="Example")
````

For facet `6`, the two edges marked up in the plot are parallel. The two chosen edges of facet `1`, however,
are not and are therefore drawn as directed edges with arrows pointing away from each other. 

!!! tip
    More examples can be found in [this tutorial](@ref "Spindles and the Hirsch conjecture I").