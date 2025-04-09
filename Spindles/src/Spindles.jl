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
    incidentvertices, 
    inequalities,
    ineqindices,
    tightinequalities,
    facets,
    nfacets,
    affinehull,
    ambientdim,

    # combinatorics
    dim, 
    codim,
    facesofdim,
    nfacesofdim,
    graph,
    apices, 
    dist,
    issimple,
    issimplicial,

    # generators
    simplex,
    cube,
    crosspolytope,
    permutahedron,
    polarize

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