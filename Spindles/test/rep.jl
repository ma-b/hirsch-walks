using Polyhedra: hrep

@testset "Tests for representations" begin
    A, b, _ = readineq("../examples/s-25-5.txt", BigInt)
    s1 = Spindle(A, b)
    s2 = Spindle(s1.P)
    s3 = Spindle(s2.A, s2.b)

    @test hrep(s1.P).A == s1.A
    @test s1.A == s2.A == s3.A  # TODO
    @test s1.b == s2.b == s3.b  # TODO
    @test s1.P == Spindle(s1.A,s1.b).P  # fails
    @test s1.P == s2.P
    @test s2.P == s3.P # fails
    #@test s == s2  # TODO

    #using Polyhedra
    #@test nvertices(s1) == npoints(s1.P)
end