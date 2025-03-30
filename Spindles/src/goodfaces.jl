"""
    FaceState

# Fields
* `good::Bool`
* `indices`: indices of all incident halfspaces
* `edges`
* `vsets`
"""
struct FaceState
    good::Bool
    indices::Union{Nothing, Vector{Int}}
    edges::Union{Nothing, Tuple{Vector{Int}, Vector{Int}}}
    vsets::Union{Nothing, Tuple{Vector{Int}, Vector{Int}}}
end

"""
    isgood2face(p::Polytope, indices, src, dst)

Test the face defined by `indices` for being a *good* 2-face of the polytope `p`
with respect to the two vertices `src` and `dst`.
Return a [`FaceState`](@ref).

See [this tutorial](@ref "Spindles and the Hirsch conjecture I") for an informal explanation of what
it means for a 2-face to be good.
"""
function isgood2face(p::Polytope, indices::AbstractVector{Int}, src::Int, dst::Int)
    verticesinface = incidentvertices(p, indices)
    n = length(verticesinface)

    # first, check simple necessary conditions to speed up computations:
    
    # (1) good faces must have at least 6 vertices
    n >= 6 || return FaceState(false, nothing, nothing, nothing)

    # (2) good faces must be 2-faces, i.e., their graph is a cycle
    # to check this, list the vertices in cyclic order around the face
    cyclic = Polytopes.cyclicorder(Graphs.induced_subgraph(graph(p), verticesinface)...)
    cyclic !== nothing || return FaceState(false, nothing, nothing, nothing)

    # (3) shortest edge walks to and from the face must have total length <= dim-2
    dists_by_src = [dist.(p, a, verticesinface) for a in [src,dst]] 
    if sum(map(minimum, dists_by_src)) > dim(p)-2
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
            max_dists_plus  = [maximum(dist.(p, a, cyclic[vertices_plus])) for a in [src,dst]]
            max_dists_minus = [maximum(dist.(p, a, cyclic[vertices_minus])) for a in [src,dst]] 

            # translate the cyclic indices of the endpoints of the two edges back to their actual vertex indices
            # note here that [j,j+1] may wrap around
            edges = (cyclic[i:i+1], cyclic[[j, mod(j,n)+1]])

            if max_dists_plus[1] + max_dists_minus[2] <= dim(p)-2
                return FaceState(
                    # here we do not use `indices` but recompute the incident facets to catch all of them
                    true, incidenthalfspaces(p, verticesinface), edges, 
                    (cyclic[vertices_plus], cyclic[vertices_minus])  # "plus" is closer to 1
                )
            elseif max_dists_minus[1] + max_dists_plus[2] <= dim(p)-2
                return FaceState(
                    true, incidenthalfspaces(p, verticesinface), edges, 
                    (cyclic[vertices_minus], cyclic[vertices_plus])   # "minus" is closer to 1
                )
            end
        end
    end

    # no successful pair (i,j) found
    return FaceState(false, nothing, nothing, nothing)
end