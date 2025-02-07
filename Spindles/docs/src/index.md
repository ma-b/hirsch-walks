# Spindles.jl

The goal of *Spindles.jl* is to provide an interface for analyzing spindles.

----

## FAQ
### What is a spindle?
A **spindle** is a polytope with two special vertices such that each facet contains exactly one of them. These two special vertices are called the **apices** of the spindle. 

A simple example is a cube: For each vertex $u$, there is a unique vertex $v$ that does not share a facet with $u$ (namely, the vertex that is "antipodal" to $u$). Any such pair $u$ and $v$ is a valid pair of apices for the cube.

### Why are spindles important?
Spindles play an important role in the [construction of counterexamples](https://arxiv.org/abs/1006.2814) to the [Hirsch conjecture](https://en.wikipedia.org/wiki/Hirsch_conjecture). In fact, a computational analysis of these counterexamples was the main driver of the development of *Spindles.jl*. More details can be found in [this tutorial](@ref "Spindles and the Hirsch conjecture").

### Why develop a package dedicated to spindles?
The Julia ecosystem offers interfaces to many libraries for polyhedral computations. Most notably, check out the [*Polyhedra.jl*](https://juliapolyhedra.github.io/Polyhedra.jl/) package. In fact, *Spindles.jl* is built on top of *Polyhedra.jl*. The main design choice in the development of *Spindles.jl* was to enable the computational analysis of certain properties of spindles with very few lines of code, while allowing extensions to other use cases. For example, the package implements a general-purpose algorithm to enumerate faces of polytopes (not just spindles) that follows ideas described [here](https://sites.google.com/site/christopheweibel/research/hirsch-conjecture) (see also the [paper](https://arxiv.org/pdf/1202.4701)).

See the [full API reference](@ref "Index") for more technical details on the package design and its functionalities.

---

## Installation
Using *Spindles.jl* requires a working installation of Julia. Download files and detailed instructions are available on the [Julia website](https://julialang.org/).

To install *Spindles.jl*, clone the [GitHub repository](https://github.com/ma-b/hirsch-walks) into ... In the `Spindles` subdirectory, run Julia in the command line and enter [Pkg](https://docs.julialang.org/en/v1/stdlib/Pkg/) mode by typing `]`. Then run

```julia
pkg> dev .
```

See also the [Pkg documentation](https://pkgdocs.julialang.org/v1/managing-packages/#developing) on the `dev` (or `develop`) command.

You are ready to use *Spindles.jl* by typing
```jldoctest
julia> using Spindles
```

---

## Getting started
For a brief tour of the package and its functionality, please read the [tutorials](@ref "First steps"). 
The full documentation can be found [here](@ref "Index").

See also [this Jupyter notebook](https://nbviewer.org/github/ma-b/hirsch-walks/blob/main/Spindles/examples/Demo.ipynb) for a demo.

!!! note

    To run the demo in your own Julia environment, the [Julia kernel](https://github.com/JuliaLang/IJulia.jl) for Jupyter notebooks is required. It can be installed in Pkg mode by running

    ```
    pkg> add IJulia
    pkg> build IJulia
    ```
