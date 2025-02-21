using Polyhedra: hrep

@testset "Tests for constructors" begin
    @testset "Explicit and implicit equation" begin
        p = Polytope([1 0; 0 1])
        
        # same, but with an implicit equation
        A = [-1 0; 1 1; 0 -1; -1 -1]
        b = [0, 1, 0, -1]
        q = Polytope(A, b)

        @test try apices(p) !== nothing
            true
        catch
            false
        end

        @test try apices(q) !== nothing
            true
        catch
            false
        end

        @test p == Polytope(collect(vertices(p)))
        @test p == q
    end

    @testset "Preserve indices" begin
        A = [1 0; 0 1; -1 0; 0 -1]
        b = [1, 1, 1, 1]
        s = Polytope(A, b)
        @test hrep(s.poly).A == A
        @test hrep(s.poly).b == b
    end
end