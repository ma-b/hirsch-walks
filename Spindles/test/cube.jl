@testset "Cube and cross-polytope" begin
    # n-dimensional 0/1 cube
    function cube(n::Int)
        # matrix with one row for each vertex
        V = [(i >> j) & 1 for i=0:(2^n-1), j=0:(n-1)]
        Polytope(V)
    end

    # n-dimensional standard cross-polytope
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

    @testset "Check dim/codim" begin
        # check dim + codim for all subsets of facets
        function testalldim(p::Polytope)
            nf = nhalfspaces(p)
            # enumerate the incidence vectors of all subsets of [nf]
            for i=0:(2^nf-1)
                b = BitVector([(i >> j) & 1 for j=0:(nf-1)])
                indices = (1:nf)[b]
                @test dim(p, indices) + codim(p, indices) == dim(p)
            end
        end

        testalldim(p)   # 2^(2n) subsets
        #testalldim(q)  # 2^(2^n) subsets!!!!
    end
    
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