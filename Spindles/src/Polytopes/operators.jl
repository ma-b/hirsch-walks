# ================================
# Operators
# ================================

"""
    map(f, p::Polytope)

Create a new [`Polytope`](@ref) whose vertices are the images of the vertices of `p` 
under the function `f`.

# Examples
````jldoctest map
julia> p = Polytope([0 0 0; 1 0 0; 0 2 0; 0 0 3]);

julia> q = map(x -> x[1:2], p);

julia> collect(vertices(q))
3-element Vector{Vector{Rational{BigInt}}}:
 [0, 0]
 [1, 0]
 [0, 2]
````
projects `p` onto the first two coordinates.

````jldoctest map
julia> q = map(x -> x .+ 1, p);

julia> collect(vertices(q))
4-element Vector{Vector{Rational{BigInt}}}:
 [1, 1, 1]
 [2, 1, 1]
 [1, 3, 1]
 [1, 1, 4]
````
translates `p` by the all-ones vector `[1, 1, 1]`.
"""
Base.map(f, p::Polytope) = Polytope(map(f, vertices(p)))

"""
    *(δ, p::Polytope)
    *(p::Polytope, δ)

Rescale `p` by the scalar factor `δ`. Returns a new [`Polytope`](@ref).

As with standard scalar multiplication, the shorthands `δp` and `-p` (if `δ == 1`) also work here.

See also [`-`](@ref -(::Polytope)), [`/`](@ref), [`//`](@ref), [`map`](@ref).

# Examples
````jldoctest mult
julia> p = Polytope([[0, 0], [1, 0], [0, 1]])
Polytope{Rational{BigInt}} in 2-space

julia> collect(vertices(p * 2))
3-element Vector{Vector{Rational{BigInt}}}:
 [0, 0]
 [2, 0]
 [0, 2]

julia> 2p == p + p
true

julia> collect(vertices(-p))
3-element Vector{Vector{Rational{BigInt}}}:
 [0, 0]
 [-1, 0]
 [0, -1]
````

Note that the element type of the rescaled polytope may be different from that of `p`:
````jldoctest mult
julia> 1//2 * p
Polytope{Rational{BigInt}} in 2-space

julia> 0.5 * p
Polytope{BigFloat} in 2-space

julia> 1//2 * p == 0.5 * p
true
````
"""
Base.:(*)(p::Polytope, δ::Number) = map(v -> δ * v, p)
Base.:(*)(δ::Number, p::Polytope) = p * δ

"""
    -(p::Polytope)

Equivalent to [`*`](@ref *(::Polytope, ::Number))`(-1, p)`.
"""
Base.:(-)(p::Polytope) = -1 * p

"""
    /(p::Polytope, δ)

Equivalent to [`*`](@ref *(::Polytope, ::Number))`(p, 1/δ)`.

If the scalar `δ` is an integer or a rational number and the element type of `p` 
is a subtype of `Integer` or `Rational`, use [`//`](@ref) to obtain a rational polytope again.

See also [`//`](@ref).
"""
Base.:(/)(p::Polytope, δ::Number) = 1/δ * p

