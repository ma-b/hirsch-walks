# Operations on polytopes

## Equality and containment
```@docs
==
in
```

## Constructions
The following operations on [`Polytope`](@ref)s are supported: 
* Cartesian product
* Minkowski sum
* polarization
* rescalation and translation
To define more complex operations that act on the set of vertices, use [`map`](@ref).
See below for an example of how projections can be defined using [`map`](@ref).
More examples can be found in [this tutorial](@ref "Line segments, hypercubes, and permutahedra").

```@autodocs
Modules = [Spindles.Polytopes]
Pages = ["Polytopes/operators.jl"]
```