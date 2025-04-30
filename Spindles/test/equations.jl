using Polyhedra: polyhedron, hrep

@testset "Explicit vs implicit equations" begin
    A = [-1 0; 1 0; 0 -1; 0 1]
    b = [0, 1, 0, 0]

    # two implicit equations
    p = Polytope(A, b)
    # make one of them an explicit equality constraint
    q = Polytope(polyhedron(hrep(A, b, BitSet([3]))))

    @test p == q

    @test inequalities(p) == (A, b)
    @test inequalities(q) == (A[[1,2,4],:], b[[1,2,4]])
    @test affinehull(p) == affinehull(q)
    @test facets(p) == facets(q)
end