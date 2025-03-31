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