# Basic operations

## Equality and containment
```@docs
==
in
```

## Constructions
*Spindles.jl* currently supports the following operations on [`Polytope`](@ref)s: 
* Cartesian product
* Minkowski sum
* rescalation and translation
* polarization
More complex operations that act on the set of vertices can be realized using [`map`](@ref).

```@autodocs
Modules = [Spindles.Polytopes]
Pages = ["Polytopes/operators.jl"]
```