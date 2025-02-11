using Graphs: nv, ne
using Polyhedra: hrep

@testset "Tests for face enumeration" begin

    for filename in ["s-25-5", "s-28-5", "s-48-5"]
        A, b, _ = readineq(joinpath("..", "examples", filename*".txt"), BigInt)
        s = Spindle(A, b)

        @testset "Test $(filename) against polymake" begin
            # parse polymake output from Hasse diagram command and return list of incident facets for each face
            function readpolymake(filename::AbstractString)
                str = read(filename, String)
                
                strlist = split(replace(strip(str), r"\n|\r|{" => ""), "}")[1:end-1]
                return [map(x -> parse(Int, x), split(f)) for f in strlist]
            end

            for k=-1:size(hrep(s.p).A, 2)
                ps = readpolymake(joinpath("polymake", "$(filename)_f$(k).txt"))
                # convert 0-based polymake indices to 1-based Julia indices
                ps = map(x->x.+1, ps)
                @test sort(facesofdim(s, k)) == sort(ps)
            end
        end

        @testset "Length test for $(filename)" begin
            @test nfacesofdim(s, -1) == 1
            @test nfacesofdim(s, 0) == nvertices(s)
            @test nv(graph(s)) == nvertices(s)
            @test nfacesofdim(s, 1) == ne(graph(s))
            @test nfacesofdim(s, 4) == Spindles.nhalfspaces(s)
            @test nfacesofdim(s, 5) == 1
            @test nfacesofdim(s, 6) == 0
        end
    end
end