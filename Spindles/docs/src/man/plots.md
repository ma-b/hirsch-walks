# Plotting faces

```@example plots
using Spindles #hide
square = Spindle([1 0; 0 1; -1 0; 0 -1], [1, 1, 1, 1])
vertices(square)
```

```@example plots
plot2face(square, Int[]; usecoordinates=true, facetlabels=nothing, directed_edges=([1,3], [2,4]))
```
Now perturb the square slightly so that those two edges are no longer parallel.
```@example plots
perturbed_square = Spindle([1 -1//8; 0 1; -1 -1//8; 0 -1], [9//8, 1, 9//8, 1])
vertices(perturbed_square)
```

```@example plots
plot2face(perturbed_square, Int[]; usecoordinates=true, facetlabels=nothing, directed_edges=([1,3], [2,4]))
```


```@docs
plot2face
```
