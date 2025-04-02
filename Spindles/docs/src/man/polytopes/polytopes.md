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
    Two `Polytope`s are considered equal by the [`==`](@ref) operator if and only if they have the same set of vertices.

An equivalent description of the 2D polytope `p` is in terms of the following system of linear inequalities:
```math
\begin{aligned}
0 \le x_1 &\le 1 \\
0 \le x_2 &\le 1
\end{aligned}
```
This translates to
```jldoctest polytopes
julia> A = [ -1   0
              1   0
              0  -1
              0   1 ];

julia> b = [0, 1, 0, 1];

julia> r = Polytope(A, b)
Polytope{Rational{BigInt}}

julia> p == r
true
```
Unlike for the first two constructors above, there is no guarantee that a polyhedron defined by 
a general system $Ax \le b$ is bounded (and, hence, a polytope). Indeed, 
if we drop any of the four inequalities above – say the last one –, this property is lost:
```jldoctest polytopes
julia> Polytope(A[1:3,:], b[1:3])
ERROR: ArgumentError: got an unbounded polyhedron
[...]
```

Even though all examples so far only featured *minimal* descriptions of the two-dimensional 0/1 cube,
a `Polytope` object can be created from *any* description of the polytope, not necessarily a minimal one.
In particular, the list of points whose convex hull is the polytope can include non-vertices. Likewise,
redundant inequalities and implicit equations in a system of linear inequalities are permitted. 
Such redundancy can be detected, see [Representations](@ref).


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


```@meta
DocTestSetup = nothing
```