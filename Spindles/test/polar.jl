@testset "Polar duality" begin
    @testset "Origin not in interior" begin
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

    @testset "Issue in 1D" begin
        # Polyhedra.hrep for 1D interval around 0 (such as `cube(1)`)
        # is not of type MixedMatHRep but first needs to be converted
        @test try polarize(cube(1)); true catch; false end
    end
end
