# Faces

```@meta
DocTestSetup = quote
    push!(LOAD_PATH, "../../src")
    using Spindles
end
```

## Enumeration

```@docs
graph
```

*Spindles.jl* implements an algorithm for enumerating all faces of a given dimension. On large inputs, this algorithm works best for near-simple spindles (with few degenerate vertices).

```@docs
facesofdim
```

```@docs
nfacesofdim
```

## Length of paths

```@docs
dist_toapex
```
## Good faces

```@docs
Spindles.FaceState
```

```@docs
isgood2face
```
