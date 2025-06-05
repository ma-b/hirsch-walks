# ================================
# Face enumeration
# ================================

# --------------------------------
# graph
# --------------------------------

graphiscomputed(p::Polytope) = p.graph !== nothing
"""
    graph(p::Polytope)

Return the graph of the polytope `p`, which is a simple undirected graph of type 
[`Graphs.SimpleGraphs.SimpleGraph`](https://juliagraphs.org/Graphs.jl/stable/core_functions/simplegraphs/#Graphs.SimpleGraphs.SimpleGraph).
"""
function graph(p::Polytope)
    if !graphiscomputed(p)
        computegraph!(p)
    end
    return p.graph
end

function computegraph!(p::Polytope)
    if !inciscomputed(p)
        computeinc!(p)
    end
    
    nv = nvertices(p)

    # number of implicit equations
    if !implicitscomputed(p)
        computeimpliciteqs!(p)
    end
    n_implicits = sum(p.isimpliciteq)

    # initialize graph
    p.graph = Graphs.SimpleGraph(nv)

    # to enumerate all edges, we follow Christophe Weibel's approach outlined here:
    # https://sites.google.com/site/christopheweibel/research/hirsch-conjecture
    
    # (1) brute-force all pairs of vertices that are contained in at least dimension minus 1 common facets

    # we count the number of facets incident with both vertex i and j as follows:
    n_inc(i::Int, j::Int) = sum(p.inc[i] .& p.inc[j])
    
    pairs = [
        ([i,j], n_inc(i,j)) for i=1:nv for j=i+1:nv 
        if n_inc(i,j) >= n_implicits + dim(p) - 1
    ]

    # (2) drop all pairs that do not define edges: 

    # For two vertices i,j that are not adjacent, the minimal face containing both i and j must be at least 2-dimensional.
    # This face could still be contained in dimension minus 1 facets (more than would be needed) if the polytope is degenerate.
    # But then this face has an edge, which is contained in at least one additional facet. So for i,j to be adjacent, 
    # their set of common facets must be inclusion-maximal among all such sets.

    # For near-simple polytopes, the task of checking for inclusion-maximality can be sped up be splitting 
    # the list of possibly adjacent pairs i,j into those that are contained in exactly dimension minus 1 facets 
    # and those that are contained in more:
    # most pairs will be of the first type, and inclusion among their sets of common facets does not have to 
    # be checked because they are all distinct and of the same size.

    nondegenerate_pairs = [ e     for (e, m) in pairs if m == n_implicits + dim(p) - 1]
    degenerate_pairs    = [(e, m) for (e, m) in pairs if m >  n_implicits + dim(p) - 1]

    # we use this predicate to check inclusion-maximality: return true if and only if 
    # each facet incident to all vertices in list `a` is also incident to all vertices in `b`, or
    # in terms of BitVectors, x <= y, which is equivalent to y .| (~).x
    iscontained(a::Vector{Int}, b::Vector{Int}) = all(reduce(.&, p.inc[b]) .| (~).(reduce(.&, p.inc[a])))  # ~ bitwise NOT
    
    for e in nondegenerate_pairs
        if !any(iscontained(e, d) for (d, _) in degenerate_pairs)
            Graphs.add_edge!(p.graph, e...)
        end
    end
    for (d, m) in degenerate_pairs
        # strict superset must have strictly greater cardinality
        if !any(iscontained(d, dd) for (dd, mm) in degenerate_pairs if mm > m)
            Graphs.add_edge!(p.graph, d...)
        end
    end
end

# --------------------------------
# complete face enumeration
# --------------------------------

facescomputed(p::Polytope, k::Int) = haskey(p.faces, k)
function computefacesofdim!(p::Polytope, k::Int)
    k > 1 || return  # do not cache faces of lower dim
    
    if !inciscomputed(p)
        computeinc!(p)
    end
    
    nv = nvertices(p)
    
    # number of implicit equations
    if !implicitscomputed(p)
        computeimpliciteqs!(p)
    end
    n_implicits = sum(p.isimpliciteq)

    # initialize
    p.faces[k] = Vector{Vector{Int}}()
    
    proper_supsets = unique(
        # face of dimension one less plus a vertex not contained in it such that 
        # both are still contained in at least the minimum number of dimension minus k facets
        f[p.inc[v][f]] for v=1:nv, f in facesofdim(p, k-1)
        if !all(p.inc[v][f]) && sum(p.inc[v][f]) >= dim(p) - k + n_implicits
    )

    nondegenerate_supsets = [f for f in proper_supsets if length(f) == dim(p) - k + n_implicits]
    degenerate_supsets    = [f for f in proper_supsets if length(f) >  dim(p) - k + n_implicits]

    # find inclusion-maximal subsets among all subsets of facets found 
    # (some may be higher-dim faces contained in more than the minimum number of facets)
    for f in nondegenerate_supsets
        if !any(issubset(f, g) for g in degenerate_supsets)
            push!(p.faces[k], f)
        end
    end
    for f in degenerate_supsets
        if !any(issubset(f, g) for g in degenerate_supsets if length(g) > length(f))
            push!(p.faces[k], f)
        end
    end
end

"""
    facesofdim(p::Polytope, k::Int)

Return (an iterator over or a collection of) all faces of dimension `k` of the polytope `p`. Each face is given by a list of 
the indices of all tight inequalities.

Note here that the empty face ``\\emptyset`` (which is the unique face of dimension −1 by convention)
is given by the list of *all* inequality indices, as the intersection of all facets of a polytope is empty.

!!! note "Implementation note"
    The algorithm proceeds recursively and computes faces bottom-up, starting from the vertices.
    The results are cached internally in the `Polytope` object `p`. Therefore, 
    subsequent calls to `facesofdim(p, l)` for any ``l \\le k`` do not cost anything.

See also [`nfacesofdim`](@ref), [`dim`](@ref).
"""
function facesofdim(p::Polytope, k::Int)
    if !(-1 <= k <= ambientdim(p))
        # there is no face of dimension less than -1 or greater than the dimension of the ambient space
        return Vector{Int}()  # FIXME type-stability
    elseif k == -1  # empty face
        # here we use that the intersection of all facets of a polytope is empty
        return [collect(ineqindices(p))]  # FIXME type-stability
    elseif k == 0  # vertices
        return Iterators.map(v -> _tightinequalities(p, v), 1:nvertices(p))
    elseif k == 1  # edges
        return Iterators.map(e -> _tightinequalities(p, [Graphs.src(e), Graphs.dst(e)]), Graphs.edges(graph(p)))
    else
        if !facescomputed(p, k)
            computefacesofdim!(p, k)
        end
        # TODO implement iterator
        return (f for f in p.faces[k])  # same as Iterators.map(identity, ...)
    end
end


"""
    nfacesofdim(p::Polytope, k::Int)

Count the `k`-dimensional faces of the polytope `p`. 
Shorthand for `length(facesofdim(p, k))`.

See also [`nfacets`](@ref), [`facesofdim`](@ref), [`dim`](@ref).

# Examples
```jldoctest
julia> nfacesofdim.(cube(3), -1:3)
5-element Vector{Int64}:
  1
  8
 12
  6
  1
```
"""
nfacesofdim(p::Polytope, k::Int) = length(facesofdim(p, k))