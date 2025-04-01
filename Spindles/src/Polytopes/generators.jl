# ================================
# Polytope generators
# ================================

"""
    simplex(n)

Create the `n`-dimensional simplex whose vertices are the standard basis vectors in ``\\mathbb{R}^n``
plus the origin.
"""
function simplex(n::Integer)
    A = [zeros(Int, n, n); ones(Int, 1, n)]
    for i=1:n
        A[i,i] = -1
    end
    b = [zeros(Int, n); 1]
    Polytope(A, b)
end

"""
    cube(n)

Create the `n`-dimensional standard hypercube ``[-1,1]^n``.
"""
function cube(n::Integer)
    # matrix with one row for each 0/1 vector
    V = [(i >> j) & 1 for i=0:(2^n-1), j=0:(n-1)]
    Polytope(@. 2V-1)  # transform unit cube to standard cube
end

"""
    crosspolytope(n)

Create the `n`-dimensional standard cross-polytope 
whose vertices are the ``2n`` positive and negative standard basis vectors in ``\\mathbb{R}^n``.
"""
function crosspolytope(n::Integer)
    # matrix with one row for each of the 2n vertices
    V = zeros(Int, 2n, n)
    for i=1:n
        V[2i-1, i] =  1
        V[2i,   i] = -1
    end
    Polytope(V)
end

"""
    permutahedron(n)

Create the `n`-th permutahedron. It is defined as the convex hull of the vectors 
``(\\pi(1), \\pi(2), \\dots, \\pi(n))`` for all permutations ``\\pi`` of ``\\{1,2, \\dots, n\\}``.

Note that its dimension is ``n-1``.

# Examples
````jldoctest
julia> p = permutahedron(3);

julia> nvertices(p) == factorial(3)
true

julia> dim(p)
2
````
"""
function permutahedron(n::Integer)
    A = [(i >> j) & 1 for i=1:(2^n-1), j=0:(n-1)]
    sums = reshape(sum(A, dims=2), size(A,1))
    b = sums .* (sums .+ 1) .// 2

    # add implicit equation
    A = [-A; ones(Int, 1, n)]
    b = [-b; n*(n+1)//2]

    Polytope(A, b)
end

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

julia> q = -x + p;

julia> polarize(q)
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