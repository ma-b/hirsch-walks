module Spindles

using Polyhedra

mutable struct Spindle
    P::Polyhedron
    B::Matrix{T} where T<:Number
    d::Vector{T} where T<:Number

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

        return new(P, B, d)
    end

    function Spindle(P::Polyhedron)
        B = -hrep(P).A[:,2:end]
        d = hrep(P).A[:,1]
        return new(P, B, d)
    end
end

include("util.jl")

end