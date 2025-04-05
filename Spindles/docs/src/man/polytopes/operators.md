# Operators
*Spindles.jl* supports common operations on polytopes.

## Set-theoretic operators
```@autodocs
Modules = [Spindles.Polytopes]
Pages = ["Polytopes/setoperators.jl"]
```

## Sums and products of polytopes
```@docs
+(::Polytope, ::Polytope)
sum
*(::Polytope, ::Polytope)
```

## Transformations
```@docs
+(::Polytope, ::AbstractVector{<:Number})
-(::Polytope, ::AbstractVector{<:Number})
*(::Polytope, ::Number)
/
//
-(::Polytope)
```

To define more complex mappings of the set of vertices, use [`map`](@ref).
See below for an example of how projections can be defined using [`map`](@ref).
More examples can be found in [this tutorial](@ref "Line segments, hypercubes, and permutahedra").

```@docs
map
```

# Polarization
```@docs
polarize
```