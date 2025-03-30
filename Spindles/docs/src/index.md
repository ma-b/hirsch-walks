# Spindles.jl
## Introduction

The goal of *Spindles.jl* is to provide a lightweight interface for representing and analyzing polytopes.
The initial purpose of the package is to facilitate research in polyhedral theory on so-called spindles.

### What is a spindle?
A *spindle* is a [polytope](https://en.wikipedia.org/wiki/Polytope) with two special vertices such that each facet contains exactly one of them. These two special vertices are called the *apices* of the spindle. 

A simple example is a cube: For each vertex $u$, there is a unique vertex $v$ that does not share a facet with $u$ (namely, the vertex that is "antipodal" to $u$). Any such pair $u$ and $v$ is a valid pair of apices for the cube.

### Why are spindles important?
Spindles play an important role in the [construction of counterexamples](https://arxiv.org/abs/1006.2814) to the [Hirsch conjecture](https://en.wikipedia.org/wiki/Hirsch_conjecture). In fact, a computational analysis of these counterexamples was the main driver of the development of *Spindles.jl*. More details can be found in [this tutorial](@ref "Spindles and the Hirsch conjecture I").

### Who is this package for?
Even though the package was born out of polyhedral research on spindles, 
its implementation is not specific to this special class of polytopes at all. 
In fact, *Spindles.jl* allows for representing and analyzing any polytope. 
For example, the package implements lightweight (and mostly combinatorial) algorithms to enumerate and 
count faces, compute the dimension, or detect redundancy in a given linear description of a polytope.

Of course, there are many great and free software packages and libraries for manipulating polyhedra.
Here is a non-exhaustive list of examples from the Julia ecosystem:
* [Polyhedra.jl](https://github.com/JuliaPolyhedra/Polyhedra.jl): Implements the [double description method](https://juliapolyhedra.github.io/Polyhedra.jl/stable/polyhedron/#Polyhedra.doubledescription)
  for converting representations of polyhedra into each other. Also provides an interface to many other libraries for polyhedral computations, see the [JuliaPolyhedra website](https://juliapolyhedra.github.io/).
* [Polymake.jl](https://github.com/oscar-system/Polymake.jl): Julia wrapper for [polymake](https://polymake.org/doku.php) and part of the [OSCAR computer algebra system](https://www.oscar-system.org/).
* [CDDLib.jl](https://github.com/JuliaPolyhedra/CDDLib.jl): Julia wrapper for [cdd](https://people.inf.ethz.ch/fukudak/cdd_home/).
* [LRSLib.jl](https://github.com/JuliaPolyhedra/LRSLib.jl): Julia wrapper for [lrs](https://cgm.cs.mcgill.ca/~avis/C/lrs.html).
The latter two are examples of libraries that can also be used with [Polyhedra.jl](https://github.com/JuliaPolyhedra/Polyhedra.jl), as can a couple of others listed on the [JuliaPolyhedra website](https://juliapolyhedra.github.io/).

!!! note
    *Spindles.jl* currently relies on [Polyhedra.jl](https://github.com/JuliaPolyhedra/Polyhedra.jl) to convert a polytope given by a system of linear inequalities into a list of its vertices and vice versa.

See the [full API reference](@ref "Index") for more technical details on the package design and its functionalities.

---

## Installation
Using *Spindles.jl* requires a working installation of Julia. Download files and detailed instructions are available on the [Julia website](https://julialang.org/).

To install the latest stable version of *Spindles.jl*, clone the parent [GitHub repository](https://github.com/ma-b/hirsch-walks) by running 

    git clone --branch v0.3.2 https://github.com/ma-b/hirsch-walks.git

in the command line. In the `Spindles` subdirectory of your local clone, open the Julia REPL and enter [Pkg](https://docs.julialang.org/en/v1/stdlib/Pkg/) mode by pressing `]`. Then run

    pkg> dev .

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

    If you would like to run the examples presented in the tutorials yourself, you can view or 
    download all tutorials as Jupyter notebooks. The links can be found on the respective tutorial pages.

    Note that the [Julia kernel](https://github.com/JuliaLang/IJulia.jl) for Jupyter notebooks is required to run them in your own Julia environment. It can be installed in Pkg mode by running

    ```
    pkg> add IJulia
    pkg> build IJulia
    ```
