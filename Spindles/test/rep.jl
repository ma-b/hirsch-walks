using Polyhedra: polyhedron, vrep, hrep

@testset "Tests for constructors" begin
    @testset "Explicit equation" begin
        p = polyhedron(vrep([1 0; 0 1]))

        @test try apices(Polytope(p)) !== nothing
            true
        catch
            false
        end
    end

    @testset "Implicit equations" begin
        A = [-1 0; 1 1; 0 -1; -1 -1]
        b = [0, 1, 0, -1]
        p = polyhedron(hrep(A, b))

        @test try apices(Polytope(p)) !== nothing
            true
        catch
            false
        end

        @test try apices(Polytope(A, b)) !== nothing
            true
        catch
            false
        end
    end

    @testset "Preserve indices" begin
        A = [1 0; 0 1; -1 0; 0 -1]
        b = [1, 1, 1, 1]
        s = Polytope(A, b)
        @test hrep(s.poly).A == A
        @test hrep(s.poly).b == b
    end
end