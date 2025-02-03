# Introduction

This repository provides a collection of tools to study paths on polytopes:
1. a Python script for use in [Sage](https://www.sagemath.org/) that computes the **monotone diameter** of a polytope,
2. a [Julia](https://julialang.org/) package `Spindles` to analyze so-called **spindles**. These are polytopes with two distinguished vertices such that each facet contains exactly one of them. 

These tools have been developed to analyze known counterexamples to the [Hirsch conjecture](https://en.wikipedia.org/wiki/Hirsch_conjecture).


## Getting Started

### Monotone Diameter
To run the Python code in [MonotoneDiameter/](MonotoneDiameter/), you will need a working installation of Sage. Alternatively, you can use [CoCalc](https://cocalc.com/) to run it.

### Spindles
The Julia code for `Spindles` is located in [Spindles/src/](Spindles/src/) and uses the following Julia packages:
* [Polyhedra](https://juliapolyhedra.github.io/Polyhedra.jl/) for polyhedral computations, 
* [Graphs](https://juliagraphs.org/Graphs.jl/) for basic graph computations, 
* [Plots](https://docs.juliaplots.org/) for visualization.

> [!NOTE]
> `Spindles` requires Julia version 1.8 or higher.

See [here](Spindles/examples/Demo.ipynb) for a demo. 

> [!NOTE] 
> To run the demo in your own Julia environment, the [Julia kernel](https://github.com/JuliaLang/IJulia.jl) for Jupyter notebooks is required in addition to the packages listed above.
> It can be installed by entering [Pkg](https://docs.julialang.org/en/v1/stdlib/Pkg/) mode in the Julia REPL (type `]`) and running
>
> ```
>	pkg> add IJulia
>	pkg> build IJulia
> ```
