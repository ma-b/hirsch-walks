# Dimension

```@docs
Spindles.dim
```

[`dim`](@ref Spindles.dim) can be used to test whether an inequality is facet-defining 
for a polytope `p` (see the example above). In high dimensions, this may be slow,
since [`dim`](@ref Spindles.dim) constructs a chain of faces between the empty face and the given face
– which in the case of a facet amounts to a maximal chain except for the maximal face `p`.
In this case, however, the complementary approach is fast: Find a chain of faces not between the empty face
and the given face, but between the face and the polytope `p` itself. From the length of the resulting chain, 
one can easily read off the *codimension* of the face (which equals 1 for a facet):

```@docs
codim
```