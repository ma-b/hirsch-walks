if !(joinpath("..", "src") in LOAD_PATH)
    push!(LOAD_PATH, joinpath("..", "src"))
end

using Test
using Spindles

include("polymake.jl")
include("graph_degen.jl")