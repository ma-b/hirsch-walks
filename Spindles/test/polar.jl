@testset "Polar duality" begin
    p = Polytope([0 0; 1 0; 0 1; 1 1])
    # `p` does not contain 0 in its interior and hence `polarize` must throw an error
    @test try polarize(p); false catch; true end

    # average of vertices is an interior point, so shift by negative to make 0 an interior point
    avg = sum(vertices(p)) / length(vertices(p))
    q = p + -avg
    @test try polarize(q); true catch; false end

    r = polarize(polarize(q))
    @test q == r
    @test p == r + avg
end