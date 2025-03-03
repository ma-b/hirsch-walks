# ================================
# Redundancy detection
# ================================

export facets, nfacets, impliciteqs

"""
    facets(p::Polytope)

Return a minimal subset of inequality indices that contains one inequality for each facet of `p`.

If multiple inequalities in the description of `p` define the same facet,
the one with the smallest index is selected.

See also [`nfacets`](@ref), [`impliciteqs`](@ref).

# Examples
````jldoctest
julia> A = [-1 0; 1 1; 2 0; 1 0; 0 -1; 0 1]
6×2 Matrix{Int64}:
 -1   0
  1   1
  2   0
  1   0
  0  -1
  0   1

julia> b = [0, 2, 2, 1, 0, 1]
6-element Vector{Int64}:
 0
 2
 2
 1
 0
 1

julia> p = Polytope(A, b);

julia> facets(p)
4-element Vector{Int64}:
 1
 3
 5
 6

julia> q = Polytope(A[facets(p),:], b[facets(p)]);

julia> p == q
true
````
"""
function facets(p::Polytope)
    A = Polyhedra.hrep(p.poly).A
    b = Polyhedra.hrep(p.poly).b
    nf = nhalfspaces(p)

    # We first drop all inequalities that are not facet-defining. Detecting redundancy among the remaining
    # inequalities is straightforward: two inequalities define the same facet iff their outer normals are
    # positive scalar multiples of each other

    # BitVector whose i-th entry indicates whether inequality i is facet-defining
    isfacet = codim.(p, 1:nf) .== 1
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
            A[i,r] != 0 || continue  # dismiss right away, since we would have to scale j by 0  

            α = A[i,r] / A[j,r]
            α > 0 || continue   # rows must be positive scalar multiples of 
                                # each other in order to define the same facet
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

# Examples
````jldoctest impliciteqs
julia> A = [-1 0; 1 0; 0 -1; 0 1]; b = [0, 1, 0, 1];

julia> p = Polytope(A, b);

julia> impliciteqs(p)
Int64[]
````
Now embed the polytope `p` into the hyperplane ``x_3 = 0`` in one dimension higher:
````jldoctest impliciteqs
julia> B = [A zeros(Int, 4); 0 0 -1; 0 0 1]
6×3 Matrix{Int64}:
 -1   0   0
  1   0   0
  0  -1   0
  0   1   0
  0   0  -1
  0   0   1

julia> d = [b; 0; 0]
6-element Vector{Int64}:
 0
 1
 0
 1
 0
 0

julia> q = Polytope(B, d);

julia> facets(q)
4-element Vector{Int64}:
 1
 2
 3
 4

julia> impliciteqs(q)
2-element Vector{Int64}:
 5
 6
````
"""
function impliciteqs(p::Polytope)
    if !inciscomputed(p)
        computeinc!(p)
    end
    findall(reduce(.&, p.inc))
end

function isvertex(p::Polytope, v::Int)
    if !inciscomputed(p)
        computeinc!(p)
    end
	
    nv = Polyhedra.npoints(p.poly)
    # TODO assuming 1 <= v <= nv

    # a point is a vertex if and only if its set of incident halfspaces 
    # is inclusion-maximal among all points

    # f incident to i => f incident to j
    iscontained(i, j) = all(p.inc[j] .| (~).(p.inc[i]))  # ~ bitwise NOT
    return !any(iscontained(v, j) for j=1:nv if v != j)
end