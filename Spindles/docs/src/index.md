# Spindles.jl

The goal of *Spindles.jl* is to provide an interface for analyzing spindles.

## FAQ
### What is a spindle?
A **spindle** is a polytope with two special vertices such that each facet contains exactly one of them. These two special vertices are called the **apices** of the spindle. 
A simple example is a cube: For each vertex $u$, there is a unique vertex $v$ that does not share a facet with $u$ (namely, the "antipodal" one). Any such pair $u$ and $v$ is a valid pair of apices for the cube.

### Why are spindles important?
Spindles play an important role in the [construction of counterexamples](https://arxiv.org/abs/1006.2814) to the [Hirsch conjecture](https://en.wikipedia.org/wiki/Hirsch_conjecture). In fact, analyzing these counterexamples computationally was the main driver of the development of *Spindles.jl*. More details can be found in [this tutorial](@ref "Spindles and the Hirsch conjecture").

### Why develop a package dedicated to spindles?
The Julia ecosystem offers interfaces to many libraries for polyhedral computations. Most notably, check out the [*Polyhedra.jl*](https://juliapolyhedra.github.io/Polyhedra.jl/) package. In fact, *Spindles.jl* is built on top of *Polyhedra.jl*. The main design choice in the development of *Spindles.jl* was to enable the computational analysis of certain properties of spindles with very few lines of code, while allowing extensions to other use cases. For example, the package implements a general-purpose algorithm to enumerate faces of polytopes (not just spindles) that follows ideas described [here](https://sites.google.com/site/christopheweibel/research/hirsch-conjecture) (see also the [paper](https://arxiv.org/pdf/1202.4701)).

See the [full API reference](@ref "Representation") for more technical details on the package design and its functionalities.


## Installation
### Julia
Download files and detailed instructions are available on the [Julia website](https://julialang.org/).

### Package
Currently not available via Julia's in-built package manager [Pkg](https://docs.julialang.org/en/v1/stdlib/Pkg/). Clone the GitHub repo or download ... and run the following in the command line:

```
    ...
```

Ready to use *Spindles.jl* by typing
```jldoctest
julia> using Spindles
```

## Getting started




