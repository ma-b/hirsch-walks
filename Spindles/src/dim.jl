# ================================
# Dimension of faces
# ================================

export dim, codim

# Compute a maximal chain in the face lattice of `p` such that all faces only contain vertices in `vindices`,
# and the minimal face of the chain is the face defined by inequalities `f`.
# IMPORTANT: `f` must be the inclusion-maximal subset of halfspaces incident to the face because at each step 
#            of the chain, at least one halfspace index is dropped, and no new index enters.
#            This means that the length of the chain is at most length(f)+1. Fails, e.g., when `f ` only contains two disjoint facets.
function maxchain(p::Polytope, f::AbstractVector{Int}, vindices::AbstractVector{Int}=1:nvertices(p))
    # Implementation strategy is the same as for `facesofdim`:
    # We enumerate all faces that properly contain the current face `f`. Since we have a polytope,
    # each such face must contain all vertices of the current face plus (at least) one additional vertex 
    # that is not incident to the current face
    containing_faces = [
        f[p.inc[v][f]] for v in vindices if !all(p.inc[v][f])
    ]

    if isempty(containing_faces)
        # if all vertices are incident with `f`, we arrived at the (unique) maximal face, the polytope itself
        return [f]
    else
        # pick any subset of maximum cardinality (which must therefore also be inclusion-maximal)
        # among all subsets found
        nextf = argmax(length, containing_faces)
        return pushfirst!(maxchain(p, nextf, vindices), f)
    end
end

dimiscomputed(p::Polytope) = p.dim !== nothing
"""
    dim(p::Polytope)

Compute the dimension of `p`.

This is done by computing the length of a maximal chain in the face lattice of `p`,
i.e., a finite sequence of faces 
```math
\\emptyset = F_{-1} \\subsetneq F_0 \\subsetneq F_1 \\subsetneq \\dots \\subsetneq F_d
```
for which ``d`` is maximal among all such sequences. Then ``F_d`` must be `p` itself, and ``d`` is its dimension.

See also [`Polyhedra.dim`](https://juliapolyhedra.github.io/Polyhedra.jl/stable/redundancy/#Polyhedra.dim).

# Examples
```jldoctest
julia> p = Polytope([0 0; 1 0; 0 1; 1 1])
Polytope{Rational{BigInt}}

julia> dim(p)
2
```
"""
function dim(p::Polytope)
    if !dimiscomputed(p)
        p.dim = dim(p, Int[])
    end
    p.dim
end

"""
    dim(p::Polytope, indices)
    dim(p::Polytope, i::Int)

Compute the dimension of the face of `p` that is defined by the inequalities 
in the collection `indices`, or by the single inequality at index `i`.
If `indices` is empty, this is the same as `dim(p)`.

The implementation idea is the same as above except that the maximal face of the chain is the face
defined by `indices`.

See also [`codim`](@ref).

# Examples
```jldoctest
julia> p = Polytope([-1 0; 1 0; 0 -1; 0 1], [0, 1, 0, 1])
Polytope{Rational{BigInt}}

julia> dim(p, Int[])
2

julia> dim(p, 1)
1

julia> dim(p, [1, 3])
0

julia> dim(p, [1, 2])
-1
```
"""
function dim(p::Polytope, indices::AbstractVector{Int})
    all(isineqindex.(p, indices)) || throw(ArgumentError("inequality indices must be between 1 and $(nhalfspaces(p))"))

    if !inciscomputed(p)
        computeinc!(p)
    end

    # the maximal face in the chain will have the desired dimension, 
    # so subtract 2 for the (-1)-dim and 0-dim faces (if present)
    if isempty(indices)
        return length(maxchain(p, 1:nhalfspaces(p))) - 2
    else
        # here we use that the minimal face containing all incident vertices of a face is the face itself
        return length(maxchain(p, 1:nhalfspaces(p), _incidentvertices(p, indices))) - 2
    end
end
dim(p::Polytope, i::Int) = dim(p, [i])

"""
    codim(p::Polytope, indices)
    codim(p::Polytope, i::Int)

Compute the codimension `dim(p) - dim(p, indices)` of the face of `p` that is defined 
by the inequalities in `indices`, or by the single inequality at index `i`.

For the sake of consistency, 
the codimension of the empty face of a ``d``-dimensional polytope is defined as ``d+1``.
The implementation is complementary to [`dim`](@ref) and computes a maximal chain of faces
between the given face and `p` itself in the face lattice of `p`.

See also [`dim`](@ref).

# Examples
```jldoctest
julia> p = Polytope([-1 0; 1 0; 0 -1; 0 1], [0, 1, 0, 1])
Polytope{Rational{BigInt}}

julia> codim(p, Int[])
0

julia> codim(p, 1)
1

julia> codim(p, [1, 3])
2

julia> codim(p, [1, 2])
3
```
"""
function codim(p::Polytope, indices::AbstractVector{Int})
    all(isineqindex.(p, indices)) || throw(ArgumentError("inequality indices must be between 1 and $(nhalfspaces(p))"))

    if !inciscomputed(p)
        computeinc!(p)
    end

    # to correctly compute a chain of faces, we need to begin with all facets that contain the given face,
    # even if the face can be expressed as the intersection of a strict subset of those facets
    allindices = _incidenthalfspaces(p, _incidentvertices(p, indices))
    return length(maxchain(p, allindices)) - 1
end
codim(p::Polytope, i::Int) = codim(p, [i])