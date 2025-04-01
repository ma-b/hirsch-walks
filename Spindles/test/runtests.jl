joinpath("..", "src") in LOAD_PATH || push!(LOAD_PATH, joinpath("..", "src"))

using Test
using Spindles

include("representations.jl")
include("inc.jl")
include("polymake.jl")
include("poset.jl")
include("paper.jl")
include("redundancy.jl")
include("issue_codim.jl")
include("cube.jl")
include("polar.jl")