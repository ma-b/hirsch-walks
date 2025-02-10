using Polyhedra: polyhedron, vrep, hrep

@testset "Tests for constructors" begin
    @testset "Explicit equation" begin
        p = polyhedron(vrep([1 0; 0 1]))

        @test try Spindle(p)
            true
        catch
            false
        end
    end

    @testset "Implicit equations" begin
        A = [-1 0; 1 1; 0 -1; -1 -1]
        b = [0, 1, 0, -1]
        p = polyhedron(hrep(A, b))

        @test try s = Spindle(p)
            true
        catch
            false
        end

        @test try Spindle(A, b)
            true
        catch
            false
        end
    end

    @testset "Preserve indices" begin
        A = [1 0; 0 1; -1 0; 0 -1]
        b = [1, 1, 1, 1]
        s = Spindle(A, b)
        @test hrep(s.p).A == A
        @test hrep(s.p).b == b
    end
end