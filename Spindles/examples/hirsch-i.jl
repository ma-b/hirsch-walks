# # Spindles and the Hirsch conjecture I

#md # [![](https://img.shields.io/badge/show-nbviewer-579ACA.svg)](@__NBVIEWER_ROOT_URL__/tutorials/Spindles and the Hirsch conjecture I.ipynb)

# In this tutorial, we will explore a particular spindle that is known from theory to have
# an interesting property: Its apices are far away from each other in the graph of the spindle.
# This property made it possible to disprove a long-standing conjecture in polyhedral theory,
# the so-called *Hirsch conjecture*. Even though the focus of this tutorial is on a thorough
# analysis of the special spindle, we will showcase some more advanced functionalities
# and customization options of *Spindles.jl* along the way.
# For the basic usage, please read [this tutorial](@ref "First steps") first.

#md # !!! note
#md #     This tutorial is also available as a Jupyter notebook. 
#md #     Click on the badge above to view it in [nbviewer](https://nbviewer.jupyter.org/).

#src ==========================
# ## The Hirsch conjecture

# The [Hirsch conjecture](https://en.wikipedia.org/wiki/Hirsch_conjecture) for polytopes 
# stated that any two vertices of a $d$-dimensional polytope with $f$ facets can be connected
# by a path of at most $f-d$ edges. It was disproved in 2010 when Francisco Santos found a
# [construction](https://arxiv.org/abs/1006.2814) that produces counterexamples from spindles
# with a special property: the length of a shortest path between the apices
# (called the *length* of the spindle) must be strictly greater than the dimension.

# Santos' original counterexample from 2010 is based on a 5-dimensional spindle with 48 facets, 
# for which the shortest path between the apices is of length 6. A minimal inequality description
# of this spindle (see Table 1 in Santos' [paper](https://arxiv.org/pdf/1006.2814)) can be found
# in the file `s-48-5.txt` located in the `examples` folder beneath the package root directory `Spindles`.

#src ==========================
# ## Reading a spindle from a file

# The data can be read from the file using the function [`readineq`](@ref) as follows.
using Spindles
A, b, labels = readineq("s-48-5.txt", Int);

# The function returns not only the coefficient matrix `A` and vector of 
# right-hand sides `b` of the description $Ax \le b$ 
[A b]
# but also a label for each inequality:
labels

# !!! note
#     Even though we use the same set of labels as Santos in his [paper](https://arxiv.org/pdf/1006.2814),
#     the assignment to the rows of `A` is different.

# The resulting spindle `s` has
s = Polytope(A, b)
nvertices(s)
# vertices and its apices are
apx = apices(s)
collect(vertices(s))[apx]

# The distance between them in the graph of `s` is indeed 6:
dist(s, apx...)

# Note that both apices are highly degenerate:
using Graphs: degree
degree(graph(s), apx)

#src ==========================
# ## Inspecting faces

# The original motivation for developing *Spindles.jl* was the search for special two-dimensional faces
# (or *2-faces* for short) of the spindle `s` and similar spindles. 
# To explain what we mean by "special", let us consider the following three facets (note that all inequalities
# in the description given in `s-48-5.txt` are indeed facet-defining):
face = [29, 37, 41]
labels[face]

# They indeed define a 2-face of `s`:
dim(s, face) == 2
#src face in facesofdim(s, 2)

# To inspect `face`, we may use the `plot` command from [Plots.jl](https://github.com/JuliaPlots/Plots.jl)
# to make a plot.
using Plots
plot(s, face; ineqlabels=labels)
#src nothing # hide

# This creates a two-dimensional projection of `face` onto the two coordinates
# by which the axes are labeled above.

# Each vertex is labeled by its index. Edges and the face itself get their labels from the incident facets, 
# since we passed the `labels` extracted above to the keyword argument `ineqlabels`. Note here that the
# three facets that contain `face` are omitted from the edge labels.

# We may customize the above plot even further. For example, let's add more information to the vertex labels.
# To print the distances of each vertex to the two apices of `s` on a second line
# beneath the vertex index, we first generate all labels in the desired format. Here, we use the format
# `"dist1 | dist2"` for the second line of the label, where `dist1` and `dist2` are placeholders for the
# distances to `apx[1]` and `apx[2]`, respectively.
dist_labels = map(1:nvertices(s)) do v
    "$v\n" * join(dist.(s, apx, v), " | ")
