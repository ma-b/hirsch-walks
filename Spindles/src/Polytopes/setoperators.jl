# ================================
# Set-theoretic operators
# ================================

"""
    ==(p::Polytope, q::Polytope) -> Bool

Check whether polytopes `p` and `q` have the same set of vertices.

# Examples
````jldoctest
julia> p = Polytope([1 0; 0 1]);

julia> p == p
true

julia> p == Polytope(collect(vertices(p)))
true

julia> p == Polytope([1 0; 0 1; 0 1; 1//2 1//2])
true

julia> p == Polytope([1.0 -0.0; 0 1])
true

julia> p == Polytope([0.999999 0; 0 1])
false
````
"""
Base.:(==)(p::Polytope, q::Polytope) = sort(collect(vertices(p))) == sort(collect(vertices(q)))

"""
    in(x, p::Polytope) -> Bool
    ∈(x, p::Polytope) -> Bool

Check whether the vector `x` is in the polytope `p`.

# Examples
````jldoctest
julia> p = Polytope([0 0; 1 0; 0 1]);

julia> [1, 1] in p
false

julia> (sum(vertices(p)) / nvertices(p)) ∈ p
true
````
""" 
function Base.in(x::AbstractVector{<:Real}, p::Polytope)
    if length(x) != ambientdim(p)
        throw(DimensionMismatch("vector is of mismatched length: expected $(ambientdim(p)), got $(length(x))"))
    end
    
    h = Polyhedra.MixedMatHRep(Polyhedra.hrep(p.poly))  # FIXME
    all(h.A * x .<= h.b) && all(isapprox.(h.A[collect(h.linset),:] * x, h.b[collect(h.linset)]))
end

"""
    issubset(p::Polytope, q::Polytope) -> Bool
    ⊆(p::Polytope, q::Polytope) -> Bool
    ⊇(q::Polytope, p::Polytope) -> Bool

Check whether `p` is contained in `q`. 

# Examples
````jldoctest
julia> p = Polytope([0 0; 1 0; 0 1]);

julia> issubset(p, p)
true

julia> q = Polytope([0 0; 1 0; 0 1; 1 1]);

julia> p ⊆ q
true

julia> p ⊇ q
false
````
"""
Base.issubset(p::Polytope, q::Polytope) = all(v in q for v in vertices(p))

"""
    isempty(p::Polytope) -> Bool

Check whether `p` is the empty polytope ``\\emptyset``.
"""
Base.isempty(p::Polytope) = isempty(vertices(p))

"""
    intersect(p::Polytope, polytopes...)
    ∩(p::Polytope, polytopes...)

Intersection of `p` and all polytopes in `polytopes`. Returns a new [`Polytope`](@ref).

See also [`union`](@ref).

# Examples
````jldoctest
julia> p = Polytope([[-1, 0], [1, 0]]) ∩ Polytope([[0, -1], [0, 1]]);

julia> collect(vertices(p))
1-element Vector{Vector{Rational{BigInt}}}:
 [0, 0]

julia> p = Polytope([0 0; 1 0; 0 1]);

julia> q = intersect((Polytope([v]) for v in vertices(p))...);

julia> isempty(q)
true
````
"""
Base.intersect(p::Polytope, polytopes...) = 
    Polytope(intersect(p.poly, mapreduce(q -> q.poly, intersect, polytopes)))
# TODO fallback implementation relying on `intersect` for Polyhedra.Polyhedron

"""
    union(p::Polytope, polytopes...)
    ∪(p::Polytope, polytopes...)

Union of `p` and all polytopes in `polytopes`. Returns a new [`Polytope`](@ref).

See also [`intersect`](@ref).

# Examples
````jldoctest
julia> p = Polytope([[-1, 0], [1, 0]]) ∪ Polytope([[0, -1], [0, 1]]);

julia> collect(vertices(p))
4-element Vector{Vector{Rational{BigInt}}}:
 [-1, 0]
 [1, 0]
 [0, -1]
 [0, 1]

julia> p == union((Polytope([v]) for v in vertices(p))...)
true
````
"""
Base.union(p::Polytope, polytopes...) = 
    Polytope(union(collect(vertices(p)), mapreduce(collect ∘ vertices, union, polytopes)))
# FIXME need `collect` here because intersect/union on Polyhedra vertices returns Vector{Any}
#       (eltype of Polyhedra vertex iterator is Any)

"""
    isdisjoint(p::Polytope, q::Polytope)

Check whether `p` and `q` are disjoint. Equivalent to `isempty(p ∩ q)`.

See also [`intersect`](@ref), [`isempty`](@ref).

# Examples
````jldoctest
julia> isdisjoint(Polytope([[-1, 0], [1, 0]]), Polytope([[0, -1], [0, 1]]))
false
````
"""
Base.isdisjoint(p::Polytope, q::Polytope) = isempty(intersect(p, q))