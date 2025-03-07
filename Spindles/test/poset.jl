@testset "Test face poset" begin

    # start chain at k-dimensional face
    function testchain(p::Polytope, face::Vector{Int}, k::Int; testenum::Bool=false)
        mc = Spindles.maxchain(p, face)
        for (i,f) in enumerate(mc)
            # the i-th chain element is a face of dimension i+k-1 (since we start counting dimensions at k)
            # so it must consist of at least dim-(i+k-1) halfspace indices
            @test length(f) >= dim(p) - (i+k-1)

            # reverse-engineer face from incident vertices
            vs = incidentvertices(p, f)

            # do not reduce over empty `vs`
            @test isempty(vs) || sort(f) == incidenthalfspaces(p, vs)
            # `vs` can only be empty for the empty face at i=1 (if k=-1)
            @test !isempty(vs) || (i == 1 && k == -1)

            # test against (expensive!) face enumeration only if option is explicitly set
            @test !testenum || sort(f) in facesofdim(p, i+k-1)
        end
    end

    for filename in ["s-25-5", "s-28-5", "s-48-5"]
        @testset "Test chain of faces of $(filename)" begin
            A, b, _ = readineq(joinpath("..", "examples", filename*".txt"), BigInt)
            p = Polytope(A, b)

            @test dim(p) == 5
            testchain(p, collect(1:nhalfspaces(p)), -1; testenum=true)

            # pick a random vertex and start maximal chain from there
            v = rand(1:nvertices(p))
            #v = findfirst(i -> !(i in apices(p)), 1:nvertices(p))
            @test dim(p) == length(Spindles.maxchain(p, findall(p.inc[v]))) - 1

            testchain(p, findall(p.inc[v]), 0; testenum=true)
        end
    end

    #=
    @testset "Test high-dim" begin
        A, b, _ = readineq(joinpath("..", "examples", "s-25.txt"), BigInt)
        s = Polytope(A, b)
        @test dim(p) == 20
        testchain(p, collect(1:nhalfspaces(p)), -1) 
    end=#
end