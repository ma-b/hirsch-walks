using Graphs: degree

@testset "Tests for incidence/graph computations" begin
    B = readrational("../examples/s-25-5.txt", BigInt)
    d = ones(Rational{BigInt}, size(B, 1))
    s = Spindle(B, d)

    # find all degenerate vertices
    @test findall(degree(graph(s)) .> 5) == findall(map(sum, s.inc) .> 5)
end

#=
    for (i,row) in enumerate(eachrow(Bd))
        println(i, '\t', row[1:5])
    end
=#