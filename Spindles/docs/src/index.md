# Spindles.jl

The goal of *Spindles.jl* is to provide an interface for analyzing spindles.

### What is a spindle?
A *spindle* is a [polytope](https://en.wikipedia.org/wiki/Polytope) with two special vertices such that each facet contains exactly one of them. These two special vertices are called the *apices* of the spindle. 

A simple example is a cube: For each vertex $u$, there is a unique vertex $v$ that does not share a facet with $u$ (namely, the vertex that is "antipodal" to $u$). Any such pair $u$ and $v$ is a valid pair of apices for the cube.

### Why are spindles important?
Spindles play an important role in the [construction of counterexamples](https://arxiv.org/abs/1006.2814) to the [Hirsch conjecture](https://en.wikipedia.org/wiki/Hirsch_conjecture). In fact, a computational analysis of these counterexamples was the main driver of the development of *Spindles.jl*. More details can be found in [this tutorial](@ref "Spindles and the Hirsch conjecture I").

### Why develop a package dedicated to spindles?
There are many great (and free) software packages and libraries for representing and manipulating polyhedra.
In the Julia ecosystem specifically, there are
* [Polyhedra.jl](https://juliapolyhedra.github.io/Polyhedra.jl/)
* [Polymake.jl](https://github.com/oscar-system/Polymake.jl): Julia wrapper for [polymake](https://polymake.org/doku.php) and part of the [OSCAR computer algebra system](https://www.oscar-system.org/)
* [CDDLib.jl](https://github.com/JuliaPolyhedra/CDDLib.jl): Julia wrapper for [cdd](https://people.inf.ethz.ch/fukudak/cdd_home/)
* [LRSLib.jl](https://github.com/JuliaPolyhedra/LRSLib.jl): Julia wrapper for [lrs](https://cgm.cs.mcgill.ca/~avis/C/lrs.html)
And this list is by no means exhaustive.

Since spindles are polyhedra, they can of course be built and analyzed with any of the packages in the list.
In fact, *Spindles.jl* relies on [Polyhedra.jl](https://juliapolyhedra.github.io/Polyhedra.jl/) to enumerate
vertices of a polytope, given only an inequality description of it. 
What drove the development of a separate package specifically for spindles was research in polyhedral theory that required the computational analysis of certain properties of spindles with few lines of code. 

As *Spindles.jl* was born out of a research project,
we are not sure how useful the package is to the broader community. However, one of the guiding design principles
of *Spindles.jl* is to implement functions in such a way that they do not only apply to spindles and do not 
only serve the initial research purpose. For example, the package implements a general-purpose algorithm to enumerate faces of polytopes (not just spindles) that follows ideas described [here](https://sites.google.com/site/christopheweibel/research/hirsch-conjecture) (see also the [paper](https://arxiv.org/pdf/1202.4701)).

See the [full API reference](@ref "Index") for more technical details on the package design and its functionalities.

---

## Installation
Using *Spindles.jl* requires a working installation of Julia. Download files and detailed instructions are available on the [Julia website](https://julialang.org/).

To install *Spindles.jl*, clone the parent [GitHub repository](https://github.com/ma-b/hirsch-walks). In the `Spindles` subdirectory of your local clone, open the Julia REPL and enter [Pkg](https://docs.julialang.org/en/v1/stdlib/Pkg/) mode by pressing `]`. Then run

```julia
pkg> dev .
```

!!! note
    
    See also the [Pkg documentation](https://pkgdocs.julialang.org/v1/managing-packages/#developing) on the `dev` (or `develop`) command.

You are now ready to use *Spindles.jl* by typing
```jldoctest
julia> using Spindles
```

---

## Getting started
For the basic usage of *Spindles.jl*, please read the tutorial on [first steps](@ref "First steps"). 
The full documentation can be found [here](@ref "Index").

To learn more about how *Spindles.jl* can help analyze counterexamples to the Hirsch conjecture, please check out [this tutorial](@ref "Spindles and the Hirsch conjecture I").

!!! note

    If you would like to run some of the examples presented in the tutorials yourself, you can view or download them
    as Jupyter notebooks. The links can be found on the respective tutorial pages.

    Note that the [Julia kernel](https://github.com/JuliaLang/IJulia.jl) for Jupyter notebooks is required to run the example notebooks in your own Julia environment. It can be installed in Pkg mode by running

    ```
    pkg> add IJulia
    pkg> build IJulia
    ```
