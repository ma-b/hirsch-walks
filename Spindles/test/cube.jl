@testset "Cube and cross-polytope" begin
    # n-dimensional 0/1 cube
    function cube(n::Int)
        # matrix with one row for each vertex
        V = [(i >> j) & 1 for i=0:(2^n-1), j=0:(n-1)]
        Polytope(V)
    end

    # n-th standard cross-polytope
    function crosspolytope(n::Int)
        # matrix with one row for each of the 2n vertices
        V = zeros(Int, 2n, n)
        for i=1:n
            V[2i-1, i] = 1
            V[2i,   i] = -1
        end
        Polytope(V)
    end

    n = 4
    p = cube(n)
    q = crosspolytope(n)

    # f-vectors must be reverses of each other since the polytopes are dual to each other
    @test nfacesofdim.(p, -1:n) == nfacesofdim.(q, n:-1:-1)
    
    @testset "Check prescribed apex" begin
        # both cube and cross-polytope are spindles where each vertex can be an apex
        for i=1:nvertices(p)
            @test apices(p, i) !== nothing
        end
        for i=1:nvertices(q)
            @test apices(q, i) !== nothing
        end
    end
end