# Spindles and the Hirsch conjecture
This tutorial showcases more advanced use cases of *Spindles.jl*. For its basic usage, please read [this tutorial](@ref "First steps") first.

## Reading an inequality description from a file
```@example s48
push!(LOAD_PATH, "../../src") # hide
using Spindles # hide
A, b, labels = readineq("../../examples/s-48-5.txt", Int);
```

```@example s48
A, b, labels = readineq("../../examples/s-48-5.txt", Int);  # hide
[A b]
```
This does not only read the inequality description from the source but also the attached labels, one for each inequality.

```@example s48
labels
```

```@example s48
s48 = Spindle(A, b)
nvertices(s48)
```

Note that ... returns an iterator
```@example s48
collect(vertices(s48))[apices(s48)]
```

## Good 2-faces
```@example s48
nfacesofdim(s48, 2)
```


```@example s48
[(f, labels[f]) for f in sort(facesofdim(s48, 2)) if isgood2face(s48, f).good]
```


```@example s48
1
#plot2face(s48, [29,37,41], usecoordinates=true, facetlabels=labels);
```

This produces the following output:
