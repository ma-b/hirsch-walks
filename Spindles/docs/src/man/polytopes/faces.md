# Faces and graphs

```@meta
DocTestSetup = quote
    push!(LOAD_PATH, "../../src")
    using Spindles
end
```

## Enumeration
*Spindles.jl* implements an algorithm for enumerating all faces of a given dimension. The algorithm 
is optimized for near-simple polytopes, i.e., polytopes with few degenerate vertices. It is inspired
by an algorithm for computing the graph of a polytope described [here](https://sites.google.com/site/christopheweibel/research/hirsch-conjecture) (see also the [paper](https://arxiv.org/pdf/1202.4701)).

```@docs
facesofdim
```

```@docs
nfacesofdim
```

For example, calling `facesofdim(p, 1)` lists the incident halfspaces of each edge of the polytope `p`.
These edges, given as pairs of adjacent vertices, define the graph (or *1-skeleton*) of `p`. The graph
can also be retrieved directly:

```@docs
graph
```

## Length of paths

```@docs
dist
```