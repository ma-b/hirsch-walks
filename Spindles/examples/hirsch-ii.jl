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
# ## Good faces in dimension 5

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

## generate vertex labels
dist_labels = map(1:nvertices(s)) do v
    "$v\n" * join(dist.(s, apx, v), " | ")
end

plot_arr = []  # collect subplots to make one subplot per face in the final plot
for fstate in goodfaces
    push!(plot_arr, 
        plot(s, fstate.indices; usecoordinates=false,
            vertexlabels=dist_labels, directed_edges=fstate.edges
        )
    )
end

ncols = 4
nrows = ceil(Int, length(plot_arr) / ncols)  # maximum number of subplots per column
plot(plot_arr..., layout=(nrows, ncols), size=(1000, nrows*300), plot_title="Good 2-faces")

#src ==========================
# ## Good faces in dimension 20

#src ==========================
# ### Patterns in the inequality description
# As a warm-up, let's take a look at the inequality description of the 20-dimensional spindle.
# A minimal description is provided in the file `s-25.txt`:
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

# For our purposes, the correspondence between rows of `A20` and `A` will be extremely useful
# in "guessing" good 2-faces of the 20-dimensional spindle.

#src ==========================
# ### Building the spindle
# Before we examine its faces, let us first
# read the file and construct a `Spindle` object from it.

A20, b20, labels = readineq("s-25.txt", BigInt)
s20 = Polytope(A20, b20)
# To speed up computations, we tell the function `apices` that 
# the system of linear inequalities specified by `A20` and `b20` is known to be minimal,
# by using the keyword argument `checkredund` (see also the API documentation on [`apices`](@ref)):
apx20 = apices(s20; checkredund=false)
collect(vertices(s20))[apx20]

# Note that `s20` is simple:
using Graphs: degree
all(degree(graph(s20)) .== dim(s20))

# Its most important property, however, is the length of a shortest path between the apices:
dist(s20, apx20...)

# The Hirsch conjecture would imply that there must be a strictly shorter path, namely of length 20.
# Therefore, `s20` is a counterexample to the Hirsch conjecture.

# You may have noticed that computations in dimension 20 take longer than they did in dimension 5.
# Calling `graph` or `dist` for the first time on `s20` (or any `Spindles` function that needs
# the graph, in fact) triggers the computation of the entire graph of `s20`. Luckily, we don't
# have to enumerate all 2-faces of `s20` to identify good ones. 
# Instead, we may take advantage of the structure in its coefficient matrix to "guess" good 2-faces.

#src ==========================
# ### "Guessing" good 2-faces

# For example, here is one of the good 2-faces of `s` again:
face = [2,8,9]
isgood2face(s, face, apx...).good

# To get the corresponding facets of `s20`, we define a function
# that sends a given subset of row `indices` of `A` to the corresponding rows of `A20`. 
map5to20(indices) = findall(label -> label in string.(indices), labels)
map5to20(face)

# Three facets don't define a 2-face in dimension 20 yet. We need another 15 facet-defining
# inequalities from the description of `s20` (recall that `s20` is simple). 
# With some geometric intuition of what the wedging operation does, 
# we propose the following rule of thumb: To get up to 18 facets, pick facets from
# those two blocks of "replications" labeled `11` and `25`. Specifically, from each block, pick all
# facets but one. Let us calculate the number of facets in each block:
length(map5to20([11])), length(map5to20([25]))
#src sum(labels .== "11"), sum(labels .== "25")

# So, in total, our proposed rule of thumb would indeed give us the desired number of $9+8-2=15$ facets.
# Let us "validate" this rule on `face`. 
# Suppose that we omit the first index in each block. Then, by our rule, we would expect the following 18
# facets to define a 2-face of `s20`:
face20 = [
    map5to20(face);
    map5to20([11])[2:end]; 
    map5to20([25])[2:end]
]
#src join(unique(labels[face20]), " ")

# Let's check whether they do, using [`isgood2face`](@ref) (which not only tests a face for being good
# but also checks its dimension first).
isgood2face(s20, face20, apx20...).good

# Great! We have indeed found a good 2-face of `s20`.
# Let us plot this face and the original one in dimension 5 side by side.

plot(
    plot(s, face; vertexlabels=nothing),
    plot(s20, face20; vertexlabels=nothing, ineqlabels=labels),
    layout=grid(1,2), size=(800,300)
)

# Not only do their projections look very similar, the two faces are also combinatorially almost identical.
# To see this, let us make plots of their graphs. For `s20`, we would like the same kind of vertex labels
# that we generated for the smaller spindle above:
dist_labels20 = Dict(map(incidentvertices(s20, face20)) do v
    v => "$v\n" * join(dist.(s20, apx20, v), " | ")
end)

# Note here that we only generated labels for the vertices of `face20` and stored them in a more compact dictionary
# rather than a (long) list of labels for *all* vertices of `s20`. For the purpose of plotting,
# this does not make a difference, since the function `plot` also accepts a dictionary of labels: 

#-
edges = isgood2face(s, face, apx...).edges
edges20 = isgood2face(s20, face20, apx20...).edges

plot(
    plot(s, face; usecoordinates=false, vertexlabels=dist_labels, directed_edges=edges),
    plot(s20, face20; usecoordinates=false, vertexlabels=dist_labels20, ineqlabels=labels, directed_edges=edges20),
    layout=grid(1,2), size=(800,400)
)

# The figure on the right is the graph of the 2-face in dimension 20, with facets labeled by 
# which facets of the 5-dimensional spindle `s` they correspond to. Combinatorially,
# the only change is an additional edge (the one defined by `4`). Most importantly, however,
# the property of being good is preserved, since the two vertex sets $V_1$ and $V_2$ are still sufficiently
# close to the apices. Here, "sufficiently close" again means that there are paths from any pair of vertices in
# $V_1$ and $V_2$ to the apices `apx20[1]` and `apx20[2]`, respectively, of total length $20-2=18$.

#src ==========================
# ### Many good faces

# Next, let's take the analysis one step further and find such a good 2-face in dimension 20 for each of
# the good 2-faces of `s`. The following code prints one line for each good 2-face of the 5-dimensional
# spindle `s`, listing its incident facets with their indices in `A` and the corresponding indices
# in `A20`. The output also includes a possible choice of index pairs according to our rule of thumb above.

for (count, gf) in enumerate(goodfaces)
    ## loop through all pairs of indices in the two blocks corresponding to labels 11 and 25
    for i = 1:length(map5to20([11])), j = 1:length(map5to20([25]))
        ## the face obtained after omitting i and j is:
        f = unique([
            map5to20(gf.indices);
            map5to20([11])[1:end .!= i]; 
            map5to20([25])[1:end .!= j]
        ])
        
        if isgood2face(s20, f, apx20...).good
            println("good face #$(count):\t", gf.indices, "\t->   ", map5to20(gf.indices), "\t(except $i, $j)")
            break
        end
    end
end

# Notice that four good faces of `s` are incident to facets `11` or `25`. Recall that the corresponding rows of `A`
# are precisely those that were "replicated" to obtain `A20` from `A`. For those good faces, the analogous face
# in dimension 20 needs to be contained in *all* facets of the respective block of replications.