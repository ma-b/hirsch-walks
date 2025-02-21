@testset "Verify graphs from paper" begin

    function testfaces(filename::AbstractString, faces::Vector{Vector{Int}})
        A, b, _ = readineq(filename, BigInt)
        s = Polytope(A, b)

        apx = apices(s)
        @test apx !== nothing

        gfs = [f for f in facesofdim(s, 2) if isgood2face(s, f, apx...).good]
        @test length(gfs) == 32

        @test all(f in facesofdim(s, 2) for f in faces)
    end

    function testfaces(filename::AbstractString, faces::Vector{String}=String[])
        _, _, labels = readineq(filename, BigInt)

        testfaces(filename, [map(x -> findfirst(labels .== x), split(f)) for f in faces])
    end

    faces = [
        [15,17,21],  [3,15,17], [3,9,15], 
        [13,18,22],  [2,9,11], [2,9,13], [2,13,18], [9,13,22],
        [2,8,9],     [2,8,18], [2,8,16], [2,16,22], [16,21,22],
        [3,5,9],     [3,5,13], [3,13,23], [13,21,23]
    ]
    testfaces("../examples/s-25-5.txt", faces)

    faces = [
        "10+ 11+ 13+",  "3+ 10+ 13+", "3+ 4+ 10+", "1+ 3+ 4+",
        "8+ 9+ 13+",    "2+ 9+ 13+", "1+ 2+ 9+",
        "1+ 2+ 6+",     "2+ 6+ 10+", "2+ 10+ 11+", "8+ 10+ 11+",
        "3+ 4+ 6+",     "3+ 6+ 9+", "3+ 8+ 9+"
    ]
    faces = map(faces) do f
        replace(f, "+" => "⁺")  # use unicode symbol
    end
    testfaces("../examples/s-28-5.txt", faces)

    testfaces("../examples/s-48-5.txt", Vector{Int}[])  # symmetric spindle
end