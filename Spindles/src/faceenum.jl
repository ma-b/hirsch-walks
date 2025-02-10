export facesofdim, nfacesofdim, graph

graphiscomputed(s::Spindle) = s.graph !== nothing
"""
    graph(s)

Return a [`Graphs.SimpleGraphs.SimpleGraph`](https://juliagraphs.org/Graphs.jl/stable/core_functions/simplegraphs/#Graphs.SimpleGraphs.SimpleGraph)
"""
function graph(s::Spindle, stopatvertex::Union{Nothing, Int}=nothing)
    if !graphiscomputed(s)
        computegraph!(s, stopatvertex)
    end
    return s.graph
end

function computegraph!(s::Spindle, stopatvertex::Union{Nothing, Int}=nothing)
    if !inciscomputed(s)
        computeinc!(s)
    end
    
    nv = stopatvertex === nothing ? nvertices(s) : min(stopatvertex, nvertices(s))
    s.graph = Graph(nv)  # TODO SimpleGraph(nv)

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

    # For near-simple polytopes, the task of checking for inclusion-maximality can be sped up be splitting the list of possibly
    # adjacent pairs i,j into those that are contained in exactly dimension minus 1 facets and those that are contained in more:
    # most pairs will be of the first type, and inclusion among their sets of common facets does not have to be checked 
    # because they are all distinct and of the same size.

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

#=function edges(s::Spindle, stopatvertex::Union{Nothing, Int}=nothing)
    ([src(e), dst(e)] for e in Graphs.edges(graph(s, stopatvertex)))
end=#


facescomputed(s::Spindle, k::Int) = haskey(s.faces, k) #&& s.faces[k] !== nothing
function computefacesofdim!(s::Spindle, k::Int, stopatvertex::Union{Nothing, Int}=nothing)
    if !inciscomputed(s)
        computeinc!(s)
    end
    
    nv = stopatvertex === nothing ? nvertices(s) : min(stopatvertex, nvertices(s))    

    # base cases: dimensions 0 and 1 (vertices and edges)
    if k == 0
        s.faces[0] = [findall(s.inc[v]) for v=1:nv]
    elseif k == 1
        # call more efficient edge enumeration routine
        # and compute sets of incident facets from adjacent vertex pairs returned by `edges`
        s.faces[1] = [findall(s.inc[src(e)] .& s.inc[dst(e)]) for e in Graphs.edges(graph(s, stopatvertex))]
        #s.faces[1] = [findall(reduce(.&, s.inc[e])) for e in edges(s)]
    else
        s.faces[k] = Vector{Vector{Int}}()

        # recurse and enumerate faces of one dimension lower
        lowerfaces = facesofdim(s, k-1, nv)

        # TODO rename pairs
        pairs = unique(
            # face of dimension one less plus a vertex not contained in it such that both are still contained in sufficiently many facets
            f[s.inc[v][f]] for v=1:nv, f in lowerfaces
            if !all(s.inc[v][f]) && sum(s.inc[v][f]) >= dim(s)-k  
        )

        nondegenerate_pairs = [f for f in pairs if length(f) == dim(s)-k]
        degenerate_pairs = [f for f in pairs if length(f) > dim(s)-k]

        # find inclusion-maximal subsets among all subsets of facets found 
        # (some may be higher-dim faces contained in more than the minimum number of facets)
        
        iscontained(a::Vector{Int}, b::Vector{Int}) = all(i in b for i in a)

        for e in nondegenerate_pairs
            if !any(iscontained(e, d) for d in degenerate_pairs)
                push!(s.faces[k], e)
            end
        end
        for d in degenerate_pairs
            if !any(iscontained(d, dd) for dd in nondegenerate_pairs if length(dd) > length(d))
                push!(s.faces[k], d)
            end
        end
    end
end

"""
    facesofdim(s, k)

Enumerate all faces of dimension `k` of the spindle `s`, each one given by a vector containing the indices of all 
incident halfspaces/facets (starting at 1). Return them in one vector.

!!! note

    difference from `Polyhedra.Index`

Recursive bottom-up computation. Most (memory-)efficient for near-simple polytopes, for which faces are contained
in few facets each.
"""
function facesofdim(s::Spindle, k::Int, stopatvertex::Union{Nothing, Int}=nothing)
    if !(-1 <= k <= size(Polyhedra.hrep(s.p).A, 2))
        # there is no face of dimension less than -1 or greater than the dimension of the ambient space
        return Vector{Int}()
    elseif k == -1  # empty face
        # here we use that the intersection of all facets of a polytope is empty
        return [collect(1:nhalfspaces(s))]
    else
        if !facescomputed(s, k)
            computefacesofdim!(s, k, stopatvertex)
        end
        return s.faces[k]
    end
end


"""
    nfacesofdim(s, k)

Count the `k`-dimensional faces of the spindle `s`. ... Equivalent with `length(facesofdim(s, k))` if not nothing.
Uses the convention that the dimension of the empty face is -1.
"""
nfacesofdim(s::Spindle, k::Int) = length(facesofdim(s, k)) #facesofdim(s, k) !== nothing ? length(facesofdim(s, k)) : 0