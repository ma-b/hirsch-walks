# Spindles and the Hirsch conjecture
This tutorial showcases more advanced use cases of *Spindles.jl*. For its basic usage, please read [this tutorial](@ref "First steps") first.

## Reading an inequality description from a file
```@example
push!(LOAD_PATH, "../../src") # hide
using Spindles # hide
A, b, labels = readineq("../../examples/s-48-5.txt", Int);
```

```@example
push!(LOAD_PATH, "../../src") # hide
using Spindles # hide
A, b, labels = readineq("../../examples/s-48-5.txt", Int);  # hide
[A b]
```
This does not only read the inequality description from the source but also the attached labels, one for each inequality.

```@example
push!(LOAD_PATH, "../../src") # hide
using Spindles # hide
A, b, labels = readineq("../../examples/s-48-5.txt", Int);  # hide
labels
```

```@example
push!(LOAD_PATH, "../../src") # hide
using Spindles # hide
A, b, labels = readineq("../../examples/s-48-5.txt", Int);  # hide
s48 = Spindle(A, b)
nvertices(s48)
```

Note that ... returns an iterator
```@example
push!(LOAD_PATH, "../../src") # hide
using Spindles # hide
A, b, labels = readineq("../../examples/s-48-5.txt", Int);  # hide
s48 = Spindle(A, b) # hide
collect(vertices(s48))[apices(s48)]
```

## Good 2-faces
```@example
push!(LOAD_PATH, "../../src") # hide
using Spindles # hide
A, b, labels = readineq("../../examples/s-48-5.txt", Int);  # hide
s48 = Spindle(A, b) # hide
nfacesofdim(s48, 2)
```


```@example
push!(LOAD_PATH, "../../src") # hide
using Spindles # hide
A, b, labels = readineq("../../examples/s-48-5.txt", Int);  # hide
s48 = Spindle(A, b) # hide
[(f, labels[f]) for f in sort(facesofdim(s48, 2)) if isgood2face(s48, f).good]
```


```@example
push!(LOAD_PATH, "../../src") # hide
using Spindles # hide
A, b, labels = readineq("../../examples/s-48-5.txt", Int);  # hide
s48 = Spindle(A, b) # hide
#plot2face(s48, [29,37,41], usecoordinates=true, facetlabels=labels);
```

This produces the following output: