@testset "Test for apices with redundancy" begin
    @testset "Cube" begin
        # minimal description of the 3D unit cube
        A = [1 0 0; 0 1 0; 0 0 1; -1 0 0; 0 -1 0; 0 0 -1]
        b = [1,1,1,1,1,1]
        # add redundant inequalities, some of which are NOT facet-defining
        B = [A; 1 1 1; 1 1 0; 2 0 0]
        d = [b; 3; 2; 2]

        cube = Polytope(B, d)
        @test nvertices(cube) == 8

        isfacet(i::Int) = codim(cube, i) == 1

        @test all( isfacet.([1:6; 9])) # facets
        @test !any(isfacet.([7,8]))    # non-facets

        # test codim of lower-dim faces that are already defined by a subset of their tight inequalities
        # (see also issue_codim.jl)
        for i=1:nhalfspaces(cube)
            @test dim(cube, i) + codim(cube, i) == dim(cube)
        end

        for v=1:nvertices(cube)
            apx = apices(cube, v)
            # each vertex has an antipodal one that we may take as a second apex:
            @test apx !== nothing
            # antipodal pair means they must sum to 0:
            @test sum(collect(vertices(cube))[apx]) == [0,0,0]
        end

        # remove redundant rows and check whether polytope is the same
        # TODO
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

    # test facets and impliciteqs disjoint

end