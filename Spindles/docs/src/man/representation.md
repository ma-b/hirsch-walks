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

There are two possible ways to construct objects of this type. The first way explicitly uses `Polyhedra`:

```@docs
Spindle(p::Polyhedra.Polyhedron)
```

To make spindle constructions more convenient, there is a second constructor 
that accepts the data of an H-representation and does not require any imports from `Polyhedra`:
```@docs
Spindle(A::AbstractMatrix{<:Real}, b::AbstractVector{<:Real}, lib::Union{Nothing, Polyhedra.Library}=nothing)
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
