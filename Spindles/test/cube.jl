@testset "Check prescribed apex" begin
    # unit cube
    A = [1 0 0; 0 1 0; 0 0 1; -1 0 0; 0 -1 0; 0 0 -1]
    b = [1,1,1,1,1,1]
    cube = Spindle(A, b)

    success = true
    for i=1:nvertices(cube)
        try
            setapex!(cube, i)
        catch
            success = false 
        end
    end
    @test success
end
