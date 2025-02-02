using Polyhedra
using Graphs: degree

@testset "Tests for incidence/graph computations" begin

    A, b, _ = readineq("../examples/s-25-5.txt", BigInt)  # TODO for others too
    sp = Spindle(A, b)

    Spindles.computeinc!(sp)

    @testset "Redundancy/dimension" begin
        @test nfacets(sp) == size(A, 1)  # we know that Ax <= b is irredundant
        @test Spindles.dim(sp) == 5
    end

    # distances must be symmetric
    @test dist_toapex(sp, apices(sp)...) == dist_toapex(sp, reverse(apices(sp))...)

    @testset "Count degenerate vertices" begin
        # find all degenerate vertices
        @test findall(degree(graph(sp)) .> 5) == findall(map(sum, sp.inc) .> 5)
    end

    @testset "Incidence matrix" begin
        # computeinc! << 2 < 3 (10x memory allocations)
        function inc2(s::Spindle)
            [s.A * v .== s.b for v in vertices(s)]
        end
        function inc3(s::Spindle)
            [isapprox.(s.A * v, s.b) for v in vertices(s)]
        end

        #=
        # alternative computation of vertex-facet incidences using Polyhedra.Indices
        function inctest(s::Spindle)
            inc = Vector(undef, nvertices(s))

            nf = Polyhedra.nhalfspaces(s.P)
            @test nf == nfacets(s)  # assuming no redundancy

            for v in eachindex(vertices(s))
                inc[v.value] = falses(nf)
                for f in Polyhedra.incidenthalfspaceindices(s.P, v)  # assuming they are numbered as in s.A
                    inc[v.value][f.value] = true
                end
            end

            return inc
        end
        =#

        @test sp.inc == inc2(sp) == inc3(sp)
    end
end

#=
    for (i,row) in enumerate(eachrow(Bd))
        println(i, '\t', row[1:5])
    end
=#