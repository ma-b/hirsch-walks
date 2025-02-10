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

import Polyhedra
using Graphs

export Spindle, vertices, nvertices, incidentvertices, apices, setapex!

"""
    Spindle{T}

Main type that represents a spindle.
"""
mutable struct Spindle{T}
    const p::Polyhedra.Polyhedron{T}
    apices::Union{Nothing, Vector{Int}}
    inc::Union{Nothing, Vector{BitVector}}  # vertex-halfspace incidences
    graph::Union{Nothing, SimpleGraph{Int}}
    faces::Dict{Int, Vector{Vector{Int}}}  # maps k to list of incident halfspaces for each face of dim k
    dists::Union{Nothing, Dict{Int, Vector{Int}}}

    function Spindle{T}(p::Polyhedra.Polyhedron{T}) where T
        # first check whether P is a polytope
        Polyhedra.nlines(p) + Polyhedra.nrays(p) == 0 || throw(ArgumentError("got an unbounded polyhedron"))  # TODO triggers computation of V-representation
        
        # create a preliminary object with apices not set
        s = new{T}(p, nothing, nothing, nothing, Dict{Int, Vector{Vector{Int}}}(), nothing)

        # try to find two apices
        s.apices = computeapices(s)
        if s.apices === nothing
            throw(ArgumentError("not a spindle: cannot find two apices"))
        end

        return s
    end
end

Spindle(p::Polyhedra.Polyhedron{T}) where T = Spindle{T}(p)

@doc"""
    Spindle(A, b [,lib])

Create a spindle from its inequality description with coefficient matrix `A` and right-hand side vector `b`.

The optional argument `lib` allows to specify a library for polyhedral computations that implements
the interface of [`Polyhedra`](https://juliapolyhedra.github.io/Polyhedra.jl/). A list of all supported libraries
can be found on the [JuliaPolyhedra website](https://juliapolyhedra.github.io/).

If `lib` is not specified, use the default library implemented in `Polyhedra` 
(see the [`Polyhedra` documentation](https://juliapolyhedra.github.io/Polyhedra.jl/stable/polyhedron/)).

The above is equivalent to
```julia
using Polyhedra: polyhedron, hrep
#lib = ...
Spindle(polyhedron(hrep(A, b), lib))
```

!!! note

    `A` and `b` are not checked for the presence of redundant rows or implicit equations.
---

    Spindle{T}(p::Polyhedron{T})

Create a spindle directly from a `Polyhedron` `p`.
If not specified the element type `T` is the element type of `p`.
"""
function Spindle(A::Matrix{T}, b::Vector{T}, lib::Polyhedra.Library = Polyhedra.DefaultLibrary{T}()) where T #<:Number
    if size(A,1) != size(b,1)
        throw(DimensionMismatch("matrix A has dimensions $(size(A)), right-hand side vector b has length $(length(b))"))
    end

    p = Polyhedra.polyhedron(Polyhedra.hrep(A, b), lib)
    #=if lib !== nothing
        P = Polyhedra.polyhedron(Polyhedra.hrep(A, b), lib)
    else
        # use default library
        P = Polyhedra.polyhedron(Polyhedra.hrep(A, b))
    end=#

    return Spindle(p)
end

nhalfspaces(s::Spindle) = Polyhedra.nhalfspaces(s.p)
dim(s::Spindle) = Polyhedra.dim(s.p, true)  # TODO

"""
    vertices(s)

Returns an iterator over the vertices of the spindle `s`.
"""
vertices(s::Spindle) = Polyhedra.points(s.p)

"""
    nvertices(s)

Count the vertices of `s`.
"""
nvertices(s::Spindle) = Polyhedra.npoints(s.p)

# --------------------------------
# vertex-halfspace incidences
# --------------------------------

inciscomputed(s::Spindle) = s.inc !== nothing
function computeinc!(s::Spindle)
    s.inc = Vector{BitVector}(undef, nvertices(s))

    nf = Polyhedra.nhalfspaces(s.p)
    nh = Polyhedra.nhyperplanes(s.p)

    for v in eachindex(vertices(s))
        s.inc[v.value] = falses(nf)
        for f in Polyhedra.incidenthalfspaceindices(s.p, v)
            s.inc[v.value][f.value - nh] = true  # TODO hacky
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

# --------------------------------
# apices
# --------------------------------

"""
    apices(s [,apex])

Return the indices of a pair of vertices (the *apices*) of `s` for which each facet of `s` 
is incident to exactly one of them.
"""
apices(s::Spindle) = s.apices

# actually needs computeapices! because inc is computed
function computeapices(s::Spindle, apex::Union{Nothing, Int}=nothing)
    nv = nvertices(s)  # triggers vertex enumeration if necessary
    nf = nhalfspaces(s)

    if !inciscomputed(s)
        computeinc!(s)
    end

    # assuming that i and j are the indices of the apices that we want to find, their incidenct 
    # halfspaces/facets partition the set of all halfspaces, so this predicate must evaluate to true:
    isapexpair(i,j) = all(s.inc[i] .⊻ s.inc[j])  # bitwise XOR

    # in particular, the number of incident facets of j must be at least 
    # nf - sum(s.inc[i]) >= nf - maxinc, 
    # where maxinc is the maximum number of incident halfspaces across all vertices:
    maxinc = maximum(sum, s.inc)

    # we use this fact to perform a pre-check in the following algorithm
    # and discard vertices with too few incident facets

    # given i, finds j such that (i,j) are a valid pair of apices
    # if onlygreater is set to `true`, then consider j > i only
    function findsecondapex(i::Int, onlygreater::Bool)
        issecondapex(j) = (!onlygreater || j > i) && i != j && 
            sum(s.inc[j]) + maxinc >= nf && isapexpair(i,j)
        findfirst(issecondapex, 1:nv)
    end

    # brute-force all possible apex pairs and stop on finding the first valid pair

    if apex !== nothing
        j = findsecondapex(apex, false)
        if j !== nothing
            return sort([apex,j])
        end
    else
        for i=1:nv
            sum(s.inc[i]) + maxinc >= nf || continue
            j = findsecondapex(i, true)
            if j !== nothing
                return [i,j]
            end
        end
    end

    # no apex pair found
    return nothing
end

"""   
    setapex!(s, apex)

Try to find the index `v` of a vertex of `s` such that `v` and `apex` are apices of `s`.
If successful, overwrite the apices of `s`, or throw an error otherwise.

# Examples

```jldoctest
julia> square = Spindle([1 0; 0 1; -1 0; 0 -1], [1, 1, 1, 1]);

julia> vertices(square)
4-element iterator of Vector{Rational{BigInt}}:
 Rational{BigInt}[-1, -1]
 Rational{BigInt}[1, -1]
 Rational{BigInt}[-1, 1]
 Rational{BigInt}[1, 1]

julia> apices(square)
2-element Vector{Int64}:
 1
 4

julia> setapex!(square, 2);

julia> apices(square)
2-element Vector{Int64}:
 2
 3
```
"""
function setapex!(s::Spindle, apex::Int)
    1 <= apex <= nvertices(s) || throw(ArgumentError("no vertex at index $(apex): index must be between 1 and $(nvertices(s))"))

    apices = computeapices(s, apex)
    if apices !== nothing
        s.apices = apices
    else
        throw(ArgumentError("cannot find a matching second apex"))        
    end
end

# --------------------------------
# face enumeration, plotting, io:
# --------------------------------

include("faceenum.jl")
include("goodfaces.jl")
include("plots.jl")
include("io.jl")

end # module Spindles