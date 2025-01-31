if !(joinpath("..", "src") in LOAD_PATH)
    push!(LOAD_PATH, joinpath("..", "src"))
end

using Test
using Spindles

include("polymake.jl")
include("inc.jl")
include("cube.jl")
include("paper.jl")