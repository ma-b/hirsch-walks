# tests taken from examples/permutahedra.jl
using Graphs: edges, src, dst

@testset "Tests for polytope generators" begin

    @testset "Hypercubes" begin
        n = 4
        lineseg = Polytope([[0], [1]])
        p = reduce(*, repeat([lineseg], n))

        @test cube(n) == 2p - ones(n)
        @test p == (cube(n) + ones(Int, n)) // 2

        @test cube(n) == -cube(n)  # standard hypercube is symmetric around 0

        @test lineseg == simplex(1)
        @test p == reduce(*, repeat([simplex(1)], n))
    end

    @testset "Permutahedra" begin
        n = 4
        directions = [Int.(1:n .== i) - Int.(1:n .== j) for i=1:n for j=i+1:n]
        p = collect(1:n) + sum(d -> Polytope([zeros(Int, n), d]), directions)

        @test dim(p) == n-1
        @test nvertices(p) == factorial(n)
        @test p == permutahedron(n)

        # the edge directions of `p` must be precisely the vectors in `directions`
        edge_directions = unique([
            reduce(-, collect(vertices(p))[[dst(e), src(e)]])
            for e in edges(graph(p))
        ])
        @test sort(directions) == sort(edge_directions)

        # as projections of hypercubes
        T = hcat(directions...)
        m = length(directions)
        c = 1//2 * (cube(m) + ones(Int, m))  # 0/1 hypercube in dimension m
        @test p == collect(1:n) + map(x -> T * x, c)
    end
end