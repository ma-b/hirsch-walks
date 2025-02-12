using Polyhedra: hrep
using Graphs: degree

@testset "Tests for incidence/graph computations" begin

    A, b, _ = readineq("../examples/s-25-5.txt", BigInt)  # TODO for others too
    sp = Spindle(A, b)

    Spindles.computeinc!(sp)

    @testset "Redundancy/dimension" begin
        @test Spindles.nhalfspaces(sp) == size(A, 1)  # we know that Ax <= b is irredundant
        @test Spindles.dim(sp) == 5
    end

    # distances must be symmetric
    @test dist(sp, apices(sp)...) == dist(sp, reverse(apices(sp))...)

    @testset "Count degenerate vertices" begin
        # find all degenerate vertices
        @test findall(degree(graph(sp)) .> 5) == findall(map(sum, sp.inc) .> 5)
    end

    @testset "Incidence matrix" begin
        # computeinc! << 2 < 3 (10x memory allocations)
        function inc2(s::Spindle)
            [hrep(s.p).A * v .== hrep(s.p).b for v in vertices(s)]
        end
        function inc3(s::Spindle)
            [isapprox.(hrep(s.p).A * v, hrep(s.p).b) for v in vertices(s)]
        end

        @test sp.inc == inc2(sp) == inc3(sp)
    end

    # test the two improper faces: sp itself and the empty face
    @test incidentvertices(sp, Int[]) == collect(1:nvertices(sp))
    @test isempty(incidentvertices(sp, collect(1:Spindles.nhalfspaces(sp))))
end

#=
    for (i,row) in enumerate(eachrow(Bd))
        println(i, '\t', row[1:5])
    end
=#