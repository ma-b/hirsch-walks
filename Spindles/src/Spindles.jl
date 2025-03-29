"""
Main module. The public API is listed below.
"""
module Spindles

import Polyhedra
import Graphs
using DelimitedFiles: readdlm
using RecipesBase
import Plots  # TODO remove dependency

export 
    Polytope,

    # representations and incidence
    vertices, 
    nvertices, 
    nhalfspaces, 
    incidentvertices, 
    incidenthalfspaces,
    facets, 
    nfacets, 
    impliciteqs,

    # combinatorics
    dim, 
    codim,
    facesofdim,
    nfacesofdim,
    graph,
    apices,
    isgood2face, 
    dist,

    # I/O
    readineq, 
    writeineq,

    # for compatibility with older versions
    plot2face  # TODO remove

include("polytopes.jl")
include("incidence.jl")
include("faceenum.jl")
include("dim.jl")
include("redundancy.jl")
include("goodfaces.jl")
include("plot/utils.jl")
include("plot/arrow.jl")
include("plot/plotrecipe.jl")
include("io.jl")

end # module