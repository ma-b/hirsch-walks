# Plotting faces

Since the initial purpose of *Spindles.jl* is the detection of special 2-faces, 
the package includes a visualization function.

```@docs
plot2face
```

###### Examples
Consider the following polytope, a perturbed cube:
````@example plots
using Spindles #hide
p = Polytope(
    [ 1  0     0
      0  1 -1//8
      0  0     1
      -1 0     0
      0 -1 -1//8
      0  0    -1 ], 
    [1, 9//8, 1, 1, 9//8, 1]
);
nothing #hide
````

Let's create a custom plot of two facets of `p`, facets `1` and `6`:
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
and overwrite the default behaviour of `plot2face` with `usecoordinates=true`.



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

!!! tip
    More examples can be found in [this tutorial](@ref "Spindles and the Hirsch conjecture I").