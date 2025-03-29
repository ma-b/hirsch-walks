# ================================
# Redundancy detection
# ================================

# --------------------------------
# H-redundancy
# --------------------------------

"""
    facets(p::Polytope)

Return a minimal subset of inequality indices that contains one inequality for each facet of `p`.

If multiple inequalities in the description of `p` define the same facet,
the one with the smallest index is selected.

See also [`nfacets`](@ref), [`impliciteqs`](@ref).

# Examples

````jldoctest facets
julia> A = [-1 0; 1 0; 0 -1; 0 1]; b = [0, 1, 0, 1];

julia> p = Polytope(A, b);
````
creates the polytope defined by the system
```math
\\begin{aligned}
0 \\le x_1 &\\le 1 \\\\
0 \\le x_2 &\\le 1
\\end{aligned}
```

The following inequalities are also valid for `p`:
```math
\\begin{aligned}
3 x_1 &\\le 3 \\\\
x_1 + x_2 &\\le 2
\\end{aligned}
```

Adding them to the original (irredundant) system introduces redundancy:
````jldoctest facets
julia> B = [3 0; 1 1; A]; d = [3; 2; b];

julia> q = Polytope(B, d);

julia> f = facets(q)
4-element Vector{Int64}:
 1
 3
 5
 6

julia> r = Polytope(B[f,:], d[f]);

julia> p == q == r
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
The polytope given by
```math
\\begin{aligned}
0 \\le x_1 &\\le 1 \\\\
x_2 &= 0
\\end{aligned}
```
can be modeled by replacing the equality constraint with two inequalities ``\\pm x_2 \\le 0`` as follows:

````jldoctest
julia> A = [-1 0; 1 0; 0 -1; 0 1]; b = [0, 1, 0, 0];

julia> p = Polytope(A, b);

julia> impliciteqs(p)
2-element Vector{Int64}:
 3
 4
````
"""
function impliciteqs(p::Polytope)
    if !inciscomputed(p)
        computeinc!(p)
    end
    findall(reduce(.&, p.inc))
end

# --------------------------------
# V-redundancy
# --------------------------------

# Check whether index v is a vertex of p. 
# To be able to build a list of all vertices without duplicates, set unique=true.
# Then, for each vertex that occurs multiple times in the description of p, only the 
# occurrence with the least index counts as a vertex.
function isvertex(p::Polytope, v::Int; unique::Bool=false)
    if !inciscomputed(p)
        computeinc!(p)
    end
	
    nv = nvertices(p)
    # TODO assuming that 1 <= v <= nv

    # A point is a vertex if and only if its set of incident halfspaces 
    # is inclusion-maximal among all points. We may check whether each halfspace 
    # incident to i is also incident to j like this:
    iscontained(i, j) = all(p.inc[j] .| (~).(p.inc[i]))  # ~ bitwise NOT

    # to avoid filtering out all occurrences of duplicate vertices,
    # we require strict containment (for all i > j if unique is set to true)
    isidentical(i, j) = p.inc[i] == p.inc[j] && (!unique || i < j)
    
    return all(!iscontained(v, j) || isidentical(v, j) for j=1:nv if v != j)
end

# Delete all non-vertices from the description (return new polytope if applies)
function remove_vredundancy(p::Polytope)
    isv = isvertex.(p, 1:nvertices(p); unique=true)
    all(isv) ? p : Polytope(collect(vertices(p))[isv])
end