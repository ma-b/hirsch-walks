using Printf
using Graphs: nv, ne

@testset "Tests for faceenum.jl" begin

    B = readrational("../examples/s-25-5.txt", BigInt)
    d = ones(Rational{BigInt}, size(B,1))
    s = Spindle(B, d)

    @testset "Test against polymake" begin
        # parse polymake output from Hasse diagram command and return list of incident facets for each face
        function readpolymake(filename::AbstractString)
            str = read(filename, String)
            
            strlist = split(replace(strip(str), r"\n|\r|{" => ""), "}")[1:end-1]
            return [map(x -> parse(Int, x), split(f)) for f in strlist]
        end

        for k=-1:size(B,2)
            ps = readpolymake(@sprintf("s-25-5_f%d.txt", k))
            # convert 0-based polymake indices to 1-based Julia indices
            ps = map(x->x.+1, ps)
            @test sort(facesofdim(s, k)) == sort(ps)
        end
    end

    @testset "Length test" begin
        @test nfacesofdim(s, -1) == 1
        @test nfacesofdim(s, 0) == nvertices(s)
        @test nv(graph(sp)) == nvertices(sp)
        @test nfacesofdim(s, 1) == ne(graph(s))
        @test nfacesofdim(s, 4) == nfacets(s)
        @test nfacesofdim(s, 5) == 1
        @test nfacesofdim(s, 6) == 0
    end
end
