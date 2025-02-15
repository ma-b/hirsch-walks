"""
Main module. The public API is listed [here](@ref "Index").
"""
module Spindles

import Polyhedra
using Graphs

export Spindle, vertices, nvertices, incidentvertices, incidentfacets, apices, setapex!

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
    dim::Union{Nothing, Int}
    dists::Union{Nothing, Dict{Int, Vector{Int}}}

    function Spindle{T}(p::Polyhedra.Polyhedron{T}) where T
        # first check whether P is a polytope (triggers computation of V-representation)
        Polyhedra.nlines(p) + Polyhedra.nrays(p) == 0 || throw(ArgumentError("got an unbounded polyhedron"))
        
        # create a preliminary object with apices not set
        s = new{T}(p, nothing, nothing, nothing, Dict{Int, Vector{Vector{Int}}}(), nothing, nothing)

        # try to find two apices
        s.apices = computeapices(s)
        if s.apices === nothing
            throw(ArgumentError("not a spindle: cannot find two apices"))
        end
        return s
    end
end

"""
    Spindle{T}(p::Polyhedra.Polyhedron{T})

Create a spindle from the polyhedron `p`. If `p` is unbounded or there are no two apices among its vertices,
throw an error. 

If not specified, the element type `T` is the element type of `p`.

See also [`Polyhedra.polyhedron`](https://juliapolyhedra.github.io/Polyhedra.jl/stable/polyhedron/#Polyhedra.polyhedron).

# Examples

```jldoctest poly
julia> using Polyhedra: polyhedron, vrep, hrep

julia> p = polyhedron(vrep([0 0; 1 0; 0 1; 1 1]));

julia> Spindle(p)
Spindle{Rational{BigInt}}
```
creates the two-dimensional 0/1 cube whose vertices are ``(0,0),(1,0),(0,1)``, and ``(1,1)``. To construct from 
such a V-representation a polyhedron that can be passed to the `Spindle` constructor, we used 
[`Polyhedra.vrep`](https://juliapolyhedra.github.io/Polyhedra.jl/stable/representation/#Polyhedra.vrep). 
Equivalently, we could have created it from an inequality description (an H-representation), for example from
the system of inequalities
```math
\\begin{aligned}
0 \\le x_1 &\\le 1 \\\\
0 \\le x_2 &\\le 1
\\end{aligned}
```
Using [`Polyhedra.hrep`](https://juliapolyhedra.github.io/Polyhedra.jl/stable/representation/#Polyhedra.hrep), 
this translates to
```jldoctest poly
julia> p = polyhedron(hrep([-1 0; 1 0; 0 -1; 0 1], [0, 1, 0, 1]));

julia> Spindle(p)
Spindle{Rational{BigInt}}
```

Note that the 0/1 cube is a spindle. However, if we drop any of its vertices, this property is lost:
```jldoctest poly
julia> p = polyhedron(vrep([0 0; 1 0; 0 1]));

julia> Spindle(p)
ERROR: ArgumentError: not a spindle: cannot find two apices
[...]
```

Similarly, trying to create a spindle from a proper subset of the inequalities in the H-representation above
results in an error:

```jldoctest poly
julia> p = polyhedron(hrep([-1 0; 1 0; 0 -1], [0, 1, 0]));

julia> Spindle(p)
ERROR: ArgumentError: got an unbounded polyhedron
[...]
```
"""
Spindle(p::Polyhedra.Polyhedron{T}) where T = Spindle{T}(p)



