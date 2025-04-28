# ================================
# V- and H-representations
# ================================

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

# internal functions without bound checks
function _incidentvertices(p::Polytope, indices::AbstractVector{Int})
    filter(v -> all(p.inc[v][indices]), 1:nvertices(p))
end
_incidentvertices(p::Polytope, i::Int) = _incidentvertices(p, [i])
function _incidenthalfspaces(p::Polytope, indices::AbstractVector{Int}; init=trues(nhalfspaces(p)))
    findall(reduce(.&, p.inc[indices]; init=init))
end
_incidenthalfspaces(p::Polytope, v::Int) = _incidenthalfspaces(p, [v])

"""
    incidentvertices(p::Polytope, indices::AbstractVector{Int})

Return the indices of all vertices of the polytope `p` for which each inequality 
in the collection `indices` is tight (i.e., satisfied at equality). 
Here, index `i` refers to the `i`th inequality in [`inequalities`](@ref).

If `indices` is empty, this is the same as `collect(1:nvertices(p))`.

See also [`nvertices`](@ref), [`inequalities`](@ref), [`tightinequalities`](@ref).

# Examples
````jldoctest
julia> p = Polytope([-1 0; 0 -1; 2 3], [0, 0, 1]);

julia> collect(vertices(p))
3-element Vector{Vector{Rational{BigInt}}}:
 [1//2, 0]
 [0, 1//3]
 [0, 0]

julia> inequalities(p)
(Rational{BigInt}[-1 0; 0 -1; 2 3], Rational{BigInt}[0, 0, 1])

julia> incidentvertices(p, [3])
2-element Vector{Int64}:
 1
 2
````
"""
function incidentvertices(p::Polytope, indices::AbstractVector{Int})
    all(isineqindex.(p, indices)) || throw(ArgumentError("inequality indices must be between 1 and $(nhalfspaces(p))"))
    
    if !inciscomputed(p)
        computeinc!(p)
    end
    _incidentvertices(p, indices)
end

"""
    tightinequalities(p::Polytope, indices)

Return the indices of all inequalities that are tight (i.e., satisfied at equality) 
for each vertex in the collection `indices`.

If `indices` is empty, this is the same as `collect(ineqindices(p))`.

See also [`ineqindices`](@ref), [`incidentvertices`](@ref).

# Examples
````jldoctest
julia> p = Polytope([-1 0; 0 -1; 2 3], [0, 0, 1]);

julia> collect(vertices(p))
3-element Vector{Vector{Rational{BigInt}}}:
 [1//2, 0]
 [0, 1//3]
 [0, 0]

julia> inequalities(p)
(Rational{BigInt}[-1 0; 0 -1; 2 3], Rational{BigInt}[0, 0, 1])

julia> tightinequalities(p, [1])
2-element Vector{Int64}:
 2
 3
````
"""
function tightinequalities(p::Polytope, indices::AbstractVector{Int})
    all(isvertexindex.(p, indices)) || throw(ArgumentError("indices must be between 1 and $(nvertices(p))"))

    if !inciscomputed(p)
        computeinc!(p)
    end
    _incidenthalfspaces(p, indices)
end

# --------------------------------
# implicit equations
# --------------------------------

implicitscomputed(p::Polytope) = p.isimpliciteq !== nothing
function computeimpliciteqs!(p::Polytope)
    if !inciscomputed(p)
        computeinc!(p)
    end
    p.isimpliciteq = reduce(.&, p.inc)
end


# --------------------------------
# V-representations
# --------------------------------

"""
    vertices(p::Polytope)

Return an iterator over the vertices of the polytope `p`.

See also [`nvertices`](@ref).

# Examples
````jldoctest
julia> p = Polytope([    1     0
                         0     1
                         0     1
                      1//2  1//2 ]);

julia> collect(vertices(p))
2-element Vector{Vector{Rational{Int64}}}:
 [1, 0]
 [0, 1]
````
"""
vertices(p::Polytope) = Polyhedra.points(p.poly)

"""
    nvertices(p::Polytope)

Return the number of vertices of `p`.

See also [`vertices`](@ref Spindles.Polytopes.vertices).
"""
nvertices(p::Polytope) = Polyhedra.npoints(p.poly)
isvertexindex(p::Polytope, v::Int) = 1 <= v <= nvertices(p)

