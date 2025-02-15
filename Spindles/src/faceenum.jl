# ================================
# Faces
# ================================

export facesofdim, nfacesofdim, graph, dim

# --------------------------------
# graph
# --------------------------------

graphiscomputed(s::Spindle) = s.graph !== nothing
"""
    graph(s::Spindle)

Return the graph (aka *1-skeleton*) of `s`, which is a simple undirected graph of type 
[`Graphs.SimpleGraphs.SimpleGraph`](https://juliagraphs.org/Graphs.jl/stable/core_functions/simplegraphs/#Graphs.SimpleGraphs.SimpleGraph).
"""
function graph(s::Spindle)
    if !graphiscomputed(s)
        computegraph!(s)
    end
    return s.graph
end

function computegraph!(s::Spindle)
    if !inciscomputed(s)
        computeinc!(s)
    end
    
    nv = nvertices(s)
    s.graph = SimpleGraph(nv)

    # to enumerate all edges, we follow Christophe Weibel's approach outlined here:
    # https://sites.google.com/site/christopheweibel/research/hirsch-conjecture    
    
    # (1) brute-force all pairs of vertices that are contained in at least dimension minus 1 common facets

    # we count the number of facets incident with both i and j as follows:
    n_inc(i::Int, j::Int) = sum(s.inc[i] .& s.inc[j])
    
    pairs = [
        ([i,j], n_inc(i,j)) for i=1:nv, j=1:nv 
        if i < j && n_inc(i,j) >= dim(s)-1
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

    nondegenerate_pairs = [e for (e,m) in pairs if m == dim(s)-1]
    degenerate_pairs  = [(e,m) for (e,m) in pairs if m > dim(s)-1]

    # we use this function to check inclusion-maximality:
    # return true if and only if each facet that contains all vertices in list `a` also contains all vertices in `b`
    iscontained(a::Vector{Int}, b::Vector{Int}) = all(reduce(.&, s.inc[a]) .<= reduce(.&, s.inc[b]))
    
    for e in nondegenerate_pairs
        if !any(iscontained(e, d) for (d,_) in degenerate_pairs)
            add_edge!(s.graph, e...)
        end
    end
    for (d,m) in degenerate_pairs
        # strict superset must have strictly greater cardinality
        if !any(iscontained(d, dd) for (dd,mm) in degenerate_pairs if mm > m)
            add_edge!(s.graph, d...)
        end
    end
end

# --------------------------------
# complete face enumeration
# --------------------------------

facescomputed(s::Spindle, k::Int) = haskey(s.faces, k)
function computefacesofdim!(s::Spindle, k::Int)
    if !inciscomputed(s)
        computeinc!(s)
    end
    
    nv = nvertices(s)

    # base cases: dimensions 0 and 1 (vertices and edges)
    if k == 0
        s.faces[0] = [incidentfacets(s, [v]) for v=1:nv]
    elseif k == 1
        # call more efficient edge enumeration routine
        # and compute sets of incident facets from adjacent vertex pairs returned by `edges`
        s.faces[1] = [incidentfacets(s, [src(e), dst(e)]) for e in Graphs.edges(graph(s))]
    else
        s.faces[k] = Vector{Vector{Int}}()

        # recurse and enumerate faces of one dimension lower
        lowerfaces = facesofdim(s, k-1)

        proper_supsets = unique(
            # face of dimension one less plus a vertex not contained in it such that 
            # both are still contained in sufficiently many facets
            f[s.inc[v][f]] for v=1:nv, f in lowerfaces
            if !all(s.inc[v][f]) && sum(s.inc[v][f]) >= dim(s)-k  
        )

        nondegenerate_supsets = [f for f in proper_supsets if length(f) == dim(s)-k]
        degenerate_supsets = [f for f in proper_supsets if length(f) > dim(s)-k]

        # find inclusion-maximal subsets among all subsets of facets found 
        # (some may be higher-dim faces contained in more than the minimum number of facets)
        
        iscontained(a::Vector{Int}, b::Vector{Int}) = all(i in b for i in a)

        for e in nondegenerate_supsets
            if !any(iscontained(e, d) for d in degenerate_supsets)
                push!(s.faces[k], e)
            end
        end
        for d in degenerate_supsets
            if !any(iscontained(d, dd) for dd in nondegenerate_supsets if length(dd) > length(d))
                push!(s.faces[k], d)
            end
        end
    end
end

"""
    facesofdim(s::Spindle, k::Int)

Enumerate all faces of dimension `k` of the spindle `s`. Each face is given by a list of the indices of its
incident halfspaces/facets.

!!! note
    The empty face ``\\emptyset`` (which is the unique face of dimension -1 by convention)
    is given by the list of *all* facet/halfspace indices, as the intersection of all facets of a polytope is empty.

!!! warning "Difference to Polyhedra.jl"
    The index of a halfspace/facet is its index in the collection of halfspaces of the polyhedron underlying `s`,
    where hyperplanes are ignored. This is different from 
    [the way that indices are treated in `Polyhedra`](https://juliapolyhedra.github.io/Polyhedra.jl/stable/polyhedron/#Incidence),
    where hyperplanes and halfspaces share the same set of indices.

The algorithm proceeds recursively and computes faces bottom-up, starting from the vertices. 

!!! note
    Results are cached internally in the `Spindle` object `s`. Therefore, subsequent calls to `facesofdim(s, l)`
    for any ``l \\le k`` do not cost anything.

See also [`nfacesofdim`](@ref).
"""
function facesofdim(s::Spindle, k::Int)
    if !(-1 <= k <= size(Polyhedra.hrep(s.p).A, 2))
        # there is no face of dimension less than -1 or greater than the dimension of the ambient space
        return Vector{Int}()
    elseif k == -1  # empty face
        # here we use that the intersection of all facets of a polytope is empty
        return [collect(1:nhalfspaces(s))]
    else
        if !facescomputed(s, k)
            computefacesofdim!(s, k)
        end
        return s.faces[k]
    end
end


"""
    nfacesofdim(s::Spindle, k::Int)

Count the `k`-dimensional faces of the spindle `s`. 
Shorthand for `length(facesofdim(s, k))`.

See also [`facesofdim`](@ref).
"""
nfacesofdim(s::Spindle, k::Int) = length(facesofdim(s, k))


# --------------------------------
# dimension
# --------------------------------

# compute a maximal chain in the face poset of `s`, starting from `f`
# our implementation follows the same idea as the face enumeration routine
function maxchain(s::Spindle, f::Vector{Int})
    nv = nvertices(s)

    # enumerate all faces that properly contain the current face `f`: since we have a polytope,
    # each such face must contain all vertices of the current face plus (at least) one additional vertex 
    # which is not incident to some of the incident halfspaces of `f`
    containing_faces = [
        f[s.inc[v][f]] for v=1:nv if !all(s.inc[v][f])
    ]

    if isempty(containing_faces)
        # if all vertices are incident with `f`, we arrived at the (unique) maximal face, the polytope itself
        return [f]
    else
        # pick any subset of maximum cardinality (which must therefore also be inclusion-maximal) among all subsets found
        nextf = containing_faces[findfirst(length.(containing_faces) .== maximum(length, containing_faces))]
        return pushfirst!(maxchain(s, nextf), f)
    end
end
# same as above except that the initial face is the empty face (of dim -1), 
# which for a polytope is the intersection of all facets
maxchain(s::Spindle) = maxchain(s, collect(1:nhalfspaces(s)))

dimiscomputed(s::Spindle) = s.dim !== nothing
function computedim!(s::Spindle)
    # the maximal face in the chain will have the desired dimension, so subtract 2 for the (-1)-dim and 0-dim faces
    s.dim = length(maxchain(s)) - 2
end

"""
    dim(s::Spindle)

Compute the dimension of the spindle `s`.

This is done by computing the length of a maximal chain in the face poset of `s`,
i.e., a finite sequence of faces 
```math
\\emptyset = F_{-1} \\subsetneq F_0 \\subsetneq F_1 \\subsetneq \\dots \\subsetneq F_d
```
for which `d` is maximal among all such sequences. Then ``F_d`` must be `s` itself, and `d` is its dimension.

See also [`Polyhedra.dim`](https://juliapolyhedra.github.io/Polyhedra.jl/stable/redundancy/#Polyhedra.dim).
"""
function dim(s::Spindle)
    if !dimiscomputed(s)
        computedim!(s)
    end
    return s.dim
end