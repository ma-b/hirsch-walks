joinpath("..", "src") in LOAD_PATH || push!(LOAD_PATH, joinpath("..", "src"))

using Test
using Spindles

include("rep.jl")
include("inc.jl")
include("cube.jl")
include("polymake.jl")
include("poset.jl")
include("paper.jl")
include("redundancy.jl")