end

# !!! note "Julia syntax"
#     ````julia
#     dist.(s, apx, v)
#     ````
#     is a shorthand for
#     ````julia
#     [dist(s, a, v) for a in apx]
#     ````

# Our custom vertex labels can now be passed to `plot` as follows:
plot(s, face; ineqlabels=labels, vertexlabels=dist_labels, usecoordinates=false)
#src nothing # hide

# Note here that the (optional) additional argument `usecoordinates=false` changed the plot mode 
# to a (combinatorial) drawing of the graph of the face `15⁺ 19⁺ 21⁺` rather than a planar projection of
# its true coordinates as above.

#src ==========================
# ## A good 2-face

# Next, let's take a closer look at our custom labels in the plot that we just generated. 
# For each vertex of the face, the sum of both distances on the second line of its label must be at least 6,
# since we know that there is no shorter path between the apices. In fact, there are (at least) two such 
# shortest paths that traverse parts of the face:
# One of the apices of `s` actually is a vertex of the face, namely the first apex
apx
# at index `1`. Start from there and take
# 3 steps to either `56` or `80`. Both vertices are at distance 3 from the second apex, 
# as their labels tell us. 
# The only two vertices that are not visited on either of those two paths are `155` and `156`,
# and they are also at distance 3 from the second apex. 

# So among the vertices of the face `15⁺ 19⁺ 21⁺`, there are two special subsets:
# One subset of vertices, let us call it $V_1$, is "close" to the first apex
# (namely, take $V_1$ to be the apex `1 ` itself). The other subset $V_2$
# (the subset consisting of `56`, `155`, `156`, and `80`) is disjoint from the
# first one, and each vertex in $V_2$ is "close" to the second apex . Here, "close" means that
# if we pick two arbitrary vertices, one from each subset, then the sum of their distances
# to the respectively closest apex is at most some given number $k$. 
#src that only depends on the dimension of the spindle. 
# In our case, any $k \ge 3$ would work for this definition of being "close", since
# the distance of $V_1$ to `apx[1]` is 0 and that of any vertex in $V_2$ to `apx[2]` is 3.

#src We will come back to the choice of this number $k$ in a moment. First,
# Let's visualize the two sets $V_1$ and $V_2$. Again, we tweak the arguments passed to
# `plot` and label the vertices of the face by which set they belong to. For example, this
# can be achieved by
set_labels = map(1:nvertices(s)) do v
    if v == 1
        return "$v ∈ V₁"
    elseif v in [56, 155, 156, 80]
        return "$v ∈ V₂"
    else
        return "$v"  # default label for vertices in neither of the two sets
    end
end
plot(s, face; ineqlabels=nothing, vertexlabels=set_labels, usecoordinates=false, title="V₁ and V₂")
#src nothing # hide

# Note that there are exactly two edges of the face `15⁺ 19⁺ 21⁺` whose endpoints belong
# to neither $V_1$ nor $V_2$ (and, hence, are only labeled by their index in the plot above). These edges are those
# between `25` and `57`, and between `33` and `81`.
# Let's mark them up in the plot using the keyword argument `markup_edges`:
plot(s, face; 
    ineqlabels=nothing, vertexlabels=set_labels, 
    markup_edges=([25,57], [33,81]),
    usecoordinates=false, title="V₁ and V₂"
)
#src nothing # hide

# Not only are the two edges marked up in the plot, they are also drawn as *directed* edges now.
# To see why (and how this direction is determined by `plot`), let's look at the true geometry of 
# the face `15⁺ 19⁺ 21⁺` again:
plot(s, face; 
    ineqlabels=nothing, vertexlabels=set_labels, 
    markup_edges=([25,57], [33,81]),
    usecoordinates=true, title="V₁ and V₂",
    xguide="", yguide=""  # hide axis labels
)

# Now the two arrows point away from each other – this is precisely how the `plot` command decides
# at which endpoints to place the arrow tips.

# Yet what do these directions tell us?
# To explain this, recall that each of the highlighted edges belongs to a shortest path (of length 6) between the apices of `s`.
# For example, we saw above that there is path of length 3 between the second apex of `s`
# (the one not contained in the face) and the vertex `156` (since `156` is in $V_2$). From `156`,
# it's only 3 more edge steps to the first apex `1`. 
# Now imagine that we travel along the edges of this path towards `1`, and orient each edge
# according to our direction of travel. Then the path becomes a sequence of steps in certain directions,
# where we follow each direction as far as we can – namely, until we hit the next vertex along the path.

