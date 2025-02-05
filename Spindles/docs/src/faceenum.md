# Enumerating faces
*Spindles.jl* implements an algorithm for enumerating all faces of a given dimension. On large inputs, this algorithm works best for near-simple spindles (with few degenerate vertices).

```@meta
DocTestSetup = quote
    push!(LOAD_PATH, "../../src")
    using Spindles
end
```


!!! warning

    Currently only full-dimensional spindles given by irredundant inequality descriptions are supported.


```@docs
facesofdim
```

```@docs
nfacesofdim
```

```@docs
graph
```

```@docs
isgood2face
```

## Full docs

```@autodocs
Modules = [Spindles]
Pages = [
    "Spindles.jl",
    "goodfaces.jl"
]
```