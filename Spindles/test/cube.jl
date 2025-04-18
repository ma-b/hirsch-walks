@testset "Cube and cross-polytope" begin
    n = 4
    p = cube(n)
    q = crosspolytope(n)

    @testset "Check duality" begin
        # f-vectors must be reverses of each other since the polytopes are dual to each other
        @test nfacesofdim.(p, -1:n) == nfacesofdim.(q, n:-1:-1)

        @test q == polarize(p)
        @test p == polarize(q)
        @test p == polarize(polarize(p))
        @test q == polarize(polarize(q))

        @test issimple(p)
        @test issimplicial(q)
    end

    @testset "Check dim/codim" begin
        # check dim + codim for all subsets of facets
        function testalldim(p::Polytope)
            nf = last(ineqindices(p))
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

    @testset "Check product of line segments" begin
        @test cube(n) == reduce(*, repeat([Polytope([[-1], [1]])], n))
        @test cube(n) == reduce(*, repeat([2simplex(1) - [1]], n))
    end

    @testset "Check sets" begin
        @test simplex(n) ⊆ p
        @test simplex(n) ⊆ q

        @test zeros(Int, n) ∈ p ∩ q
        @test simplex(n) ∪ q == q
    end
end