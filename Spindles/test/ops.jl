@testset "Tests for operators" begin
    p = Polytope([[0, 0], [1, 0], [0, 1]])
    @test 2p == p + p
    @test 1//2 * p == 0.5 * p == p / 2 == p // 2

    @test !([1, 1] in p)
    @test (sum(vertices(p)) / nvertices(p)) in p

    @test p == union((Polytope([v]) for v in vertices(p))...)
    @test intersect((Polytope([v]) for v in vertices(p))...) |> isempty
    @test !isempty(p)
    @test issubset(p, p)
end