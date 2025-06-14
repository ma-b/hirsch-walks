module Polytopes

import Polyhedra
import Graphs

export 
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

mutable struct Polytope{T}
    const poly::Polyhedra.Polyhedron{T}
    inc::Union{Nothing, Vector{BitVector}}  # vertex-halfspace incidences
    isfacet::Union{Nothing, BitVector}  # indicates which constraints from the H-representation 
        # of `poly` belong to a possible choice system of facet-defining inequalities
    isimpliciteq::Union{Nothing, BitVector}  # indicates implicit equations
    graph::Union{Nothing, Graphs.SimpleGraph{Int}}
    dim::Union{Nothing, Int}
    faces::Dict{Int, Vector{Vector{Int}}}  # maps k to list of incident halfspaces for each face of dim k
    dists::Union{Nothing, Dict{Int, Vector{Int}}}  # cache (sparse) graph distance matrix

    function Polytope{T}(p::Polyhedra.Polyhedron{T}) where T
        # First check whether `p` is a polytope. This triggers the computation of V-representation if necessary.
        # This V-representation has no redundancy, as asserted by
        # https://juliapolyhedra.github.io/Polyhedra.jl/stable/polyhedron/#Polyhedra.doubledescription
        if Polyhedra.nlines(p) + Polyhedra.nrays(p) > 0
            throw(ArgumentError("got an unbounded polyhedron"))
        end

        new{T}(p, nothing, nothing, nothing, nothing, nothing, Dict{Int, Vector{Vector{Int}}}(), Dict{Int, Vector{Int}}())
    end
end
# constructor that infers the element type T from the polyhedron
Polytope(p::Polyhedra.Polyhedron{T}) where T = Polytope{T}(p)

function Polytope(rep::Union{Polyhedra.MixedMatHRep, Polyhedra.MixedMatVRep}, lib::Union{Nothing, Polyhedra.Library}=nothing)
    # let `Polyhedra.polyhedron` do the type promotion if necessary
    if lib === nothing
        p = Polyhedra.polyhedron(rep)
    else
        p = Polyhedra.polyhedron(rep, lib)
    end
    Polytope(p)
end

"""
    Polytope(V::AbstractVector{AbstractVector})

Create a polytope from the convex hull of the collection of points `V`.
"""
function Polytope(V::AbstractVector{<:AbstractVector{<:Real}}, lib::Union{Nothing, Polyhedra.Library}=nothing)
    # first convert to MixedMatVRep type to get the correct polyhedron (sub)type
    rep = Polyhedra.MixedMatVRep(Polyhedra.vrep(V))
    remove_vredundancy(Polytope(rep, lib))
end

"""
    Polytope(V::AbstractMatrix)

Create a polytope from the convex hull of the rows of `V`.
"""
function Polytope(V::AbstractMatrix{<:Real}, lib::Union{Nothing, Polyhedra.Library}=nothing)
    remove_vredundancy(Polytope(Polyhedra.vrep(V), lib))
end

"""
    Polytope(A::AbstractMatrix, b::AbstractVector)

Create a polytope from its H-representation ``Ax \\le b``. 
If the polyhedron defined by ``Ax \\le b`` is unbounded, throw an error.
"""
function Polytope(A::AbstractMatrix{<:Real}, b::AbstractVector{<:Real}, lib::Union{Nothing, Polyhedra.Library}=nothing)
    if size(A,1) != size(b,1)
        throw(DimensionMismatch("matrix A has dimensions $(size(A)), right-hand side vector b has length $(length(b))"))
    end
    Polytope(Polyhedra.hrep(A, b), lib)
end

Base.show(io::IO, p::Polytope{T}) where T = print(io, "Polytope{$T} in $(ambientdim(p))-space")
Base.summary(p::Polytope) = "$(typeof(p))"

# avoid broadcasting over polytopes, see https://docs.julialang.org/en/v1/manual/interfaces/#man-interfaces-broadcasting
Base.broadcastable(p::Polytope) = Ref(p)


include("representations.jl")
include("faceenum.jl")
include("dim.jl")
include("distances.jl")
include("properties.jl")
include("generators.jl")
include("setoperators.jl")
include("operators.jl")

end # module