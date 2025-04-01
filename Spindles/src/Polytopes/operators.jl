# ================================
# Operators
# ================================

"""
    ==(p::Polytope, q::Polytope)

Check whether the sets of vertices of `p` and `q` are identical.

# Examples
````jldoctest
julia> Polytope([1 0; 0 1]) == Polytope([1 0; 0 1; 0 1; 1//2 1//2])
true

julia> p = Polytope([-1 0; 0 -1; 2 1], [0, 0, 3]);

julia> p == Polytope(collect(vertices(p)))
true
````
"""
Base.:(==)(p::Polytope, q::Polytope) = sort(collect(vertices(p))) == sort(collect(vertices(q)))

"""
    in(x, p)

Check whether the vector `x` is in the polytope `p`.
""" 
function Base.in(x::AbstractVector{<:Real}, p::Polytope)
    if length(t) != ambientdim(p)
        throw(DimensionMismatch("vector is of mismatched length: expected $(ambientdim(p)), got $(length(x))"))
    end
    
    @warn "not implemented"
    false
end


# create a new polytope whose vertices are the images of vertices of `p` under `f`
# FIXME function type?
applyfunc(f, p::Polytope) =
    Polytope(map(f, collect(vertices(p))))

"""
    *(δ::Real, p::Polytope)
    *(p::Polytope, δ::Real)

Rescale `p` by the scalar factor `δ`.

Note that the element type of the resulting polytope may be different from that of `p` 
(see the last example below).

# Examples
````jldoctest
julia> p = Polytope([[0, 0], [1, 0], [0, 1]])
Polytope{Rational{BigInt}}

julia> collect(vertices(p * 2))
3-element Vector{Vector{Rational{BigInt}}}:
 [0, 0]
 [2, 0]
 [0, 2]

julia> 2p == p + p
true

julia> 0.5 * p
Polytope{BigFloat}
````
"""
Base.:(*)(δ::Real, p::Polytope) = applyfunc(v -> δ * v, p)
Base.:(*)(p::Polytope, δ::Real) = δ * p

"""
    +(t, p)
    +(p, t)

Translate the polytope `p` by the vector `t`.

# Examples
````jldoctest
julia> p = Polytope([0 0; 1 0; 0 1; 1 1]);

julia> collect(vertices(-[1, 1] + 2p))
4-element Vector{Vector{Rational{BigInt}}}:
 [-1, -1]
 [1, -1]
 [-1, 1]
 [1, 1]
````
"""
function Base.:(+)(t::AbstractVector{<:Real}, p::Polytope)
    if length(t) != ambientdim(p)
        throw(DimensionMismatch("translation vector is of mismatched length: expected $(ambientdim(p)), got $(length(t))"))
    end

    applyfunc(v -> t + v, p)
end
Base.:(+)(p::Polytope, t::AbstractVector{<:Real}) = t + p
Base.:(-)(p::Polytope, t::AbstractVector{<:Real}) = -t + p

"""
    +(p::Polytope, q::Polytope)

Minkowski sum of polytopes `p` and `q`.

# Examples
Hypercubes are Minkowski sums of line segments:
````jldoctest
julia> e1 = Polytope([-1 0; 1 0]);

julia> e2 = Polytope([0 -1; 0 1]);

julia> e1 + e2 == Polytope([-1 -1; 1 -1; -1 1; 1 1])
true
````
"""
function Base.:(+)(p::Polytope, q::Polytope)
    if ambientdim(p) != ambientdim(q)
        throw(DimensionMismatch("ambient dimensions of summands must match"))
    end

    Polytope([v + w for v in vertices(p) for w in vertices(q)])
end

"""
    *(p::Polytope, q::Polytope)

Cartesian product of polytopes `p` and `q`.

# Examples
A cube is the product of line segments:
````jldoctest
julia> p = Polytope([[0], [1]]);

julia> collect(vertices(p * p * p))
8-element Vector{Vector{Rational{BigInt}}}:
 [1, 1, 1]
 [1, 1, 0]
 [1, 0, 1]
 [1, 0, 0]
 [0, 1, 1]
 [0, 1, 0]
 [0, 0, 1]
 [0, 0, 0]
````
"""
Base.:(*)(p::Polytope, q::Polytope) = 
    Polytope([[v; w] for v in vertices(p) for w in vertices(q)])

"""
    polarize(p)

Compute the polar dual of the polytope `p`.

If ``V`` denotes the set of vertices of `p`, then the *polar dual* of `p` is defined as
````math
\\{ x \\colon v^\\top x \\le 1 \\text{ for all } v \\in V \\}
````
which is a polytope if and only if `p` contains the origin in its interior. 
If this is not the case, `polarize` throws an error.

# Examples
Hypercubes and cross-polytopes are dual to each other:
````jldoctest
julia> cube(3) == polarize(crosspolytope(3))
true

julia> crosspolytope(4) == polarize(cube(4))
true
````
Note that polar duality is an involution:
````jldoctest
julia> p = cube(3);

julia> p == polarize(polarize(p))
true
````

The following polytope (a simplex) has a vertex at the origin. Therefore, `polarize` throws an error:
````jldoctest polarize
julia> p = Polytope([0 0; 1 0; 0 1]);

julia> polarize(p)
ERROR: polytope does not contain the origin in its interior
[...]
````
However, we may make the origin an interior point by taking an arbitrary interior point `x` of `p` 
and shifting the polytope by `-x`. Here we use the centroid of the simplex for `x`:
````jldoctest polarize
julia> x = sum(vertices(p)) / nvertices(p)
2-element Vector{Rational{BigInt}}:
 1//3
 1//3

julia> polarize(-x + p)
Polytope{Rational{BigInt}}
````
"""
function polarize(p::Polytope)
    # check whether 0 is in the interior of `p`
    
    b = Polyhedra.hrep(p.poly).b
    # construct a BitVector that indicates for each row of A whether the corresponding constraint
    # is an equality constraint (explicit/implicit) or not
    eqs = falses(length(b))
    eqs[collect(Polyhedra.hrep(p.poly).linset)] .= true  # linset is a BitSet and can't be used for indexing
    eqs[impliciteqs(p)] .= true

    # all non-flagged right-hand sides must be positive for 0 to be in the interior
    all(b .> 0 .| eqs) || error("polytope does not contain the origin in its interior")
    
    Polytope(hcat(vertices(p)...)', ones(Int, nvertices(p)))
end