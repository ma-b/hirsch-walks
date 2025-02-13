# # Spindles and the Hirsch Conjecture II

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
A, b, _ = readineq("s-25-5.txt", BigInt)
s = Spindle(A, b)

# !!! note
#     We created the spindle `s` from rational data with numerators and denominators of type `BigInt` 
#     (this is the second argument passed to `readineq`). Choosing `Int` here (as in [part I](@ref "Reading a spindle from a file") 
#     of this tutorial) would have produced an integer overflow error. See also the section on 
#     [arbitrary-precision arithmetic](https://docs.julialang.org/en/v1/manual/integers-and-floating-point-numbers/#Arbitrary-Precision-Arithmetic)
#     in the Julia language documentation.

# The following code finds all good 2-faces of `s`.
goodfaces = []
for f in sort(facesofdim(s, 2))
    fstate = isgood2face(s, f)
    if fstate.good
        push!(goodfaces, fstate)
    end
end
length(goodfaces)

# Next, let's plot the graph of each of those 32 good 2-faces:
using Plots

plot_arr = []
for fstate in goodfaces
    push!(plot_arr, 
        plot2face(s, fstate.facets; showdist=true, directed_edges=fstate.edges)
    )
end

ncols = 4
nrows = ceil(Int, length(plot_arr) / ncols)
plot(plot_arr..., layout=(nrows, ncols), size=(1000, nrows*300));
#src savefig("s-25-5_good.svg")

#md # This produces the following figure.

#md # ![](../assets/s-25-5_good.svg)

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

A20, b20, labels = readineq("s-25.txt", BigInt)
s20 = Spindle(A20, b20)

collect(vertices(s20))[apices(s20)]

# Note that `s20` is simple:
using Graphs: degree
all(degree(graph(s20)) .== dim(s20))

# Its most important property, however, is the length of a shortest path between the apices:
dist(s20, apices(s20)...)

# The Hirsch conjecture would imply that there must be a strictly shorter path, namely of length 20.
# Therefore, `s20` is a counterexample to the Hirsch conjecture.

# You may have noticed that computations in dimension 20 take longer than they did in dimension 5.
# Calling `graph` or `dist` for the first time on `s20` (or any `Spindles` function that needs
# the graph, in fact) triggers the computation of the entire graph of `s20`. Luckily, we don't
# have to enumerate all 2-faces of `s20` to identify good ones. 
# Instead, we may take advantage of the structure in its coefficient matrix to "guess" good 2-faces.

#src ==========================
# ## Guessing good 2-faces

# For example, here is one of the good 2-faces of `s` again:
face = [2,8,9]
isgood2face(s, face).good

# The corresponding facets of `s20` are
face20 = [i for (i,label) in enumerate(labels) if parse(Int, label) in face]

# However, three facets do not make a 2-face in dimension 20 yet. We need another 15 facet-defining
# inequalities from the description of `s20`. With some geometric intuition of what the wedging
# operation does, we propose the following rule of thumb: To get up to 18 facets, pick facets from
# those two blocks of "replications" labeled `11` and `25`. Specifically, from each block, pick all
# facets but one. Let us calculate the number of facets in each block:
sum(labels .== "11"), sum(labels .== "25")

# So, in total, our proposed rule of thumb would indeed give us the desired number of $9+8-2=15$ facets.
# Let us "validate" this rule on `face`.
blocks = [findall(labels .== ref) for ref in ["11", "25"]]  # all row indices in one of the two blocks
face20 = [face20; blocks[1][2:end]; blocks[2][2:end]]
join(unique(labels[face20]), " ")

# This is the face we would expect to be a good 2-face. Let us check whether it is:
isgood2face(s20, face20).good

# Great! By omitting the first facet from each block, we immediately found a good 2-face of `s20`.
# Let us plot this face and the original face `face` side by side.

plot(
    plot2face(s, face; usecoordinates=true),
    plot2face(s20, face20; usecoordinates=true, facetlabels=labels),
    layout=grid(1,2), size=(800,300)
)
#md nothing #hide
#src savefig("s-25_two.svg")

#md # The output is

#md # ![](../assets/s-25_compare.svg)

# Not only do their projections look very similar, they are also combinatorially almost identical:

edges  = isgood2face(s, face).edges
edges20 = isgood2face(s20, face20).edges

plot(
    plot2face(s, face; directed_edges=edges, showdist=true),
    plot2face(s20, face20; directed_edges=edges20, showdist=true, facetlabels=labels),
    layout=grid(1,2), size=(800,400)
)
#md nothing #hide
#src savefig("s-25_two_geom.svg")

#md # Now the output is

#md # ![](../assets/s-25_compare_geom.svg)

# The figure on the right is the graph of the 2-face in dimension 20, with facets labeled by 
# which facets of the 5-dimensional spindle `s` they correspond to. Combinatorially,
# the only change is an additional edge (the one defined by `4`). Most importantly, however,
# the property of being good is preserved.

# Next, let us take this one step further and find such a good 2-face in dimension 20 for each of
# the good 2-faces of `s`.

#src TODO