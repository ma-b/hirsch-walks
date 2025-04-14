# Representations

We saw that a [`Polytope`](@ref) may be created from either a V- or a H-representation.
*Spindles.jl* provides functions to retrieve both types of representations for a given polytope,
and to detect redundancy.

## Vertices
A polytope is the convex hull of its vertices.
```@docs
Spindles.Polytopes.vertices
nvertices
```
The function [`vertices`](@ref Spindles.vertices) is also used to test two polytopes for equality with
the [`==`](@ref) operator, see [Operators](@ref).

## Linear systems and redundancy
Each vertex returned by [`Spindles.Polytopes.vertices`](@ref) is a vector in the ambient space of the polytope.
The dimension of this space is given by
````@docs
ambientdim
````

Note that this may be different from the actual dimension of a polytope (see [`dim`](@ref Spindles.Polytopes.dim))
when the polytope is contained in a proper affine subspace of the ambient space. The smallest
such subspace is the *affine hull* of the polytope. Every H-representation of a polytope must include constraints
that define its affine hull. They may be included as explicit equality constraints, or as so-called
*implicit equations*. These are inequalities that are satisfied at equality by all points in the polytope.
Both types of equality constraints can be collected using [`affinehull`](@ref Spindles.Polytopes.affinehull).

````@docs
Spindles.Polytopes.affinehull
````

To obtain a complete H-representation, we further need inequalities to describe the facets of `p`.
````@docs
inequalities
ineqindices
````

Note that the system returned by `inequalities` is not necessarily minimal, i.e., it may include 
redundant inequalities. A *redundant inequality* is one whose deletion leaves the polytope unchanged.
A sufficient subset of inequalities from the given description returned by [`inequalities`](@ref) can be extracted
using the function [`facets`](@ref).

```@docs
facets
nfacets
```

## Incidence
```@docs
incidentvertices
tightinequalities
```