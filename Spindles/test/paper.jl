@testset "Verify graphs from paper" begin
    
    A, b, _ = readineq("../examples/s-25-5.txt", BigInt)
    s = Spindle(A, b)

    gfs = [f for f in facesofdim(s, 2) if isgood2face(s, f).good]
    @test length(gfs) == 32

    testfaces = [
        [3,15,17], [3,9,15], 
        [2,9,11], [2,9,13], [2,13,18], [9,13,22],
        [2,8,18], [2,8,16], [2,16,22], [16,21,22],
        [3,5,13], [3,13,23], [13,21,23]
    ]
    @test all(f in facesofdim(s, 2) for f in testfaces)
end