# ================================
# Faces
# ================================

export facesofdim, nfacesofdim, graph, dim, facets, nfacets, impliciteqs

# --------------------------------
# graph
# --------------------------------

graphiscomputed(p::Polytope) = p.graph !== nothing
"""
    graph(p::Polytope)

Return the graph of the polytope `p`, which is a simple undirected graph of type 
[`Graphs.SimpleGraphs.SimpleGraph`](https://juliagraphs.org/Graphs.jl/stable/core_functions/simplegraphs/#Graphs.SimpleGraphs.SimpleGraph).
"""
function graph(p::Polytope)
    if !graphiscomputed(p)
        computegraph!(p)
    end
    return p.graph
end

function computegraph!(p::Polytope)
    if !inciscomputed(p)
        computeinc!(p)
    end
    
    nv = nvertices(p)
    p.graph = Graphs.SimpleGraph(nv)

    # to enumerate all edges, we follow Christophe Weibel's approach outlined here:
    # https://sitep.google.com/site/christopheweibel/research/hirsch-conjecture    
    
    # (1) brute-force all pairs of vertices that are contained in at least dimension minus 1 common facets

    # we count the number of facets incident with both i and j as follows:
    n_inc(i::Int, j::Int) = sum(p.inc[i] .& p.inc[j])
    
    pairs = [
        ([i,j], n_inc(i,j)) for i=1:nv, j=1:nv 
        if i < j && n_inc(i,j) >= dim(p)-1
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

    nondegenerate_pairs = [e for (e,m) in pairs if m == dim(p)-1]
    degenerate_pairs  = [(e,m) for (e,m) in pairs if m > dim(p)-1]

    # we use this function to check inclusion-maximality:
    # return true if and only if each facet that contains all vertices in list `a` also contains all vertices in `b`
    iscontained(a::Vector{Int}, b::Vector{Int}) = all(reduce(.&, p.inc[a]) .<= reduce(.&, p.inc[b]))
    
    for e in nondegenerate_pairs
        if !any(iscontained(e, d) for (d,_) in degenerate_pairs)
            Graphs.add_edge!(p.graph, e...)
        end
    end
    for (d,m) in degenerate_pairs
        # strict superset must have strictly greater cardinality
        if !any(iscontained(d, dd) for (dd,mm) in degenerate_pairs if mm > m)
            Graphs.add_edge!(p.graph, d...)
        end
    end
end

# --------------------------------
# complete face enumeration
# --------------------------------

facescomputed(p::Polytope, k::Int) = haskey(p.faces, k)
function computefacesofdim!(p::Polytope, k::Int)
    if !inciscomputed(p)
        computeinc!(p)
    end
    
    nv = nvertices(p)

    # base cases: dimensions 0 and 1 (vertices and edges)
    if k == 0
        p.faces[0] = [incidentfacets(p, [v]) for v=1:nv]
    elseif k == 1
        # call more efficient edge enumeration routine
        # and compute sets of incident facets from adjacent vertex pairs returned by `edges`
        p.faces[1] = [incidentfacets(p, [Graphs.src(e), Graphs.dst(e)]) for e in Graphs.edges(graph(p))]
    else
        p.faces[k] = Vector{Vector{Int}}()

        # recurse and enumerate faces of one dimension lower
        lowerfaces = facesofdim(p, k-1)

        proper_supsets = unique(
            # face of dimension one less plus a vertex not contained in it such that 
            # both are still contained in sufficiently many facets
            f[p.inc[v][f]] for v=1:nv, f in lowerfaces
            if !all(p.inc[v][f]) && sum(p.inc[v][f]) >= dim(p)-k  
        )

        nondegenerate_supsets = [f for f in proper_supsets if length(f) == dim(p)-k]
        degenerate_supsets = [f for f in proper_supsets if length(f) > dim(p)-k]

        # find inclusion-maximal subsets among all subsets of facets found 
        # (some may be higher-dim faces contained in more than the minimum number of facets)
        
        iscontained(a::Vector{Int}, b::Vector{Int}) = all(i in b for i in a)

        for e in nondegenerate_supsets
            if !any(iscontained(e, d) for d in degenerate_supsets)
                push!(p.faces[k], e)
            end
        end
        for d in degenerate_supsets
            if !any(iscontained(d, dd) for dd in nondegenerate_supsets if length(dd) > length(d))
                push!(p.faces[k], d)
            end
        end
    end
end

"""
    facesofdim(p::Polytope, k::Int)

Enumerate all faces of dimension `k` of the polytope `p`. Each face is given by a list of the indices of its
incident halfspaces.

Note here that the empty face ``\\emptyset`` (which is the unique face of dimension -1 by convention)
is given by the list of *all* halfspace indices, as the intersection of all facets of a polytope is empty.

!!! warning "Difference from Polyhedra.jl"
    The index of a halfspace is the index of the corresponding inequality in the linear description
    of `p`, where (explicitly given) equality constraints (defining hyperplanes) are ignored. This is different from 
    [the way that indices are treated in Polyhedra.jl](https://juliapolyhedra.github.io/Polyhedra.jl/stable/polyhedron/#Incidence),
    where hyperplanes and halfspaces share the same set of indices.

!!! note
    The algorithm proceeds recursively and computes faces bottom-up, starting from the vertices.
    The results are cached internally in the `Polytope` object `p`. Therefore, 
    subsequent calls to `facesofdim(p, l)` for any ``l \\le k`` do not cost anything.

See also [`nfacesofdim`](@ref), [`dim`](@ref).
"""
function facesofdim(p::Polytope, k::Int)
    if !(-1 <= k <= size(Polyhedra.hrep(p.poly).A, 2))
        # there is no face of dimension less than -1 or greater than the dimension of the ambient space
        return Vector{Int}()
    elseif k == -1  # empty face
        # here we use that the intersection of all facets of a polytope is empty
        return [collect(1:nhalfspaces(p))]
    else
        if !facescomputed(p, k)
            computefacesofdim!(p, k)
        end
        return p.faces[k]
    end
end


"""
    nfacesofdim(p::Polytope, k::Int)

Count the `k`-dimensional faces of the polytope `p`. 
Shorthand for `length(facesofdim(p, k))`.

See also [`nfacets`](@ref), [`facesofdim`](@ref), [`dim`](@ref).

# Examples
```jldoctest
julia> V = [(i >> j) & 1 for i=0:7, j=0:2]
8×3 Matrix{Int64}:
 0  0  0
 1  0  0
 0  1  0
 1  1  0
 0  0  1
 1  0  1
 0  1  1
 1  1  1

julia> cube = Polytope(V);

julia> nfacesofdim.(cube, -1:3)
5-element Vector{Int64}:
  1
  8
 12
  6
  1
```
"""
nfacesofdim(p::Polytope, k::Int) = length(facesofdim(p, k))


# --------------------------------
# dimension
# --------------------------------

# Compute a maximal chain in the face lattice of `p` such that all faces only contain vertices in `vindices`,
# and the minimal face of the chain is the face defined by inequalities `f`.
# The implementation follows the same strategy as the face enumeration routine
function maxchain(p::Polytope, f::AbstractVector{Int}, vindices::AbstractVector{Int}=1:nvertices(p))
    # enumerate all faces that properly contain the current face `f`: since we have a polytope,
    # each such face must contain all vertices of the current face plus (at least) one additional vertex 
    # that is not incident to the current face
    containing_faces = [
        f[p.inc[v][f]] for v in vindices if !all(p.inc[v][f])
    ]

    if isempty(containing_faces)
        # if all vertices are incident with `f`, we arrived at the (unique) maximal face, the polytope itself
        return [f]
    else
        # pick any subset of maximum cardinality (which must therefore also be inclusion-maximal) among all subsets found
        nextf = containing_faces[findfirst(length.(containing_faces) .== maximum(length, containing_faces))]
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
for which `d` is maximal among all such sequences. Then ``F_d`` must be `p` itself, and `d` is its dimension.

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
    return p.dim
end

"""
    dim(p::Polytope, indices)

Compute the dimension of the face of `p` that is defined by the inequalities in `indices`.
If `indices` is empty, this is the same as `dim(p)`.
"""
function dim(p::Polytope, indices::AbstractVector{Int})
    if !all(isineq.(p, indices))
        throw(ArgumentError("inequality indices must be between 1 and $(nhalfspaces(p))"))
    end

    if !inciscomputed(p)
        computeinc!(p)
    end

    # here we use that the minimal facet containing all incident vertices of a face is the face itself

    # the maximal face in the chain will have the desired dimension, 
    # so subtract 2 for the (-1)-dim and 0-dim faces (if present)
    length(maxchain(p, 1:nhalfspaces(p), incidentvertices(p, indices))) - 2
end

"""
    dim(p::Polytope, i::Int)

Same as `dim(p, [i])`.

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
dim(p::Polytope, i::Int) = dim(p, [i])

"""
    facets(p::Polytope)

Return a minimal subset of inequality indices that contains one inequality for each facet of `p`.

If multiple inequalities in the description of `p` define the same facet,
the one with the smallest index is selected.

See also [`nfacets`](@ref), [`impliciteqs`](@ref).

# Examples

"""
function facets(p::Polytope)
    A = Polyhedra.hrep(p.poly).A
    b = Polyhedra.hrep(p.poly).b
    nf = nhalfspaces(p)

    # BitVector whose i-th entry indicates whether inequality i is facet-defining
    isfacet = dim.(p, 1:nf) .== dim(p)-1
    # keep track of inequalities whose deletion will leave an irredundant inequality description
    # their indices will be set to false in the following loop
    keep = trues(nf)

    for i=1:nf
        # continue if i is not a facet or has already been flagged as redundant
        isfacet[i] && keep[i] || continue
        
        for j=i+1:nf
            isfacet[j] || continue

            # find a column r of A such that A[j,r] is nonzero
            # and scale the row j such that this entry matches A[i,r] in absolute value
            r = findfirst(A[j,:] .!= 0)
            if A[i,r] == 0  # dismiss right away, since we would have to scale j by 0
                continue
            end
            α = abs(A[i,r]) / abs(A[j,r])

            # if the rescaled row j is now identical to row i, then i and j must define the same facet
            # (and the corresponding right-hand sides are necessarily identical too)
            if A[j,:] * α == A[i,:]
                @assert b[j] * α == b[i]
                keep[j] = false
            end  # (no j is considered twice)
        end
    end

    findall(isfacet .& keep)
end

"""
    nfacets(p::Polytope)

Count the facets of `p`. Shorthand for `length(facets(p))`.

See also [`nfacesofdim`](@ref), [`facets`](@ref).
"""
nfacets(p::Polytope) = length(facets(p))

"""
    impliciteqs(p::Polytope)

Return the indices of all inequalities that are implicit equations, i.e., that are satisfied at equality
for each point in `p`.

See also [`facets`](@ref).
"""
impliciteqs(p::Polytope) = [i for i=1:nhalfspaces(p) if dim(p, i) == dim(p)]
