@testset "Apices with redundancy" begin
    @testset "Cube" begin
        # minimal description of the 3D unit cube
        A = [1 0 0; 0 1 0; 0 0 1; -1 0 0; 0 -1 0; 0 0 -1]
        b = [1, 1, 1, 1, 1, 1]
        # add redundant inequalities, some of which are NOT facet-defining
        B = [A; 1 1 1; 1 1 0; 2 0 0]
        d = [b; 3; 2; 2]

        p = Polytope(B, d)
        @test nvertices(p) == 8
        @test p == Polytope(A, b)

        isfacet(i::Int) = codim(p, i) == 1

        @test  all(isfacet.([1:6; 9])) # facets
        @test !any(isfacet.([7,8]))    # non-facets

        # test codim of lower-dim faces that are already defined by a subset of their 
        # tight inequalities (see also issue_codim.jl)
        for i in ineqindices(p)
            @test dim(p, i) + codim(p, i) == dim(p)
        end

        for v=1:nvertices(p)
            apx = apices(p, v)
            # each vertex has an antipodal one that we may take as a second apex:
            @test apx !== nothing
            # antipodal pair means they must sum to 0:
            @test sum(collect(vertices(p))[apx]) == [0,0,0]
        end

        # try to find apices without eliminating redundancy first; 
        # this should fail for at least one vertex
        @test any(isnothing, apices(p, v; checkredund=false) for v=1:nvertices(p))

        # remove redundant rows and check whether polytope is the same
        # (we know that the polytope is full-dimensional)
        @test p == Polytope(facets(p)...)
    end

    @testset "Introduce redundancy to s48" begin
        A, b, = readineq(joinpath("..", "examples", "s-48-5.txt"), Int)
        s = Polytope([A; sum(A[1:10,:], dims=1)], [b; sum(b[1:10])])
        @test nfacets(s) == 48
        
        apx = apices(s)
        @test apx !== nothing
        apx = collect(vertices(s))[apx]
        @test [1,0,0,0,0] in apx
        @test [-1,0,0,0,0] in apx
    end
end