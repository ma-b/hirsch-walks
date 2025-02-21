@testset "Check prescribed apex" begin
    # unit cube
    A = [1 0 0; 0 1 0; 0 0 1; -1 0 0; 0 -1 0; 0 0 -1]
    b = [1,1,1,1,1,1]
    cube = Polytope(A, b)

    for i=1:nvertices(cube)
        @test apices(cube, i) !== nothing
    end
end
