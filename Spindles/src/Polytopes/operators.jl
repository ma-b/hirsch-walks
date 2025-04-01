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

julia> collect(vertices([-1, -1] + 2p))
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