"""
Main module in `Spindles.jl`.

# Exports
* [`Spindle`](@ref Spindles.Spindle)
* [`apices`](@ref Spindles.apices)
* [`vertices`](@ref Spindles.vertices)
* [`nvertices`](@ref Spindles.nvertices)
* ...
"""
module Spindles

using Polyhedra
using Graphs

export Spindle, vertices, nvertices, apices

"""
    Spindle

Main type that represents a spindle...
"""
mutable struct Spindle
    const P::Polyhedron
    apices::Union{Nothing, Vector{Int}}
    inc::Union{Nothing, Vector{BitVector}}  # vertex-halfspace incidences
    graph::Union{Nothing, SimpleGraph}
    faces::Dict{Int, Vector{Vector{Int}}}  # maps k to list of incident halfspaces for each face of dim k
    dists::Union{Nothing, Dict{Int, Vector{Int}}}

    function Spindle(P::Polyhedron)
        nlines(P) + nrays(P) == 0 || throw(ArgumentError("not a polytope"))  # TODO

        s = new(P, nothing, nothing, nothing, Dict{Int, Vector{Vector{Int}}}(), nothing)
        computeapices!(s)
        return s
    end
end

@doc"""
    Spindle(A, b [,lib])

Create a spindle from its inequality description with coefficient matrix `A` and right-hand side vector `b`.

The optional argument `lib` allows to specify a library for polyhedral computations that implements
the interface of [`Polyhedra`](https://juliapolyhedra.github.io/Polyhedra.jl/). A list of all supported libraries
can be found on the [JuliaPolyhedra website](https://juliapolyhedra.github.io/).

If `lib` is not specified, use the default library implemented in `Polyhedra` 
(see the [`Polyhedra` documentation](https://juliapolyhedra.github.io/Polyhedra.jl/stable/polyhedron/)).

!!! note

    `A` and `b` are not checked for the presence of redundant rows or implicit equations.

---

    Spindle(P::Polyhedron)

Create a spindle directly from a `Polyhedron` `P`.
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

    return Spindle(P)
end

#nfacets(s::Spindle) = nhalfspaces(s.P) #size(hrep(s.P).A, 1)  # TODO
dim(s::Spindle) = Polyhedra.dim(s.P, true)  # TODO

"""
    vertices(s)

Returns an iterator over the vertices of the spindle `s`.
"""
vertices(s::Spindle) = Polyhedra.points(s.P)

"""
    nvertices(s)

Count the vertices of `s`.
"""
nvertices(s::Spindle) = Polyhedra.npoints(s.P)

inciscomputed(s::Spindle) = s.inc !== nothing
function computeinc!(s::Spindle)
    s.inc = Vector{BitVector}(undef, nvertices(s))

    nf = Polyhedra.nhalfspaces(s.P)

    for v in eachindex(vertices(s))
        s.inc[v.value] = falses(nf)
        for f in Polyhedra.incidenthalfspaceindices(s.P, v)
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
        error("not a spindle: could not find two apices")
    else
        if apex < 1 || apex > nv
            throw(ArgumentError("not a vertex: $(apex)"))
        end

        for i=1:nv
            if i != apex && isapexpair(apex, i)
                s.apices = sort([apex, i])
                return s.apices
            end
        end
        error("not a spindle with $(apex) as an apex")
    end
end

"""
    apices(s [,apex])

Compute a pair of vertices (the *apices*) such that each facet of `s` is incident to exactly one of them, or throw
an error if no such pair exists.

If additionally given the index of a vertex `apex`, try to find a vertex distinct from `apex` such that the two vertices
are apices of `s`.
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
include("io.jl")

end # module Spindles
