# Representations

```@meta
DocTestSetup = quote
    using Spindles
end
```

```@docs
ambientdim
```

We saw that a [`Polytope`](@ref) may be created from either a V- or a H-representation. However, these representations 
need not be minimal. Which points or inequalities from the given description suffice can be detected with 
the following functions.

## Vertices
To express a polytope as the convex hull of some finite set of points, the set of its vertices suffices.
```@docs
Spindles.vertices
nvertices
```
The function [`vertices`](@ref Spindles.vertices) is also used to test two polytopes for equality with
the [`==`](@ref) operator, see [Operations on polytopes](@ref).

## Redundancy and implicit equations
A *redundant inequality* is one whose deletion leaves the polytope unchanged. If an inequality is satisfied 
at equality by all points in the polytope, it is said to be an *implicit equation*. 
Thus, the inequalities in a given description of a polytope may be partitioned into three sets:
1. a minimal set of facet-defining inequalities (which may not be unique!), 
2. a (possibly empty) set of implicit equations contained in the inequality system, and 
3. all remaining inequalities (that may safely be deleted). 
This partition can be computed using the functions [`facets`](@ref) and [`impliciteqs`](@ref),
which return the first two classes of the partition.

```@docs
facets
nfacets
impliciteqs
```

## Incidence
```@docs
incidentvertices
``` 

```@meta
DocTestSetup = nothing
```