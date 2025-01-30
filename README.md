# Introduction

This repository provides a collection of tools to study paths on polytopes:
1. a Python script for use in [Sage](https://www.sagemath.org/) that computes the **monotone diameter** of a polytope,
2. a [Julia](https://julialang.org/) package `Spindles` to analyze so-called **spindles**. These are polytopes with two distinguished vertices such that each facet contains exactly one of them. 

These tools have been developed to analyze known counterexamples to the [Hirsch conjecture](https://en.wikipedia.org/wiki/Hirsch_conjecture).


## Getting Started

To run the Python code, you will need a working installation of Sage. Alternatively, you can use [CoCalc](https://cocalc.com/) to run it.

The Julia code uses the [Polyhedra.jl](https://juliapolyhedra.github.io/Polyhedra.jl/) interface for polyhedral computations, and [Graphs.jl](https://juliagraphs.org/Graphs.jl/) for basic graph computations. 
Besides, the following Julia packages are required:

* `Plots`
* `Printf`
* `DelimitedFiles`

See [here](Spindles/examples/Demo.ipynb) for a demo.