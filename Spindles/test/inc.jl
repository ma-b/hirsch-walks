using Polyhedra
using Graphs: degree

@testset "Tests for incidence/graph computations" begin

    B = readrational("../examples/s-25-5.txt", BigInt)  # TODO for others too
    d = ones(Rational{BigInt}, size(B, 1))
    sp = Spindle(B, d)

    Spindles.computeinc!(sp)

    @testset "Redundancy/dimension" begin
        @test nfacets(sp) == size(B, 1)  # we know that Bx <= d is irredundant
        @test Spindles.dim(sp) == 5
    end

    # distances must be symmetric
    @test dist_toapex(sp, apices(sp)...) == dist_toapex(sp, reverse(apices(sp))...)

    @testset "Count degenerate vertices" begin
        # find all degenerate vertices
        @test findall(degree(graph(sp)) .> 5) == findall(map(sum, sp.inc) .> 5)
    end

    @testset "Incidence matrix" begin
        # alternative computation of vertex-facet incidences using Polyhedra.Indices
        function inctest(s::Spindle)
            inc = Vector(undef, nvertices(s))

            nf = Polyhedra.nhalfspaces(s.P)
            @test nf == nfacets(s)  # assuming no redundancy

            for v in eachindex(vertices(s))
                inc[v.value] = falses(nf)
                for f in Polyhedra.incidenthalfspaceindices(s.P, v)  # assuming they are numbered as in s.B
                    inc[v.value][f.value] = true
                end
            end

            return inc
        end

        @test sp.inc == inctest(sp)
    end
end

#=
    for (i,row) in enumerate(eachrow(Bd))
        println(i, '\t', row[1:5])
    end
=#