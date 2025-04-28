# Combinatorics

## Dimension
```@docs
Spindles.Polytopes.dim
```

[`dim`](@ref Spindles.Polytopes.dim) can be used to test whether an inequality is facet-defining 
for a polytope `p` (see the example above). In high dimensions, this may be slow,
since [`dim`](@ref Spindles.Polytopes.dim) constructs a chain of faces between the empty face and the given face
– which in the case of a facet amounts to a maximal chain except for the maximal face `p`.
In this case, however, the complementary approach is fast: Find a chain of faces not between the empty face
and the given face, but between the face and the polytope `p` itself. From the length of the resulting chain, 
one can easily read off the *codimension* of the face (which equals 1 for a facet):

```@docs
codim
```

## Face enumeration
*Spindles.jl* implements an algorithm for enumerating all faces of a given dimension. The algorithm 
is optimized for near-simple polytopes, i.e., polytopes with few degenerate vertices. It is inspired
by an algorithm for computing the graph of a polytope described [here](https://sites.google.com/site/christopheweibel/research/hirsch-conjecture) (see also the [paper](https://arxiv.org/pdf/1202.4701)).

```@docs
facesofdim
nfacesofdim
```

## Graphs and distances
For example, calling [`facesofdim`](@ref)`(p, 1)` lists the one-dimensional faces, the edges, of the polytope `p`.
These edges, written as pairs of adjacent vertices, define the graph (or *1-skeleton*) of `p`. The graph
can also be retrieved directly:

```@docs
graph
dist
```

## Simplicity and simpliciality
```@docs
issimple
issimplicial
```

## Spindles
Spindles are special polytopes for which each facet is incident to exactly one of two special vertices.
```@docs
apices
```