"""
    Spindle(A::AbstractMatrix, b::AbstractVector [, lib::Polyhedra.Library])

Create a spindle from its H-representation ``Ax \\le b``.
The optional argument `lib` specifies a library for polyhedral computations (the "backend" of Polyhedra.jl)
and is passed to [`Polyhedra.hrep`](https://juliapolyhedra.github.io/Polyhedra.jl/stable/representation/#Polyhedra.hrep).
If unspecified, use the default library implemented in `Polyhedra`.

!!! note "Info"

    `Spindle(A, b, lib)` is equivalent to `Spindle(polyhedron(hrep(A, b), lib))`.

See also the [Polyhedra.jl documentation on libraries](https://juliapolyhedra.github.io/Polyhedra.jl/stable/polyhedron/#Default-libraries).
A list of all supported libraries can be found on the [JuliaPolyhedra website](https://juliapolyhedra.github.io/).

# Examples
To use [CDDLib](https://github.com/JuliaPolyhedra/CDDLib.jl) with exact rational arithmetic, do
```julia
import CDDLib
Spindle(A, b, CDDLib.Library(:exact))
```

!!! note

    If the `lib` argument is not specified, `Spindle` will infer the type of arithmetic used from the input data.
    This behaviour is inherited from the default library in `Polyhedra`. For example, changing some of the entries
    of the coefficient matrix in the examples above to floats produces
    ```jldoctest
    julia> Spindle([-1.0 0.0; 1 0; 0 -1; 0 1], [0, 1, 0, 1])
    Spindle{Float64}
    ```
    as opposed to `Spindle{Rational{BigInt}}`.

"""
function Spindle(A::AbstractMatrix{<:Real}, b::AbstractVector{<:Real}, lib::Union{Nothing, Polyhedra.Library}=nothing)
    if size(A,1) != size(b,1)
        throw(DimensionMismatch("matrix A has dimensions $(size(A)), right-hand side vector b has length $(length(b))"))
    end

    if lib === nothing
        p = Polyhedra.polyhedron(Polyhedra.hrep(A, b))  # let polyhedron do the type promotion if necessary
    else
        p = Polyhedra.polyhedron(Polyhedra.hrep(A, b), lib)
    end
    Spindle(p)
end


Base.show(io::IO, s::Spindle) = print(io, typeof(s))

nhalfspaces(s::Spindle) = Polyhedra.nhalfspaces(s.p)

"""
    vertices(s::Spindle)

Returns an iterator over the vertices of the spindle `s`.
"""
vertices(s::Spindle) = Polyhedra.points(s.p)

"""
    nvertices(s::Spindle)

Count the vertices of `s`.
"""
nvertices(s::Spindle) = Polyhedra.npoints(s.p)

# --------------------------------
# vertex-halfspace incidences
# --------------------------------

inciscomputed(s::Spindle) = s.inc !== nothing
function computeinc!(s::Spindle)
    s.inc = Vector{BitVector}(undef, nvertices(s))

    nh = Polyhedra.nhyperplanes(s.p)
    nf = Polyhedra.nhalfspaces(s.p)

    for v in eachindex(vertices(s))
        s.inc[v.value] = falses(nf)
        for f in Polyhedra.incidenthalfspaceindices(s.p, v)
            # the hyperplanes and halfspaces of s.p are numbered consecutively (in this order),
            # so we use the number of hyperplanes as a hacky offset here
            s.inc[v.value][f.value - nh] = true
        end
    end
end

"""
    incidentvertices(s::Spindle, facets)

List the indices of all vertices of the spindle `s` that are incident with `facets`.

!!! note

    `incidentvertices(s, Int[])` is equivalent to `collect(1:nvertices(s))`.
"""
function incidentvertices(s::Spindle, facets::Vector{Int})
    if !inciscomputed(s)
        computeinc!(s)
    end

    [v for v=1:nvertices(s) if all(s.inc[v][facets])]
end

function incidentfacets(s::Spindle, indices::Vector{Int})
    if minimum(indices) < 1 || maximum(indices) > nvertices(s)
        throw(ArgumentError("all vertex indices must be between 1 and $(nvertices(s))"))
    end
    
    if !isempty(indices)
        return findall(reduce(.&, s.inc[indices]))
    else
        return Int[]
    end
end

# --------------------------------
# apices
# --------------------------------

"""
    apices(s::Spindle) 

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
    # halfspaces/facets partition the set of all halfspaces excluding those that correspond to
    # implicit equations; so this predicate must evaluate to true:
    impliciteq = reduce(.&, s.inc)
    isapexpair(i,j) = all(s.inc[i] .⊻ s.inc[j] .⊻ impliciteq)  # bitwise XOR

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
    setapex!(s::Spindle, apex::Int)

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