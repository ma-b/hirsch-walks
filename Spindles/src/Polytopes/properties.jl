# ================================
# Special combinatorial properties
# ================================

# --------------------------------
# spindle apices
# --------------------------------

"""
    apices(p::Polytope [, apex::Int]; checkredund=true) 

Check whether `p` is a spindle, i.e., whether there is a pair of vertices (the *apices*) for which
each facet of `p` is incident to exactly one of them. If `p` has a pair of apices, return their indices;
otherwise return `nothing`.

The optional argument `apex` specifies the index of a vertex that is to be taken as one of the apices.

# Keywords
* `checkredund::Bool`: If `true` (default), first detect all inequalities in the description of `p` 
    that are not facet-defining for `p`. 
    If `p` was created from an inequality description that is known to be minimal, this step may be skipped
    by setting `checkredund` to `false`.

!!! note
    In the presence of redundant inequalities, disabling `checkredund` can only produce false negatives: 
    Whenever `apices` returns a pair of vertices, they are guaranteed to be apices of `p`. The converse, however,
    is not necessarily true. A spindle may not be detected as such if its inequality description contains
    inequalities that are not facet-defining.

# Examples

```jldoctest
julia> p = Polytope([1 0; 0 1; -1 0; 0 -1], [1, 1, 1, 1]);

julia> collect(vertices(p))
4-element Vector{Vector{Rational{BigInt}}}:
 [-1, -1]
 [1, -1]
 [-1, 1]
 [1, 1]

julia> apices(p)
2-element Vector{Int64}:
 1
 4

julia> apices(p, 2)
2-element Vector{Int64}:
 2
 3
```
"""
function apices(p::Polytope, apex::Union{Nothing, Int}=nothing; checkredund=true)
    if apex !== nothing && !isvertexindex(p, apex)
        throw(ArgumentError("indices must be between 1 and $(nvertices(p))"))
    end

    nv = nvertices(p)
    nf = nhalfspaces(p)

    if !inciscomputed(p)
        computeinc!(p)
    end

    # assuming that i and j are the indices of the apices that we want to find, their incidenct 
    # halfspaces/facets partition the set of all halfspaces excluding those that do not correspond to
    # facets (e.g., implicit equations or lower-dimensional faces)
    if checkredund
        nonfacet = codim.(p, 1:nf) .!= 1
    else
        if !implicitscomputed(p)
            computeimpliciteqs!(p)
        end
        nonfacet = p.isimpliciteq  # only filter out implicit equations
    end

    # incidences must be mutually exclusive except for non-facet defining inequalities, 
    # where incidence is arbitrary (may be both if implicit equation, or even none if they define empty face)
    isapexpair(i,j) = all((p.inc[i] .⊻ p.inc[j]) .| nonfacet)  # ⊻ bitwise XOR

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
    if !checkredund
        @warn """
        Cannot find a pair of apices. 
        This may be because all inequalities were assumed to define facets or implicit equations. 
        Try without checkredund=false if you do believe the polytope is a spindle$(apex !== nothing ? " with $apex as an apex" : "").
        """
    end
    return nothing
end

# --------------------------------
# simplicity and simpliciality
# --------------------------------

"""
    issimple(p::Polytope) -> Bool

Determine whether `p` is simple, i.e., whether each vertex of `p` is contained
in exactly `dim(p)` facets.

See also [`dim`](@ref), [`issimplicial`](@ref).

# Examples
````jldoctest
julia> issimple(simplex(3))
true

julia> issimple(cube(3))
true

julia> issimple(crosspolytope(3))
false
````
"""
function issimple(p::Polytope)
    if graphiscomputed(p)
        all(Graphs.degree(graph(p)) .== dim(p))
    else
        if !facetscomputed(p)
            computefacets!(p)
        end
        # (assuming dim is cached)
        # to make sure we don't overcount facets for which there are multiple defining inequalities in
        # the H-representation of `p`, we supply `init` to filter a minimal subset of inequalities
        all(v -> length(_incidenthalfspaces(p, [v]; init=p.isfacet)) == dim(p), 1:nvertices(p))
    end
end

"""
    issimplicial(p::Polytope) -> Bool

Determine whether `p` is simplicial, i.e., whether each facet of `p` is a simplex.

See also [`issimple`](@ref).

# Examples
````jldoctest
julia> issimplicial(simplex(3))
true

julia> issimplicial(cube(3))
false

julia> issimplicial(crosspolytope(3))
true
````
"""
function issimplicial(p::Polytope)
    if !inciscomputed(p)
        computeinc!(p)
    end

    # a d-face of a polytope is a simplex iff it has exactly d+1 vertices
    # (since each face of a simplex is a simplex again, we don't need to filter out non-facets)
    all(i -> length(_incidentvertices(p, i)) == dim(p, i) + 1, ineqindices(p))
end