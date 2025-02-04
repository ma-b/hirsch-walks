# Enumerating faces
*Spindles.jl* implements an algorithm for enumerating all faces of a given dimension. On large inputs, this algorithm works best for near-simple spindles (with few degenerate vertices).

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
    "goodfaces.jl"
]
```