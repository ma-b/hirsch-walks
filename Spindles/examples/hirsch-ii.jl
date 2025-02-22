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

# !!! note
#     We created `s` from rational data with numerators and denominators of type `BigInt` 
#     (this is the second argument passed to `readineq`). Choosing `Int` here (as in [part I](@ref "Reading a spindle from a file") 
#     of this tutorial) would have produced an integer overflow error. See also the section on 
#     [arbitrary-precision arithmetic](https://docs.julialang.org/en/v1/manual/integers-and-floating-point-numbers/#Arbitrary-Precision-Arithmetic)
#     in the Julia language documentation.

# The following code finds all good 2-faces of `s`.
goodfaces = []
for f in sort(facesofdim(s, 2))
    fstate = isgood2face(s, f, apx...)
    if fstate.good
        push!(goodfaces, fstate)
    end
end
length(goodfaces)

# Next, let's plot the graph of each of those 32 good 2-faces:
using Plots

dist_labels = map(1:nvertices(s)) do v
    "$v\n" * join(dist.(s, apx, v), " | ")
end

plot_arr = []
for fstate in goodfaces
    push!(plot_arr, 
        plot2face(s, fstate.facets; 
            vertexlabels=dist_labels, usecoordinates=false, directed_edges=fstate.edges
        )
    )
end

ncols = 4
nrows = ceil(Int, length(plot_arr) / ncols)
plot(plot_arr..., layout=(nrows, ncols), size=(1000, nrows*300), plot_title="Good 2-faces")
#md savefig("s-25-5-all.svg"); nothing # hide

#md # ![](s-25-5-all.svg)

#src ==========================
# ## Dimension 20

#src ==========================
# ### Warm-up: Patterns in the inequality description
# Let us first take a look at the inequality description of the 20-dimensional spindle.
# A minimal description is provided in the file `s-25.txt`. Its contents are as follows:
print(read("s-25.txt", String))

# You may notice that the coefficients in the first couple of columns are very similar to
# those of `A`, the coefficient matrix of the 5-dimensional "base" spindle `s`. This
# similarity is no coincidence: the matrix encoded in the file above is derived from `A`
# in a highly structured way.
# Each row has a "counterpart" in `A`. For convenience, each row above is already
# labeled by the index of its "counterpart". For example, the labels of the first three rows
# (the numbers in the first column) are
[3, 7, 2]

# and the corresponding rows of `A` are
A[[3, 7, 2],:]

# If you inspect those row labels closely, you may notice a pattern. Two labels appear multiple times,
# namely  `11` and `25`. The corresponding rows of `A` have been "replicated" a number of times.
# Each time, a new nonzero entry is added to the right whose order of magnitude is much larger than
# that of all other coefficients. At the polyhedral level, this "replication" of rows is reflected by
# an operation called *wedging*, which plays a crucial role in Santos' construction of a Hirsch
# counterexample from spindles like `s`.

# The structure that we just observed will be extremely useful in "guessing" good 2-faces of the
# 20-dimensional spindle encoded in the file above. Before we examine its faces, let us first
# read the file and construct a `Spindle` object from it.

#src ==========================
# ### Building the spindle
