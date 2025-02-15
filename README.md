# Introduction

This repository provides a collection of tools to study paths on polytopes:
1. a Python script for use in [Sage](https://www.sagemath.org/) that computes the **monotone diameter** of a polytope,
2. a [Julia](https://julialang.org/) package *Spindles.jl* that facilitates the computational analysis of so-called **spindles**, a special class of polytopes.

These tools have been developed to analyze known counterexamples to the [Hirsch conjecture](https://en.wikipedia.org/wiki/Hirsch_conjecture).


## Getting Started

### Monotone Diameter
To run the Python code in [MonotoneDiameter/](MonotoneDiameter/), you will need a working installation of Sage. Alternatively, you can use [CoCalc](https://cocalc.com/) to run it.

### Spindles

[![docs stable](https://img.shields.io/badge/docs-stable-blue)](https://ma-b.github.io/hirsch-walks/stable/)
[![docs dev](https://img.shields.io/badge/docs-dev-blue)](https://ma-b.github.io/hirsch-walks/dev/)

The Julia code for *Spindles.jl* is located in [Spindles/src/](Spindles/src/) and requires Julia version 1.8 or higher.

Installation instructions, tutorials, and the full package documentation (under construction) are available [here](https://ma-b.github.io/hirsch-walks/dev/).