# --------------------------------
# V-redundancy (functions invoked by `Polytope` constructor)
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

# --------------------------------
# H-representations
# --------------------------------

# extract H-representation from internal `Polyhedra.Polyhedron` object
function repr(p::Polytope; implicit_equations=false)
    # possibly need to convert to proper type (applies to 1D polytopes)
    h = Polyhedra.MixedMatHRep(Polyhedra.hrep(p.poly))

    if implicit_equations
        # detect implicit equations, i.e., inequalities that are satisfied at equality for each point in `p`
        if !implicitscomputed(p)
            computeimpliciteqs!(p)
        end

        # index offset is the number of hyperplanes in the internal `Polyhedra.Polyhedron`
        # (first block of rows of A corresponds to (explit) equality constraints,
        # second block below contains coefficients of inequality constraints)
        eqs = union(h.linset, findall(p.isimpliciteq) .+ Polyhedra.nhyperplanes(p.poly))
    else
        eqs = h.linset
    end
    h.A, h.b, eqs
end

"""
    ambientdim(p::Polytope)

Return the dimension of the ambient space of the polytope `p`.

See also [`dim`](@ref Spindles.Polytopes.dim).

# Examples
````jldoctest
julia> ambientdim(Polytope([[1, 0], [0, 1]]))
2
````
"""
function ambientdim(p::Polytope)
    A, _, = repr(p)
    size(A, 2)
end

"""
    affinehull(p::Polytope)

Return a tuple `(B, d)` of a matrix `B` and a vector `d` 
such that the system of linear equations ``Bx = d`` defines the affine hull of `p`.
Note that this system is not necessarily minimal.

See also [`inequalities`](@ref), [`facets`](@ref).

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

julia> affinehull(Polytope(A, b))
(Rational{BigInt}[0 -1; 0 1], Rational{BigInt}[0, 0])
````
"""
function affinehull(p::Polytope)
    A, b, eqs = repr(p; implicit_equations=true)
    
    # TODO remove opposites/scalings
    A[collect(eqs), :], b[collect(eqs)]
end

"""
    inequalities(p::Polytope)

Return a tuple `(A, b)` of a matrix `A` and a vector `b` such that `p`
is given by all points ``x`` in the affine hull of `p` that satisfy ``Ax \\le b``.

If `p` was created from an H-representation and is full-dimensional, this will return the same
system that `p` was created from.

See also [`ineqindices`](@ref), [`facets`](@ref), [`affinehull`](@ref Spindles.Polytopes.affinehull).

# Examples
````jldoctest
julia> inequalities(Polytope([-1 0; 0 -1; 2 3], [0, 0, 1]))
(Rational{BigInt}[-1 0; 0 -1; 2 3], Rational{BigInt}[0, 0, 1])
````
"""
function inequalities(p::Polytope)
    A, b, eqs = repr(p)
    isineq = (~).(in.(axes(A, 1), Ref(eqs)))  # BitVector whose i-th entry indicates 
                                              # whether i is an inequality (1) or equality (0) constraint
    A[isineq, :], b[isineq]
end

"""
    ineqindices(p::Polytope)

Return the valid range of indices for the rows of the coefficient matrix `A` returned by [`inequalities`](@ref).

See also [`inequalities`](@ref), [`Base.axes`](https://docs.julialang.org/en/v1/base/arrays/#Base.axes-Tuple{Any}).

# Examples
````jldoctest
julia> ineqindices(Polytope([-1 0; 0 -1; 2 3], [0, 0, 1]))
Base.OneTo(3)
````
"""
ineqindices(p::Polytope) = axes(inequalities(p)[1], 1)
nhalfspaces(p::Polytope) = Polyhedra.nhalfspaces(p.poly)
isineqindex(p::Polytope, i::Int) = 1 <= i <= nhalfspaces(p)

# --------------------------------
# H-redundancy
# --------------------------------

# determine whether rows i and j of A are (positive) nonzero scalar multiples of one another
# (FIXME assuming rational data)
function ismultiple(A::AbstractMatrix, i::Int, j::Int; positive=false)
    # find a column r of A such that A[j,r] is nonzero
    # and scale the row j such that this entry matches A[i,r] in absolute value
    r = findfirst(A[j,:] .!= 0)
    A[i,r] != 0 || return false  # dismiss right away, since we would have to scale j by 0  

    α = A[i,r] / A[j,r]  # TODO preserves rational type if both are rationals
    positive && α > 0 || !positive && α != 0 || return false   # dismiss if multiplier is zero (or negative)
    
    # is rescaled row j identical to i?
    return A[j,:] * α == A[i,:]
