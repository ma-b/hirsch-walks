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
Spindle(A::Matrix{T}, b::Vector{T}, lib::Polyhedra.Library) where T
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

```@docs
setapex!
```

## Incidence 

```@docs
incidentvertices
```

## Dimension

```@docs
Spindles.dim
```
