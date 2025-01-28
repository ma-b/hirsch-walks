# Introduction

This repository provides a collection of tools to study paths on polytopes:
1. a [Sage](https://www.sagemath.org/) script that computes the **monotone diameter** of a polytope,
2. a [Julia](https://julialang.org/) package `Spindles` to analyze so-called **spindles**. These are polytopes with two distinguished vertices such that each facet contains exactly one of them. 

These tools have been developed to analyze known counterexamples to the [Hirsch conjecture](https://en.wikipedia.org/wiki/Hirsch_conjecture). See here for the theoretical results that the authors of this repository obtained.

The package `Spindles` uses the [Polyhedra.jl](https://juliapolyhedra.github.io/Polyhedra.jl/) interface for polyhedral computations, and [Graphs.jl](https://juliagraphs.org/Graphs.jl/) for basic graph computations. 
See [here](Spindles/examples/Demo.ipynb) for an example and how to reproduce our results in ...

## Getting Started

You need working installations of Sage and Julia.

* `Polyhedra`
* `Graphs`
* `Plots`
* `Printf`
* `DelimitedFiles`
