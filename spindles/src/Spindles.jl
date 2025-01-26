module Spindles

using Polyhedra
using Graphs

mutable struct Spindle
    P::Polyhedron
    B::Matrix{T} where T<:Number
    d::Vector{T} where T<:Number
    inc::Union{Nothing, Vector{BitVector}}  # vertex-facet incidences
    apices::Union{Nothing, Vector{Int}}  # TODO tuple or vector?
    graph::Union{Nothing, SimpleGraph}
    faces::Dict{Int, Union{Nothing, Vector{Vector{Int}}}}  # maps k to list of facets for each face of dim k

    """
        Spindle(B, d [,lib])

    If `lib` is not specified, use the default library implemented in `Polyhedra`, 
    see [here](https://juliapolyhedra.github.io/Polyhedra.jl/stable/polyhedron/).
    """
    function Spindle(B::Matrix{T}, d::Vector{T}, lib::Union{Nothing, Polyhedra.Library}=nothing) where T<:Number
        if size(B,1) != size(d,1)
            error("dimension mismatch: along axis 1, matrix B has $(size(B,1)) elements and d has $(size(d,1))")
        end
    
        if lib !== nothing
            P = polyhedron(hrep(B,d), lib)
        else
            # use default library
            P = polyhedron(hrep(B,d))
        end

        fdict = Dict(k => nothing for k=0:size(B,2))

        return new(P, B, d, nothing, nothing, nothing, fdict)
    end

    function Spindle(P::Polyhedron)
        # extract B and d from homogenized representation
        B = -hrep(P).A[:,2:end]
        d = hrep(P).A[:,1]
        fdict = Dict(k => nothing for k=0:size(B,2))

        return new(P, B, d, nothing, nothing, nothing, fdict)
    end
end

dim(s::Spindle) = Polyhedra.dim(s.P)

vertices(s::Spindle) = Polyhedra.points(s.P)  # returns an iterator
nvertices(s::Spindle) = Polyhedra.npoints(s.P)

inciscomputed(s::Spindle) = s.inc !== nothing
function computeinc!(s::Spindle)
    s.inc = [isapprox.(s.B * v, s.d) for v in vertices(s)]
end


apicescomputed(s::Spindle) = s.apices !== nothing
function computeapices!(s::Spindle, apex::Union{Nothing, Int}=nothing)  # or write two methods for function
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
            error("not a vertex: $(apex)")
        end

        for i=1:nv
            if i != apex && isapexpair(apex, i)
                s.apices = [apex, i]
                return s.apices
            end
        end
        error("not a spindle with $(apex) as an apex")  # TODO more specific error type
    end
end

"""
    apices(s [,apex])

If `apex` is unspecified, ...
"""
function apices(s::Spindle, apex::Union{Nothing, Int}=nothing)
    if !apicescomputed(s) || !(apex in s.apices)
        computeapices!(s, apex)
    end
    return s.apices
end


# 

include("faceenum.jl")
include("util.jl")

end