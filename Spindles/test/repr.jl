using Polyhedra: hrep

@testset "Tests for constructors" begin
    @testset "Explicit and implicit equation" begin
        p = Polytope([1 0; 0 1])
        
        # same, but with an implicit equation
        A = [-1 0; 1 1; 0 -1; -1 -1]
        b = [0, 1, 0, -1]
        q = Polytope(A, b)

        @test apices(p) !== nothing
        @test apices(q) !== nothing

        @test p == Polytope(collect(vertices(p)))
        @test p == q

        @test reduce(.&, q.inc) == (codim.(q, ineqindices(q)) .== 0)
    end

    @testset "Preserve indices" begin
        A = [1 0; 0 1; -1 0; 0 -1]
        b = [1, 1, 1, 1]
        s = Polytope(A, b)

        @test hrep(s.poly).A == A
        @test hrep(s.poly).b == b
    end

    @testset "Non-spindle" begin
        p = Polytope([1 0; 0 1; 0 0])
        @test apices(p) === nothing
    end

    @testset "Redundant and duplicate point" begin
        p = Polytope([1 0; 0 1; 0 1; 1//2 1//2]);

        #collect(vertices(p))
        @test nvertices(p) == 2
    end
end