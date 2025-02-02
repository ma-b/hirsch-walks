"""
...
"""
module Spindles

using Polyhedra
using Graphs

export Spindle, vertices, nvertices, nfacets, apices

"""
    Spindle(A, b [,lib])

...
"""
mutable struct Spindle #{T}
    const P::Polyhedron #{T}
    const A::Matrix{T} where T<:Number
    const b::Vector{T} where T<:Number
    inc::Union{Nothing, Vector{BitVector}}  # vertex-facet incidences
    apices::Union{Nothing, Vector{Int}}
    graph::Union{Nothing, SimpleGraph}
    faces::Dict{Int, Union{Nothing, Vector{Vector{Int}}}}  # maps k to list of incident facets for each face of dim k
    dists::Union{Nothing, Dict{Int, Vector{Int}}}

    """
        Spindle(A, b [,lib])

    If `lib` is not specified, use the default library implemented in `Polyhedra`, 
    see the [`Polyhedra` documentation](https://juliapolyhedra.github.io/Polyhedra.jl/stable/polyhedron/).
    """
    function Spindle(A::Matrix{T}, b::Vector{T}, lib::Union{Nothing, Polyhedra.Library}=nothing) where T<:Number
        if size(A,1) != size(b,1)
            throw(DimensionMismatch("matrix A has dimensions $(size(A)), right-hand side vector b has length $(length(b))"))
        end
    
        if lib !== nothing
            P = polyhedron(hrep(A, b), lib)
        else
            # use default library
            P = polyhedron(hrep(A, b))
        end

        fdict = Dict(k => nothing for k=0:size(A,2))

        return new(P, A, b, nothing, nothing, nothing, fdict, nothing)
    end

    function Spindle(P::Polyhedron)
        A, b = hrep(P).A, hrep(P).b
        fdict = Dict(k => nothing for k=0:size(A,2))
        return new(P, A, b, nothing, nothing, nothing, fdict, nothing)
    end
end

nfacets(s::Spindle) = size(s.A, 1)  # TODO
dim(s::Spindle) = size(s.A, 2) #Polyhedra.dim(s.P)  # TODO

vertices(s::Spindle) = Polyhedra.points(s.P)  # returns an iterator
nvertices(s::Spindle) = Polyhedra.npoints(s.P)

inciscomputed(s::Spindle) = s.inc !== nothing
function computeinc!(s::Spindle)
    s.inc = Vector{BitVector}(undef, nvertices(s))

    nf = Polyhedra.nhalfspaces(s.P)
    @assert nf == nfacets(s)  # assuming no redundancy

    for v in eachindex(vertices(s))
        s.inc[v.value] = falses(nf)
        for f in Polyhedra.incidenthalfspaceindices(s.P, v)  # assuming they are numbered as in s.A
            s.inc[v.value][f.value] = true
        end
    end
end

"""
    incidentvertices(s, facets)

List the indices of all vertices of the spindle `s` that are incident with `facets`. Returns an iterator.
"""
function incidentvertices(s::Spindle, facets::Vector{Int})
    if !inciscomputed(s)
        computeinc!(s)
    end
    return (v for v=1:nvertices(s) if all(s.inc[v][facets]))
end


apicescomputed(s::Spindle) = s.apices !== nothing
function computeapices!(s::Spindle, apex::Union{Nothing, Int}=nothing)
    nv = nvertices(s)  # triggers vertex enumeration if necessary
    if !inciscomputed(s)
        computeinc!(s)
    end

    isapexpair(i,j) = all(s.inc[i] .⊻ s.inc[j])  # bitwise XOR

    if apex === nothing
        for i=1:nv, j=i+1:nv
            if isapexpair(i,j)
                s.apices = [i,j]
                return s.apices
            end
        end

        # no apex pair found
        error("not a spindle")
    else
        # check index, (assuming fits into Int)
        if apex < 1 || apex > nv
            throw(ArgumentError("not a vertex: $(apex)"))
        end

        for i=1:nv
            if i != apex && isapexpair(apex, i)
                s.apices = [apex, i]
                return s.apices
            end
        end
        error("not a spindle with $(apex) as an apex")
    end
end

"""
    apices(s [,apex])

Compute a pair of vertices (the **apices**) such that each facet of `s` is incident to exactly one of them, or throw
an error if no such pair exists.

If `apex` is specified, find a second vertex for an apex pair.
"""
function apices(s::Spindle, apex::Union{Nothing, Int}=nothing)
    if !apicescomputed(s) || (apex !== nothing && !(apex in s.apices))
        computeapices!(s, apex)
    end
    return s.apices
end


# 

include("faceenum.jl")
include("goodfaces.jl")
include("plots.jl")
include("util.jl")

end
