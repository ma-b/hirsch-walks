export isgood2face, dist

# TODO incorporate direction of shortcuts
"""
    FaceState

# Fields
* `good::Bool`
* `facets`: all incident facets
* `edges`
* `vsets`
"""
struct FaceState
    good::Bool
    facets::Union{Nothing, Vector{Int}}
    edges::Union{Nothing, Tuple{Vector{Int}, Vector{Int}}}
    vsets::Union{Nothing, Tuple{Vector{Int}, Vector{Int}}}

    # TODO perform checks on construction
end

distscomputed(s::Spindle) = s.dists !== nothing
function computedistances!(s::Spindle)
    # use the Bellman-Ford algorithm implemented in Graphs.jl
    # to compute the length of shortest edge walks between the apices and all other vertices
    s.dists = Dict(a => bellman_ford_shortest_paths(graph(s), a).dists for a in apices(s))
end

"""
    dist(s::Spindle, apex::Int, v::Int)

Compute the distance between `apex` and vertex `v` in the graph of spindle `s`.

!!! note

    Results are affected by resetting the apices with [`setapex!`](@ref).

# Examples

```jldoctest
julia> square = Spindle([1 0; 0 1; -1 0; 0 -1], [1, 1, 1, 1]);

julia> apx1, apx2 = setapex!(square, 1)
2-element Vector{Int64}:
 1
 4

julia> dist(square, apx1, 4)
2

julia> apx1, apx2 = setapex!(square, 2)
2-element Vector{Int64}:
 2
 3

julia> dist(square, apx1, 4)
1
```
"""
function dist(s::Spindle, apex::Int, v::Int)
    apex in apices(s) || throw(ArgumentError("$(apex) is not an apex"))
    1 <= v <= nvertices(s) || throw(ArgumentError("index $(v) out of bounds for $(nvertices(s)) vertices"))
    
    if !distscomputed(s) || !haskey(s.dists, apex)  # recompute distances also when apices have changed in the meantime
        computedistances!(s)
    end

    return s.dists[apex][v]
end

# arguments as returned by induced subgraph; return nothing if not a cycle
function cyclicorder(g::SimpleGraph, vmap::Vector{Int})
    # pick an arbitrary starting vertex and traverse the graph g depth-first
    start = first(Graphs.vertices(g))
    cyclic = [start]

    v = start
    u = v  # will keep track of the predecessor of v throughout the following loop, initialize to v (arbitrary)
    it = 0  # number of iterations
    
    while (v != start || it == 0) && it < Graphs.nv(g)
        # find a neighbor of v distinct from u and append it to list
        nb_idx = findfirst(neighbors(g, v) .!= u)
        nb = neighbors(g, v)[nb_idx]
        push!(cyclic, nb)

        u = v
        v = nb
        it += 1
    end

    # for g to be a cycle, we must have traversed all vertices of g
    if it < Graphs.nv(g)
        return
    end
    
    # map vertex indices back to vertices of the original graph
    return vmap[cyclic[1:end-1]]  # last element is starting vertex again
end


"""
    isgood2face(s::Spindle, facets)

Test the face defined by `facets` for being a *good* 2-face of the spindle `s`.
Return a [`FaceState`](@ref).

See [this tutorial](@ref "Good 2-faces") for an informal explanation of what
it means for a 2-face to be good.
"""
function isgood2face(s::Spindle, facets::Vector{Int})
    verticesinface = incidentvertices(s, facets)
    n = length(verticesinface)

    # first, check simple necessary conditions to speed up computations:
    
    # (1) good faces must have at least 6 vertices
    n >= 6 || return FaceState(false, nothing, nothing, nothing)

    # (2) good faces must be 2-faces, i.e., their graph is a cycle
    # to check this, list the vertices in cyclic order around the face
    cyclic = cyclicorder(induced_subgraph(graph(s), verticesinface)...)
    cyclic !== nothing || return FaceState(false, nothing, nothing, nothing)

    # (3) shortest edge walks to and from the face must have total length <= dim-2
    dists_by_apex = [[dist(s, a, v) for v in verticesinface] for a in apices(s)]
    if sum(map(minimum, dists_by_apex)) > dim(s)-2
        return FaceState(false, nothing, nothing, nothing)
    end

    # now that all preliminary checks have been successful, we may check the face for being good 
    # by enumerating all pairs of edges that partition the remaining vertices into nonempty "shores"
    # at the right distance from the apices
    
    # enumerate pairs of edges that may work: tuples (i,j) where i and j are positions of vertices along the cyclic ordering
    # and the corresponding edges are i,i+1 and j,j+1 (indices wrap around)
    # (i,j) must allow for at least one vertex in between i+1 and j and between j+1 and i:

    for i=1:n, j=i+1:n
        if mod(i-j, n) >= 3 && mod(j-i, n) >= 3
            vertices_plus = i+2:j-1   # TODO naming suggests V^\pm when it has nothing do with it
            vertices_minus = [j+2:n; max(1,j+2-n):i-1]
            
            # both sets of vertices are connected, and they must be nonempty:
            @assert !isempty(vertices_plus) && !isempty(vertices_minus)

            # vertices_plus and _minus witness being 'good' if for each vertex in _plus and each vertex in _minus,
            # their distances to opposite apices are at most d-2

            # maximum distance of a vertex in _plus (or _minus, resp.) to each apex (lists with 2 entries each)
            max_dists_plus  = [maximum([dist(s, a, cyclic[vp]) for vp in vertices_plus]) for a in apices(s)]
            max_dists_minus = [maximum([dist(s, a, cyclic[vm]) for vm in vertices_minus]) for a in apices(s)] 

            # translate the cyclic indices of the endpoints of the two edges back to their actual vertex indices
            # note here that [j,j+1] may wrap around
            edges = (cyclic[i:i+1], cyclic[[j, mod(j,n)+1]])

            if max_dists_plus[1] + max_dists_minus[2] <= dim(s)-2
                return FaceState(
                    true, facets, edges, 
                    (cyclic[vertices_plus], cyclic[vertices_minus])  # "plus" is closer to 1
                )
            elseif max_dists_minus[1] + max_dists_plus[2] <= dim(s)-2
                return FaceState(
                    true, facets, edges, 
                    (cyclic[vertices_minus], cyclic[vertices_plus])   # "minus" is closer to 1
                )
            end
        end
    end

    # no successful pair (i,j) found
    return FaceState(false, nothing, nothing, nothing)
end