end

facetscomputed(p::Polytope) = p.isfacet !== nothing
function computefacets!(p::Polytope)
    A, _, = repr(p)
    nh = Polyhedra.nhyperplanes(p.poly)
    nf = Polyhedra.nhalfspaces(p.poly)

    # We first drop all inequalities that are not facet-defining. Detecting redundancy among the remaining
    # inequalities is straightforward: Two inequalities define the same facet iff their outer normals are
    # positive scalar multiples of each other. 
    # Being multiples of one another partitions the rows of A into equivalence classes.
    # We retain one representative of each class, the one with the least index.

    # initialize with BitVector whose i-th entry indicates whether inequality i is facet-defining
    p.isfacet = codim.(p, 1:nf) .== 1
    # keep track of inequalities whose deletion will leave an irredundant inequality description
    # their indices will be set to false in the following loop
    keep = trues(nf)

    for i=1:nf
        # continue if i is not a facet or has already been flagged as redundant
        p.isfacet[i] && keep[i] || continue
        
        for j=i+1:nf
            p.isfacet[j] && keep[j] || continue
            # since we build the equivalence classes one after the other, we may discard any row j that 
            # belongs to a previously identified class but was not chosen as its representative (keep[j] == false)

            # if rows i and j are positive scalar multiples of one another, then i and j must define the same facet
            # (and the corresponding right-hand sides are necessarily identical too)
            keep[j] = !ismultiple(A[(nh+1):end, :], i, j; positive=true)  # offset by number of hyperplanes

            #=
            # find a column r of A such that A[j+nh,r] is nonzero
            # and scale the row j such that this entry matches A[i+nh,r] in absolute value
            r = findfirst(A[j + nh, :] .!= 0)
            A[i + nh, r] != 0 || continue  # dismiss right away, since we would have to scale j by 0  

            α = A[i + nh, r] / A[j + nh, r]  # TODO preserves rational type if both are rationals
            α > 0 || continue   # rows must be positive scalar multiples of 
                                # each other in order to define the same facet
            # if the rescaled row j is now identical to row i, then i and j must define the same facet
            # (and the corresponding right-hand sides are necessarily identical too)
            if A[j,:] * α == A[i,:]
                @assert b[j] * α == b[i]
                keep[j] = false
            end
            =#
        end
    end

    p.isfacet = p.isfacet .& keep
end

# minimal system Ax <= b that, together with the affine hull, defines `p`
"""
    facets(p::Polytope)

Return a tuple `(A, b)` such that the system ``Ax \\le b`` is a minimal system
of facet-definining inequalities for `p`.

Note that this system need not be unique.
If `p` was constructed from an H-representation for which multiple inequalities 
define the same facet, the facet-defining inequality with the smallest index is selected.

See also [`nfacets`](@ref), [`inequalities`](@ref).

# Examples

````jldoctest facets
julia> A = [ -1   0
              1   0
              0  -1
              0   1 ];

julia> b = [0, 1, 0, 1];

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
julia> q = Polytope([3 0; 1 1; A], [3; 2; b]);

julia> B, d = facets(q);

julia> B
4×2 Matrix{Rational{BigInt}}:
  3   0
 -1   0
  0  -1
  0   1

julia> d
4-element Vector{Rational{BigInt}}:
 3
 0
 0
 1

julia> p == q == Polytope(B, d)
true
````
"""
function facets(p::Polytope)
    if !facetscomputed(p)
        computefacets!(p)
    end
    
    A, b, = repr(p)
    nh = Polyhedra.nhyperplanes(p.poly)
    A[((nh+1):end)[p.isfacet], :], b[((nh+1):end)[p.isfacet]]  # offset
end

"""
    nfacets(p::Polytope)

Return the number of facets of `p`. 
Equivalent to `nfacesofdim(p, dim(p) - 1)` but has a different implementation.

See also [`nfacesofdim`](@ref), [`dim`](@ref dim(::Polytope)), [`facets`](@ref).
"""
function nfacets(p::Polytope)
    if !facetscomputed(p)
        computefacets!(p)
    end
    sum(p.isfacet)
end
