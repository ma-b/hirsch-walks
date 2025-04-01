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