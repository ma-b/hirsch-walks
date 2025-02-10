using Polyhedra: polyhedron, vrep, hrep

@testset "Tests for constructors" begin
    @testset "Line segment" begin
        p = polyhedron(vrep([1 0; 0 1]))

        @test try Spindle(p)
            true
        catch
            false
        end
    end

    @testset "Implicit equations" begin
        A = [-1 0;1 1;0 -1; -1 -1]
        b = [0,1,0,-1]
        p = polyhedron(hrep(A, b))

        @test try s = Spindle(p)
            true
        catch
            false
        end

        @test apices(s) == [1,2]  # the only two vertices

        @test try Spindle(A, b)
            true
        catch
            false
        end
    end
end