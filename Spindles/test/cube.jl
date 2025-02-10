@testset "Check prescribed apex" begin
    # unit cube
    A = [1 0 0; 0 1 0; 0 0 1; -1 0 0; 0 -1 0; 0 0 -1]
    b = [1,1,1,1,1,1]
    cube = Spindle(A, b)

    for i=1:nvertices(cube)
        @test try setapex!(cube, i)
            true
        catch
            false
        end
    end
end
