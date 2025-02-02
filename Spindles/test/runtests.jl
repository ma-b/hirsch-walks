joinpath("..", "src") in LOAD_PATH || push!(LOAD_PATH, joinpath("..", "src"))

using Test
using Spindles

include("inc.jl")
include("polymake.jl")
include("cube.jl")
include("paper.jl")
include("rep.jl") # TODO