# taken from doctests
@testset "I/O" begin
    A = [1 0; 0 1; -1 0; 0 -1]
    b = [1, 1, 1, 1]
    labels = ["α", "β", "γ", "δ"]

    fname = "iotest.txt"
    writeineq(fname, A, b, labels; comments=["A nice polytope"])
    
    @test read(fname, String) == "# A nice polytope\nα  1  -1   0\nβ  1   0  -1\nγ  1   1   0\nδ  1   0   1"
    @test readineq(fname, Int) == (A, b, labels)
    
    rm(fname)
end