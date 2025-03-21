"""
Main module. The public API is listed below.
"""
module Spindles

import Polyhedra
import Graphs

export Polytope

mutable struct Polytope{T}
    const poly::Polyhedra.Polyhedron{T}
    inc::Union{Nothing, Vector{BitVector}}  # vertex-halfspace incidences
    graph::Union{Nothing, Graphs.SimpleGraph{Int}}  # graph
    dim::Union{Nothing, Int}  # dimension
    faces::Dict{Int, Vector{Vector{Int}}}  # maps k to list of incident halfspaces for each face of dim k
    dists::Union{Nothing, Dict{Int, Vector{Int}}}  # cache graph distance matrix

    function Polytope{T}(p::Polyhedra.Polyhedron{T}) where T
        # First check whether `p` is a polytope. This triggers the computation of V-representation if necessary.
        # INVARIANT: the V-representation has no redundancy,
        # see https://juliapolyhedra.github.io/Polyhedra.jl/stable/polyhedron/#Polyhedra.doubledescription
        if Polyhedra.nlines(p) + Polyhedra.nrays(p) > 0
            throw(ArgumentError("got an unbounded polyhedron"))
        end

        new{T}(p, nothing, nothing, nothing, Dict{Int, Vector{Vector{Int}}}(), Dict{Int, Vector{Int}}())
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


# overload useful Base methods

"""
    ==(p::Polytope, q::Polytope)

Check whether the sets of vertices of `p` and `q` are identical.

# Examples
````jldoctest
julia> Polytope([1 0; 0 1]) == Polytope([1 0; 0 1; 0 1; 1//2 1//2])
true

julia> p = Polytope([-1 0; 0 -1; 2 1], [0, 0, 3]);

julia> p == Polytope(collect(vertices(p)))
true
````
"""
Base.:(==)(p::Polytope, q::Polytope) = sort(collect(vertices(p))) == sort(collect(vertices(q)))

Base.show(io::IO, p::Polytope) = print(io, typeof(p))
Base.summary(p::Polytope) = "$(typeof(p))"

# avoid broadcasting over polytopes, see https://docs.julialang.org/en/v1/manual/interfaces/#man-interfaces-broadcasting
Base.broadcastable(p::Polytope) = Ref(p)


include("incidence.jl")
include("faceenum.jl")
include("dim.jl")
include("redundancy.jl")
include("goodfaces.jl")

# plots
include("plotutil.jl")
include("plotrecipe.jl")
include("arrow.jl")

include("io.jl")

end # module Spindles