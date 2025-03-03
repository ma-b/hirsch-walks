using Polyhedra: hrep
using Graphs: degree

@testset "Tests for incidence/graph computations" begin

    A, b, _ = readineq("../examples/s-25-5.txt", BigInt)  # TODO for others too
    s = Polytope(A, b)

    @testset "Redundancy/dimension" begin
        @test nhalfspaces(s) == size(A, 1)  # we know that Ax <= b is irredundant
        @test dim(s) == 5
    end

    # distances must be symmetric
    @test dist(s, apices(s)...) == dist(s, reverse(apices(s))...)

    @testset "Count degenerate vertices" begin
        # find all degenerate vertices
        @test findall(degree(graph(s)) .> 5) == findall(map(sum, s.inc) .> 5)
    end

    @testset "Incidence matrix" begin
        # computeinc! << 2 < 3 (10x memory allocations)
        function inc2(s::Polytope)
            [hrep(s.poly).A * v .== hrep(s.poly).b for v in vertices(s)]
        end
        function inc3(s::Polytope)
            [isapprox.(hrep(s.poly).A * v, hrep(s.poly).b) for v in vertices(s)]
        end

        @test s.inc == inc2(s) == inc3(s)
    end

    # test the two improper faces: s itself and the empty face
    @test incidentvertices(s, Int[]) == collect(1:nvertices(s))
    @test isempty(incidentvertices(s, 1:nhalfspaces(s)))
end