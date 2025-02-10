using Polyhedra: polyhedron, vrep, hrep

@testset "Tests for constructors" begin
    # TODO 1-dimensional
    p = polyhedron(vrep([1 0; 0 1]))
    Spindle(p)
end

#=
@testset "Tests for representations" begin
    A, b, _ = readineq("../examples/s-25-5.txt", BigInt)
    s1 = Spindle(A, b)
    s2 = Spindle(s1.p)
    s3 = Spindle(hrep(s2.p).A, hrep(s2.p).b)

    #@test nvertices(s1) == npoints(s1.p)
end
=#