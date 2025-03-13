# ================================
# Utility functions for plots and face analysis
# ================================

# check whether `g` is a cycle: if yes, list the vertices of `g` in cyclic order; if not, return nothing.
# the arguments are the return values of Graphs.induced_subgraph
# least index first in order
function cyclicorder(g::Graphs.SimpleGraph, vmap::Vector{Int})
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

# return cyclic indices u,v (arrow from u to v) together with Boolean flag that indicates 
# whether the direction is unique (False if edge and reference_edge are parallel)
function directedge(p::Polytope, edge::Union{Tuple{Int, Int}, AbstractVector{Int}}, facet::Int)
    u, v = edge  # TODO arg check

    # direction from u to v
    verts = collect(vertices(p))[[u,v]]
    r = verts[2] - verts[1]
    # index of first nonzero entry (exists since u and v are distinct)
    i = findfirst(@. !isapprox(r, 0))
    r ./= abs(r[i]) # normalize
    dotproduct = collect(Polyhedra.halfspaces(p.poly))[facet].a' * r  # FIXME non-public API?

    # check whether the vector r points away from or towards the halfspace (or is parallel to the hyperplane)
    if dotproduct == 0
        # parallel
        return (u,v), false  # arbitrary direction
    elseif dotproduct > 0
        # direction r points 'towards' the halfspace, so needs to be reversed
        return (v,u), true
    else
        # direction r already points away
        return (u,v), true
    end
end

# given two nonzero vectors x and y in dimension at least 2, find two coordinates
# such that the projections of x and y onto these coordinates
# are linearly independent if and only if x and y are linearly independent
function proj_onto_indices(x::Vector{<:Real}, y::Vector{<:Real})
    # implementation strategy: use Gaussian elimination

    # TODO assert nonzero

    # find first nonzero component (must exist since x is nonzero)
    i = findfirst(@. !isapprox(x, 0))  # TODO abs tol
    #i !== nothing || # TODO what to return for type stability?

    # perform a single Gauss step to eliminate component i of y
    # (note that the choice of i ensures that we do not divide by zero here)
    y_elim = y - x * y[i] / x[i]
    
    # find the first nonzero component of the resulting vector
    # note that entry i must be zero by construction
    @assert isapprox(y_elim[i], 0)
    j = findfirst(@. !isapprox(y_elim, 0))  # TODO
    # such a j must exist since x and y are linearly independent
    # now the 2x2 matrix induced by components i and j of x and y_elim is of the form [* *; 0 *] and has rank 2,
    # so projecting out all but i,j leaves projections of x and y_elim (and therefore y) linearly independent.
    i,j
end