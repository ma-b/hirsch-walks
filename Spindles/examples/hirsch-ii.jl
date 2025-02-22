# # Spindles and the Hirsch conjecture II

#md # [![](https://img.shields.io/badge/show-nbviewer-579ACA.svg)](@__NBVIEWER_ROOT_URL__/tutorials/Spindles and the Hirsch conjecture II.ipynb)

# In the second part of the tutorial, we will be analyzing the lowest-dimensional counterexample to the (bounded)
# Hirsch conjecture known to date. It is a spindle with 40 facets in dimension 20 that is
# constructed from a 5-dimensional "base" spindle found by
# [Matschke, Santos, and Weibel](https://arxiv.org/abs/1202.4701). Following the terminology
# of [part I](@ref "Spindles and the Hirsch conjecture I") of this tutorial, our goal is to find *good 2-faces*.

#md # !!! note
#md #     This example is also available as a Jupyter notebook. 
#md #     Click on the badge above to view it in [nbviewer](https://nbviewer.jupyter.org/).

#src ==========================
# ## Dimension 5

# To begin, let us enumerate the good 2-faces of the 5-dimensional spindle.

using Spindles
A, b, = readineq("s-25-5.txt", BigInt)
s = Polytope(A, b)
apx = apices(s)