# What happens if we choose different directions at each step? For example, suppose that we have reached `156`, 
# and now choose one of the two highlighted edge directions.
# To visualize the situation, we need a little extra code.
# First, let's define a function that, given a starting point `z` and a direction `g`,
# determines how far we can walk without leaving the face. In a formula, this is the maximum number
# $\mu$ for which $A(z+\mu g) \le b$ (note that the maximum is indeed finite because the spindle `s` is a polytope).

function maxsteplength(z, g)
    ## ignore rows of A whose dot product with the given direction is <= 0
    ## since the corresponding inequalities will be satisfied for any positive step length
    divpos(x, y) = y > 0 ? x/y : Inf
    minimum(divpos.(b - A * z, A * g))
end
nothing # hide

# With this helper function, we can now visualize what happens after a hypothetical step along
# either of the two arrows. In fact, we just add to the previous plot by using `plot!` instead of `plot`.
edges = ((81,33), (57,25))  # the two edges marked up above
source = collect(vertices(s))[156]

for (u, v) in edges
    edge_direction = collect(vertices(s))[v] - collect(vertices(s))[u]
    μ = maxsteplength(source, edge_direction)
    destination = source + μ * edge_direction

    plot!(
        ## project points onto the same two coordinates (1 and 5) as the face
        [source[1], destination[1]], [source[5], destination[5]],
        seriestype=:arrow, linestyle=:dash, linewidth=2, linecolor=:darkorange2, 
    )
end
current()

# !!! note "Plotting arrows"
#     The series type `arrow` is a custom series type defined by *Spindles.jl*.

# The plot above tells us that either of the two dashed arrows
# (which are parallel to the marked up edges) leads us directly onto an edge that is incident with
# `1`, rather than taking the "detour" along edges. In a nutshell, this is the reason why the face 
# `15⁺ 19⁺ 21⁺` is so interesting for analyzing paths on the spindle `s`: It allows for a "shortcut" when
# steps through the interior of the face are allowed.
# Note that the choice of the vertex `156` above was arbitrary. 
# Indeed, we could translate the tails of the two dashed arrows over to any other vertex in $V_2$ 
# and still construct similar shortcuts on the face.

# Let us call a 2-face of a spindle a *good 2-face* if it allows for such a shortcut between the apices as above
# (regardless of its direction). 
# *Spindles.jl* provides a function [`isgood2face`](@ref) that tests a face for being good.

isgood2face(s, face, apx...)

# The result is wrapped in a bespoke data type called
# [`FaceState`](@ref Spindles.FaceState). The field `good` indicates whether or not
# the tested face is good, and the two vertex sets $V_1$ and $V_2$ that certify the property
# of being good are stored in the field `vsets` (see also the documentation on the
# [`FaceState`](@ref Spindles.FaceState) type):

fstate = isgood2face(s, face, apx...)
fstate.good, fstate.vsets

# Feel free to compare the output with the sets $V_1$ and $V_2$ that we identified above.

#src ==========================
# ## Finding all good 2-faces

# Using the functions [`facesofdim`](@ref) and [`isgood2face`](@ref), all good 2-faces of `s` are easily enumerated.
for f in sort(collect(facesofdim(s, 2)))
    if isgood2face(s, f, apx...).good
        println(join(labels[f], " "))
    end
end

# In particular, for each good 2-face, there must exist paths from both apices to
# some vertex on the face of total length at most 3. 
# Interestingly, all 2-faces of `s` that satisfy this weaker condition are good:
for f in sort(collect(facesofdim(s, 2)))
    min_total_length = sum(
        minimum(  # minimum distance of the apices to any vertex on the face
            dist(s, a, v) for v in incidentvertices(s, f)
        ) for a in apx
    )
    if min_total_length <= 3
        println(join(labels[f], " "), "\t", isgood2face(s, f, apx...).good)
    end
end

# If you would like to explore one of the actual counterexamples to the Hirsch conjecture
# that was built from a spindle like `s`, please read on [here](@ref "Spindles and the Hirsch conjecture II").
