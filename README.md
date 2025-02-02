# Introduction

This repository provides a collection of tools to study paths on polytopes:
1. a Python script for use in [Sage](https://www.sagemath.org/) that computes the **monotone diameter** of a polytope,
2. a [Julia](https://julialang.org/) package `Spindles` to analyze so-called **spindles**. These are polytopes with two distinguished vertices such that each facet contains exactly one of them. 

These tools have been developed to analyze known counterexamples to the [Hirsch conjecture](https://en.wikipedia.org/wiki/Hirsch_conjecture).


## Getting Started

To run the Python code, you will need a working installation of Sage. Alternatively, you can use [CoCalc](https://cocalc.com/) to run it.

The Julia code requires Julia version 1.8 or higher. It uses the following Julia packages:
* [Polyhedra.jl](https://juliapolyhedra.github.io/Polyhedra.jl/) for polyhedral computations, 
* [Graphs.jl](https://juliagraphs.org/Graphs.jl/) for basic graph computations, 
* [Plots.jl](https://docs.juliaplots.org/) for visualization.

See [here](Spindles/examples/Demo.ipynb) for a demo. To run the demo in your own Julia environment, the [Julia kernel](https://github.com/JuliaLang/IJulia.jl) for Jupyter notebooks is required.
