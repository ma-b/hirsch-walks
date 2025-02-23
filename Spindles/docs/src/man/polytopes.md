# Polytopes

```@meta
DocTestSetup = quote
    import Polyhedra
    using Spindles
end
```

The main type defined by *Spindles.jl* is the type [`Polytope`](@ref) that represents a polytope.
Objects of this type are constructed either from a V-representation (a list of points whose convex hull
is the polytope) or from an H-representation (a system of linear inequalities whose set of solutions is the polytope):

```@docs
Polytope
```

###### Examples

```jldoctest polytopes
julia> p = Polytope([[0, 0], [1, 0], [0, 1], [1, 1]])
Polytope{Rational{BigInt}}
```
creates the polytope with vertices ``(0,0),(1,0),(0,1)``, and ``(1,1)`` (the two-dimensional 0/1 cube).
This is the same as
```jldoctest polytopes
julia> q = Polytope([0 0; 1 0; 0 1; 1 1])
Polytope{Rational{BigInt}}

julia> p == q
true
```

!!! note
    Two `Polytope`s are considered equal by the `==` operator if and only if they have the same set of vertices.

Equivalently, our 2D polytope may be created from the inequality description
```math
\begin{aligned}
0 \le x_1 &\le 1 \\
0 \le x_2 &\le 1
\end{aligned}
```
which translates to
```jldoctest polytopes
julia> r = Polytope([-1 0; 1 0; 0 -1; 0 1], [0, 1, 0, 1])
Polytope{Rational{BigInt}}

julia> p == r
true
```
Unlike for the first two constructors above, there is no guarantee that a polyhedron defined by 
a general system $Ax \le b$ is bounded (and, hence, a polytope). Indeed, 
if we drop any of the four inequalities above – say the last one –, this property is lost:
```jldoctest
julia> Polytope([-1 0; 1 0; 0 -1], [0, 1, 0])
ERROR: ArgumentError: got an unbounded polyhedron
[...]
```

!!! note "Type parameter"
    [`Polytope`](@ref) is a [parametric type](https://docs.julialang.org/en/v1/manual/types/#Parametric-Types). Namely, the precise type of each of the three objects constructed above is `Polytope{Rational{BigInt}}`, where the parameter `Rational{BigInt}` is called the element type and is inferred from the type of the data
    passed to the constructor. For example, `Rational{BigInt}` indicates that `Polytope` uses exact rational arithmetic to store and manipulate the coefficients in a V- or H-representation. For integer data, this is the default choice. 
    
    Suppose that we change some of the input data above to floating-point numbers, such as
    ```jldoctest
    julia> Polytope([-1.0 0.0; 1 0; 0 -1; 0 1], [0, 1, 0, 1])
    Polytope{Float64}
    ```
    Then we get a different element type, namely `Float64`. 
    
    The type of arithmetic used to represent and manipulate the `Polytope` object can also be set using an optional constructor argument that is borrowed from [Polyhedra.jl](https://github.com/JuliaPolyhedra/Polyhedra.jl) (and that may be passed to any of the `Polytope` constructors):
    ```jldoctest
    julia> using Polyhedra: DefaultLibrary

    julia> Polytope([-1.0 0.0; 1 0; 0 -1; 0 1], [0, 1, 0, 1], DefaultLibrary{Rational{BigInt}}())
    Polytope{Rational{BigInt}}
    ```
    This argument now specifies a library for polyhedral computations (the "backend" of [Polyhedra.jl](https://github.com/JuliaPolyhedra/Polyhedra.jl)) that is to be used for the internal representation of the `Polytope` object. In this case, we chose the [default library](https://juliapolyhedra.github.io/Polyhedra.jl/stable/polyhedron/#Default-libraries) implemented in Polyhedra.jl but forced rational data instead of `Float`s.
    
    See also the [JuliaPolyhedra website](https://juliapolyhedra.github.io/) for a list of all supported libraries.
    For example, to use [CDDLib](https://github.com/JuliaPolyhedra/CDDLib.jl) with exact rational arithmetic, do
    ```julia
    import CDDLib
    Polytope(A, b, CDDLib.Library(:exact))
    ``` 
    
Also note that lists of points or inequality descriptions passed to one of the [`Polytope`](@ref) constructors need not be minimal: They may include non-vertices; and redundant inequalities or implicit equations in a system of linear inequalities are allowed, too. However, these can be detected, see the section on [Redundancy and implicit equations](@ref) below.

## Vertices

```@docs
Spindles.vertices
```

```@docs
nvertices
```

## Incidence 

```@docs
incidentvertices
```

## Dimension

```@docs
Spindles.dim
```

As in the example above, [`dim`](@ref Spindles.dim) can be used to test whether an inequality is facet-defining 
for a polytope `p`. However, this may be slow in high dimensions, since [`dim`](@ref Spindles.dim) needs to
compute a chain of faces starting from the empty face and leading up to the given face. For a facet, such a chain
may be long. To speed up computations in those cases, consider the complementary approach to the implementation of 
[`dim`](@ref Spindles.dim): Start the chain of faces not at the empty face but at the given face, and extend it 
up to the maximal face in the face lattice (the polytope `p` itself). From the length of the resulting chain, one 
can easily read off the *codimension* of the face (which equals 1 for a facet):

```@docs
codim
```

## Redundancy and implicit equations

When constructing a `Polytope` from an inequality description, *any* inequality description is allowed. 
In particular, it may contain redundant inequalities (whose deletion leaves the polytope unchanged) or implicit equations (inequalities that are satisfied at equality by all points in the polytope).
So the inequalities in a given description may be
partitioned into three sets:
1. a minimal set of facet-defining inequalities (which may not be unique), 
2. a (possibly empty) set of implicit equations contained in the inequality system, and 
3. all remaining inequalities (that may safely be deleted). 
This partition can be computed using the functions [`facets`](@ref) and [`impliciteqs`](@ref),
which return the first two sets of the partition.

```@docs
facets
```

```@docs
nfacets
```

```@docs
impliciteqs
```

## Spindles

```@docs
apices
```



```@meta
DocTestSetup = nothing
```