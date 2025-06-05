module PlotsExt

using Spindles
using RecipesBase
import Plots  # TODO remove dependency
import Graphs, Polyhedra  # TODO remove Polyhedra dep

include("utils.jl")
include("arrow.jl")
include("plotrecipe.jl")

end # module