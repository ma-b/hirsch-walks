# TODO incorporate direction of shortcuts
struct FaceState
    good::Bool
    facets::Union{Nothing, Vector{Int}}
    edges::Union{Nothing, Tuple{Vector{Int}, Vector{Int}}}  # TODO create abstracttype for edge?
    vsubsets::Union{Nothing, Tuple{Vector{Int}, Vector{Int}}} # TODO

    # TODO perform checks on construction
end


# lists the vertices on the face in cyclic order
# using DFS=BFS here
function cyclicorder(adj::Dict)  # TODO type
    if !all(length.(values(adj)) .== 2)
        error("not a cycle")
    end

    # pick an arbitrary starting vertex
    v = first(keys(adj))
    u = v  # will keep track of the predecessor of v, initialize to v
    cyclic = [v]
    for count=1:length(keys(adj))
        # find neighbor of v distinct from u and append it to list
        nb = adj[v][1] != u ? adj[v][1] : adj[v][2]
        push!(cyclic, nb)
        u = v
        v = nb
    end

    # we know that graph of face must be a cycle  
    @assert cyclic[1] == cyclic[end]  # BUG may still work if adj defines two cycles of same length, then loop twice!!
    return cyclic[1:end-1]  # last element is starting vertex again
end


# return FaceState
function isgood2face(s::Spindle, facets::Vector{Int})
    nv = nvertices(s)

    #verticesinface = [v for v=1:nv if all(s.inc[v][facets])]
    #edgesinface = [e for e in edges(s) if all(reduce(.&, s.inc[e])[facets])]
    verticesinface = collect(incidentvertices(s, facets))  # or collect only below?
    face_subgraph, vmap = induced_subgraph(s.graph, verticesinface)  # more efficient!
    edgesinface = [(vmap[src(e)], vmap[dst(e)]) for e in Graphs.edges(face_subgraph)]    
    n = length(verticesinface)

    # first, check simple necessary conditions:
    # (1) good faces must have at least 6 vertices
    # (2) good faces must be 2-faces, i.e., their graph is a cycle with all node degrees equal to 2
    # TODO equivalent?
    n >= 6 && length(edgesinface) == n || return FaceState(false, nothing, nothing, nothing)
    
    # we avoid building the graph using Graphs package...
    # TODO compare @time Graphs.induced_subgraph
    # and instead build adjacency list, probably not much more expensive than building a high-level graph?
    # or try adj matrix? sum over row/col must be 2 everywhere
    adj = Dict(v => [] for v in verticesinface)
    for (u,v) in edgesinface
        push!(adj[u],v)
        push!(adj[v],u)
    end

    # for each vertex (key), the list of neighbors (values) must have length 2
    all(length.(values(adj)) .== 2) || return FaceState(false, nothing, nothing, nothing)

    # (3) shortest edge walks to and from the face must have total length <= k-2
    dists_to_apex = [bellman_ford_shortest_paths(s.graph, a).dists for a in apices(s)]
    # TODO cache distances!

    #@show sum(map(d -> minimum(d.dists[verticesinface]), dists_to_apex))
    if sum(map(d -> minimum(d[verticesinface]), dists_to_apex)) > dim(s)-2  # TODO debug
        return FaceState(false, nothing, nothing, nothing)
    end

    # Now that all preliminary checks have been successful, we check the face for being good as follows:
    # 'good' means that there are connected subsets of vertices vertices_plus and _minus
    # such that there are exactly two edges with no endpoints in these sets. TODO necessary cond.
    # So we may enumerate all possible subsets of vertices by checking pairs of edges.

    # first list the vertices on the face in cyclic order
    cyclic = cyclicorder(adj)
    
    # enumerate pairs of edges that may work: tuples (i,j) where i and j are positions of vertices along the cyclic ordering
    # and the corresponding edges are i,i+1 and j,j+1 (indices wrap around)
    # (i,j) must allow for at least one vertex in between i+1 and j and between j+1 and i:

    for i=1:n, j=i+1:n  # invariant i<j
        if mod(i-j, n) >= 3 && mod(j-i, n) >= 3
            vertices_plus = i+2:j-1   # TODO naming suggest V^\pm when it has nothing do with it!!!
            vertices_minus = [j+2:n; max(1,j+2-n):i-1]
            #println(n, " ", (i,j), "\t", vertices_plus," ", vertices_minus)
            
            # both sets of vertices are connected, and they must be nonempty:
            @assert length(vertices_plus) * length(vertices_minus) > 0

            # vertices_plus and _minus witness being 'good' if for each vertex in _plus and each vertex in _minus,
            # their distances to opposite apices are at most d-2

            # maximum distance of a vertex in _plus (or _minus, resp.) to each apex (lists with 2 entries each)
            max_dists_plus  = map(d -> maximum(d[cyclic[vertices_plus]]),  dists_to_apex)
            max_dists_minus = map(d -> maximum(d[cyclic[vertices_minus]]), dists_to_apex)

            #@show max_dists_plus, max_dists_minus

            if min(max_dists_plus[1] + max_dists_minus[2], max_dists_plus[2] + max_dists_minus[1]) <= dim(s)-2
                #println("good: ", (i,j), " ", (cyclic[i:i+1], cyclic[[j,mod(j,n)+1]]))  
                # mod(j,n)+1 test!!! j is 1-based index
                fstate = FaceState(
                    true, facets, (cyclic[i:i+1], cyclic[[j,mod(j,n)+1]]), 
                    (cyclic[vertices_plus], cyclic[vertices_minus])  
                )
                return fstate
            end
        end
    end

    # no successful pair (i,j) found
    return FaceState(false, nothing, nothing, nothing)
end


