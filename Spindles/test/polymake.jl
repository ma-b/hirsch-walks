using Printf

@testset "Tests for faceenum.jl" begin

    B = Spindles.readrational("../examples/s-25-5.txt", BigInt)
    d = ones(Rational{BigInt}, size(B,1))
    s = Spindles.Spindle(B, d)

    @testset "Test against polymake" begin
        # parse polymake output from Hasse diagram command and return list of incident facets for each face
        function readpolymake(filename::AbstractString)
            str = read(filename, String)
            
            strlist = split(replace(strip(str), r"\n|\r|{" => ""), "}")[1:end-1]
            return [map(x -> parse(Int, x), split(f)) for f in strlist]
        end

        # TODO k=size(B,2)
        for k=0:size(B,2)-1
            ps = readpolymake(@sprintf("s-25-5_f%d.txt", k))
            # convert 0-based polymake indices to 1-based Julia indices
            ps = map(x->x.+1, ps)
            @test sort(Spindles.facesofdim(s, k)) == sort(ps)
        end
    end

    @testset "Length test" begin
        @test nfacesofdim(s, -1) == 1
    end
end