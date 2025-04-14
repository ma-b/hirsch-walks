# ================================
# Graph distances
# ================================

distscomputed(p::Polytope, src::Int) = haskey(p.dists, src)
function computedistances!(p::Polytope, src::Int)
    # compute the length of shortest edge walks between the apices and all other vertices
    p.dists[src] = Graphs.dijkstra_shortest_paths(graph(p), src).dists
end

"""
    dist(p::Polytope, u::Int, v::Int)

Compute the distance between vertices `u` and `v` in the graph of `p`.

# Examples

```jldoctest
julia> p = Polytope([0 0; 0 1; 1 1; 1 0]);

julia> collect(vertices(p))
4-element Vector{Vector{Rational{BigInt}}}:
 [0, 0]
 [0, 1]
 [1, 1]
 [1, 0]

julia> dist(p, 1, 3)
2
```
"""
function dist(p::Polytope, u::Int, v::Int)
    u, v = sort([u,v])
    if u < 1 || v > nvertices(p)
        throw(ArgumentError("indices must be between 1 and $(nvertices(p))"))
    end
    
    if !distscomputed(p, u)
        computedistances!(p, u)
    end
    return p.dists[u][v]
end


# check whether `g` is a cycle: if yes, list the vertices of `g` in cyclic order; if not, return nothing.
# the arguments are the return values of Graphs.induced_subgraph
# least index first in order
function cyclicorder(g::Graphs.SimpleGraph, vmap::AbstractVector{Int})
    # pick an arbitrary starting vertex and traverse the graph g depth-first
    start = minimum(Graphs.vertices(g))  # least vertex index first
    cyclic = [start]

    v = start
    u = v  # will keep track of the predecessor of v throughout the following loop, initialize to v (arbitrary)
    it = 0  # number of iterations
    
    while (v != start || it == 0) && it < Graphs.nv(g)
        # find a neighbor of v distinct from u and append it to list
        nb_idx = findfirst(Graphs.neighbors(g, v) .!= u)
        nb = Graphs.neighbors(g, v)[nb_idx]
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