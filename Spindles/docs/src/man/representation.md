# Representation

```@meta
DocTestSetup = quote
    using Polyhedra
end
```

```@docs
Spindles
```

The main type defined by *Spindles.jl* is

```@docs
Spindle
```

Objects of this type may be created in one of two possible ways:

```@docs
Spindle(::Matrix{T}, ::Vector{T}, ::Union{Nothing, Polyhedra.Library}=nothing) where T<:Number
```


## Vertices and apices

```@docs
Spindles.vertices
```

```@docs
nvertices
```

```@docs
apices
```

## Incidence 

```@docs
Spindles.incidentvertices
```
