# ================================
#  ...
# ================================

export apices, vertices, nvertices, nhalfspaces, incidentvertices, incidentfacets

"""
    vertices(p::Polytope)

Returns an iterator over the vertices of the polytope `p`.
"""
vertices(p::Polytope) = Polyhedra.points(p.poly)

"""
    nvertices(p::Polytope)

Count the vertices of `p`.
"""
nvertices(p::Polytope) = Polyhedra.npoints(p.poly)
isvertex(p::Polytope, v::Int) = 1 <= v <= nvertices(p)

# convenient shorthands for index checks
nhalfspaces(p::Polytope) = Polyhedra.nhalfspaces(p.poly)
isineq(p::Polytope, i::Int) = 1 <= i <= nhalfspaces(p)

# --------------------------------
# vertex-halfspace incidences
# --------------------------------

inciscomputed(p::Polytope) = p.inc !== nothing
function computeinc!(p::Polytope)
    p.inc = Vector{BitVector}(undef, nvertices(p))

    nh = Polyhedra.nhyperplanes(p.poly)
    nf = Polyhedra.nhalfspaces(p.poly)

    for v in eachindex(vertices(p))
        p.inc[v.value] = falses(nf)
        for f in Polyhedra.incidenthalfspaceindices(p.poly, v)
            # the hyperplanes and halfspaces of p.poly are numbered consecutively (in this order),
            # so we use the number of hyperplanes as a hacky offset here
            p.inc[v.value][f.value - nh] = true
        end
    end
end

"""
    incidentvertices(p::Polytope, indices::AbstractVector{Int})

List the indices of all vertices of the polytope `p` for which each inequality in `indices` is tight.

If `indices` is empty, this is the same as `collect(1:nvertices(p))`.
"""
function incidentvertices(p::Polytope, indices::AbstractVector{Int})
    if !all(isineq.(p, indices))
        throw(ArgumentError("inequality indices must be between 1 and $(nhalfspaces(p))"))
    end
    
    if !inciscomputed(p)
        computeinc!(p)
    end
    [v for v=1:nvertices(p) if all(p.inc[v][indices])]
end

function incidentfacets(p::Polytope, indices::AbstractVector{Int})
    if !all(isvertex.(p, indices))
        throw(ArgumentError("vertex indices must be between 1 and $(nvertices(p))"))
    end

    if !isempty(indices)
        if !inciscomputed(p)
            computeinc!(p)
        end
        return findall(reduce(.&, p.inc[indices]))
    else
        return Int[]
    end
end

# --------------------------------
# spindle apices
# --------------------------------

"""
    apices(p::Polytope [, apex]) 

Check whether `p` is a spindle, i.e., if there is a pair of vertices (the *apices*) for which
each facet of `p` is incident to exactly one of them. If `p` has a pair of apices, return their indices;
otherwise return `nothing`.

The optional argument `apex` specifies the index of a vertex that is to be taken as one of the apices.

# Examples

```jldoctest
julia> square = Polytope([1 0; 0 1; -1 0; 0 -1], [1, 1, 1, 1]);

julia> vertices(square)
4-element iterator of Vector{Rational{BigInt}}:
 Rational{BigInt}[-1, -1]
 Rational{BigInt}[1, -1]
 Rational{BigInt}[-1, 1]
 Rational{BigInt}[1, 1]

julia> apices(square)
2-element Vector{Int64}:
 1
 4

julia> apices(square, 2)
2-element Vector{Int64}:
 2
 3
```
"""
function apices(p::Polytope, apex::Union{Nothing, Int}=nothing)
    if apex !== nothing && !isvertex(p, apex)
        throw(ArgumentError("vertex indices must be between 1 and $(nvertices(p))"))
    end

    nv = nvertices(p)
    nf = nhalfspaces(p)

    if !inciscomputed(p)
        computeinc!(p)
    end

    # assuming that i and j are the indices of the apices that we want to find, their incidenct 
    # halfspaces/facets partition the set of all halfspaces excluding those that do not correspond to
    # facets (e.g., implicit equations or lower-dimensional faces)
    nonfacet = dim.(p, 1:nf) .!= dim(p)-1

    # incidences must be mutually exclusive except for non-facet defining inequalities, 
    # where incidence is arbitrary (may be both if implicit equation, or even none if they define empty face)
    isapexpair(i,j) = all((p.inc[i] .⊻ p.inc[j]) .| nonfacet)  # bitwise XOR

    # in particular, the number of incident facets of j must be at least 
    # nf - sum(p.inc[i]) >= nf - sum(nonfacet) - maxinc, 
    # where maxinc is the maximum number of incident halfspaces across all vertices:
    #maxinc = maximum(sum, p.inc)

    # we use this fact to perform a pre-check in the following algorithm
    # and discard vertices with too few incident facets

    # given i, finds j such that (i,j) are a valid pair of apices
    # if onlygreater is set to `true`, then consider j > i only
    function findsecondapex(i::Int, onlygreater::Bool)
        issecondapex(j) = (!onlygreater || j > i) && i != j && 
            #sum(p.inc[j]) + maxinc >= nf && 
            isapexpair(i,j)
        findfirst(issecondapex, 1:nv)
    end

    # brute-force all possible apex pairs and stop on finding the first valid pair

    if apex !== nothing
        j = findsecondapex(apex, false)
        if j !== nothing
            return sort([apex,j])
        end
    else
        for i=1:nv
            #if sum(p.inc[i]) + maxinc < nf
            #    # too few incident halfspaces
            #    continue
            #end
            j = findsecondapex(i, true)
            if j !== nothing
                return [i,j]
            end
        end
    end

    # no apex pair found
    return nothing
end