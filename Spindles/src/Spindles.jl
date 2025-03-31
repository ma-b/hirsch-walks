module Spindles

import Graphs
using DelimitedFiles: readdlm

export 
    isgood2face,

    # I/O
    readineq, 
    writeineq,
    
    # --- and everything from Polytopes: ---
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
    dist,

    # generators
    simplex,
    cube,
    crosspolytope,
    permutahedron,
    polarize,

    # for compatibility with older versions
    plot2face

"""
    Spindles

A lightweight package for representing and analyzing polytopes.
"""
#Spindles

include("Polytopes/Polytopes.jl")
using .Polytopes

include("goodfaces.jl")
include("io.jl")

end # module