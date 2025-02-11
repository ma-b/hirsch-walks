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

        @testset "Test combinatorial dim" begin
            # pick a non-apex and start maximal chain from there
            v = findfirst(i -> !(i in apices(s)), 1:nvertices(s))
            @test dim(s) == length(Spindles.maxchain(s, findall(s.inc[v]))) - 1

            mc = Spindles.maxchain(s, collect(1:Spindles.nhalfspaces(s)))
            for (i,f) in enumerate(mc)
                # the i-th chain element is a face of dimension i-2 (since we start counting dimensions at -1)
                # so it must consist of at least dim-(i-2) halfspace indices
                @test length(f) >= dim(s)-i+2

                # reverse-engineer face from incident vertices
                vs = collect(incidentvertices(s, f))

                # do not reduce over empty `vs`
                @test isempty(vs) || sort(f) == findall(reduce(.&, s.inc[vs]))
                # `vs` can only be empty for the empty face at i=1
                @test !isempty(vs) || i == 1
            end
        end
    end
end