"""
    //(p::Polytope, δ)

Equivalent to [`*`](@ref *(::Polytope, ::Number))`(p, 1//δ)` 
where both the element type of `p` and the type of `δ` must be subtypes of `Integer` or `Rational`.

See also [`/`](@ref).

# Examples
````jldoctest
julia> p = Polytope([[0, 0], [1, 0], [0, 1//1]])
Polytope{Rational{Int64}} in 2-space

julia> p / 1
Polytope{Float64} in 2-space

julia> p // 1
Polytope{Rational{Int64}} in 2-space

julia> (p / 1) // 1
ERROR: MethodError: no method matching //(::Polytope{Float64}, ::Int64)
[...]
````
"""
Base.:(//)(p::Polytope{T}, δ::Union{Integer, Rational}) where {T<:Union{Integer, Rational}} = 1//δ * p

"""
    +(t, p)
    +(p, t)

Translate the polytope `p` by the vector `t`. Returns a new [`Polytope`](@ref).

See also [`-`](@ref -(::Polytope, ::Number)), [`map`](@ref).

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
function Base.:(+)(p::Polytope, t::AbstractVector{<:Number})
    if length(t) != ambientdim(p)
        throw(DimensionMismatch("translation vector is of mismatched length: expected $(ambientdim(p)), got $(length(t))"))
    end

    map(v -> v + t, p)
end
Base.:(+)(t::AbstractVector{<:Number}, p::Polytope) = p + t

"""
    -(p, t)

Equivalent to [`+`](@ref +(::Polytope, ::AbstractVector{<:Number}))`(p, -t)`.

# Examples
````jldoctest
julia> p = Polytope([0 0; 1 0; 0 1; 1 1]);

julia> collect(vertices(2p - [1, 1]))
4-element Vector{Vector{Rational{BigInt}}}:
 [-1, -1]
 [1, -1]
 [-1, 1]
 [1, 1]
````
"""
Base.:(-)(p::Polytope, t::AbstractVector{<:Number}) = -t + p

"""
    +(p::Polytope, q::Polytope)

Minkowski sum of polytopes `p` and `q`.

# Examples
Hypercubes are Minkowski sums of line segments:
````jldoctest
julia> p = Polytope([-1 0; 1 0]) + Polytope([0 -1; 0 1]);

julia> collect(vertices(p))
4-element Vector{Vector{Rational{BigInt}}}:
 [-1, -1]
 [-1, 1]
 [1, -1]
 [1, 1]
````
"""
function Base.:(+)(p::Polytope, q::Polytope)
    if ambientdim(p) != ambientdim(q)
        throw(DimensionMismatch("ambient dimensions of summands must match"))
    end

    Polytope([v + w for v in vertices(p) for w in vertices(q)])
end

"""
    sum(ps)

Minkowski sum of the collection of [`Polytope`](@ref)s `ps`.

# Examples
````jldoctest
julia> p = sum([Polytope([[0, 0], Int.(1:2 .== i)]) for i=1:2]);

julia> collect(vertices(p))
4-element Vector{Vector{Rational{BigInt}}}:
 [0, 0]
 [0, 1]
 [1, 0]
 [1, 1]
````
"""
Base.sum

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
    polarize(p::Polytope)

Compute the polar dual of the polytope `p`.

If ``V`` denotes the set of vertices of `p`, then the *polar dual* of `p` is
````math
\\{ x \\colon v^\\top x \\le 1 \\text{ for all } v \\in V \\}
````
which is a polytope if and only if `p` contains the origin in its interior. 
If this is not the case, `polarize` throws an error.

# Examples
[Hypercubes](@ref cube) and [cross-polytopes](@ref crosspolytope) are dual to each other:
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
ERROR: got a polytope that does not contain the origin in its interior
[...]
````
However, we may make the origin an interior point by taking an arbitrary interior point `x` of `p` 
and shifting the polytope by `-x`. Here we use the centroid of the simplex for `x`:
````jldoctest polarize
julia> x = sum(vertices(p)) / nvertices(p)
2-element Vector{Rational{BigInt}}:
 1//3
 1//3

julia> polarize(p - x)
Polytope{Rational{BigInt}} in 2-space
````
"""
function polarize(p::Polytope)
    !isempty(p) || error("got an empty polytope")
    
    # check whether 0 is in the interior of `p`
    A, b, eqs = repr(p; implicit_equations=true)
    # convert the BitSet `eqs` to a BitVector
    iseq = in.(axes(A, 1), Ref(eqs))

    # all non-flagged right-hand sides must be positive for 0 to be in the interior
    all(iseq .| (b .> 0)) || error("got a polytope that does not contain the origin in its interior")
    
    Polytope(hcat(vertices(p)...)', ones(Int, nvertices(p)))
end