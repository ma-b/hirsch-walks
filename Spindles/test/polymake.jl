using Graphs: nv, ne
using Polyhedra: hrep

@testset "Tests for face enumeration" begin

    for filename in ["s-25-5", "s-28-5", "s-48-5"]
        A, b, _ = readineq(joinpath("..", "examples", filename*".txt"), BigInt)
        s = Polytope(A, b)

        # test apices
        apx = apices(s)
        @test apx !== nothing
        apx = collect(vertices(s))[apx]
        @test [1,0,0,0,0] in apx
        @test [-1,0,0,0,0] in apx

        # verify that the given inequality description is minimal -- in four equivalent ways:
        @test all(codim.(s, 1:nhalfspaces(s)) .== 1)
        @test all(dim.(s, 1:nhalfspaces(s)) .== dim(s)-1)
        @test nfacets(s) == nhalfspaces(s)
        @test isempty(impliciteqs(s))

        @testset "Test $(filename) against polymake" begin
            # parse polymake output from Hasse diagram command and return list of incident facets for each face
            function readpolymake(filename::AbstractString)
                str = read(filename, String)
                
                strlist = split(replace(strip(str), r"\n|\r|{" => ""), "}")[1:end-1]
                return [map(x -> parse(Int, x), split(f)) for f in strlist]
            end

            for k=-1:5
                ps = readpolymake(joinpath("polymake", "$(filename)_f$(k).txt"))
                # convert 0-based polymake indices to 1-based Julia indices
                ps = map(x->x.+1, ps)
                @test sort(facesofdim(s, k)) == sort(ps)
            end
        end

        @testset "Length test for $(filename)" begin
            @test nfacesofdim(s, -1) == 1
            @test nfacesofdim(s, 0) == nvertices(s) == nv(graph(s))
            @test nfacesofdim(s, 1) == ne(graph(s))
            @test nfacesofdim(s, 4) == nfacets(s) == nhalfspaces(s)
            @test nfacesofdim(s, 5) == 1
            @test nfacesofdim(s, 6) == 0
            @test dim(s) == 5
        end
    end
end