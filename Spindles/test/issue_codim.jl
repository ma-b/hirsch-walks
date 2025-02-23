@testset "Issue: codimension of face not given by all incident facets" begin
    p = Polytope([-1 0; 1 0; 0 -1; 0 1], [0, 1, 0, 1])

    dims = Dict(
        Int[] => 2,
        1 => 1,
        [1, 3] => 0,
        1:2 => -1, # empty face
        1:3 => -1, # empty face
        1:4 => -1, # empty face
    )

    for (f,d) in dims 
        @test dim(p, f)   == d
        @test codim(p, f) == 2-d
    end
end