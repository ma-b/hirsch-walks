using Polyhedra: polyhedron, hrep

@testset "Tests for constructors and representations" begin
    @testset "Explicit vs implicit equations I" begin
        # line segment
        p = Polytope([1 0; 0 1])
        
        # same but with an implicit equation
        A = [-1 0; 1 1; 0 -1; -1 -1]
        b = [0, 1, 0, -1]
        q = Polytope(A, b)

        # both must be spindles
        @test apices(p) !== nothing
        @test apices(q) !== nothing

        @test p == Polytope(collect(vertices(p)))
        @test p == q

        @test reduce(.&, q.inc) == (codim.(q, ineqindices(q)) .== 0)
    end

    @testset "Explicit vs implicit equations II" begin
        A = [-1 0; 1 0; 0 -1; 0 1]
        b = [0, 1, 0, 0]

        # two implicit equations
        p = Polytope(A, b)
        # make one of them an explicit equality constraint
        q = Polytope(polyhedron(hrep(A, b, BitSet([3]))))

        @test p == q

        @test inequalities(p) == (A, b)
        @test inequalities(q) == (A[[1,2,4],:], b[[1,2,4]])
        @test affinehull(p) == affinehull(q)
        @test facets(p) == facets(q)
    end

    @testset "Preserve indices" begin
        A = [1 0; 0 1; -1 0; 0 -1]
        b = [1, 1, 1, 1]
        s = Polytope(A, b)

        @test hrep(s.poly).A == A
        @test hrep(s.poly).b == b
        @test inequalities(s) == (A, b)
    end

    @testset "Non-spindle" begin
        p = Polytope([1 0; 0 1; 0 0])
        @test apices(p) === nothing
    end

    @testset "Redundant and duplicate point" begin
        p = Polytope([1 0; 0 1; 0 1; 1//2 1//2]);
        @test nvertices(p) == 2
    end

    @testset "Argument errors" begin
        A = [1 0; 0 1; -1 0; 0 -1]
        b = [1, 1, 1, 1]

        @test try
            Polytope(A, b[2:end])  # wrong dimensions
            false
        catch
            true
        end

        # vertex index out of bounds
        @test try apices(Polytope(A, b), 10); false catch; true end
    end
end