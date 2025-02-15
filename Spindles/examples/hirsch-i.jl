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

# We may read the description from the file as follows.
using Spindles
A, b, labels = readineq("s-48-5.txt", Int);
#-
[A b]

# The function [`readineq`](@ref) does not only return the data in the inequality description 
# $Ax \le b$ from the source but also the attached labels, one for each inequality.

labels

# !!! note
#     Even though we use the same set of labels as Santos in his [paper](https://arxiv.org/pdf/1006.2814),
#     the assignment to the rows of `A` is different.

# The resulting spindle `s` has
s = Spindle(A, b)
nvertices(s)
# vertices and its apices are
collect(vertices(s))[apices(s)]

# The distance between them in the graph of `s` is indeed 6:
dist(s, apices(s)...)

# Note that both apices are highly degenerate:
using Graphs: degree
degree(graph(s), apices(s))

#src ==========================
# ## Inspecting faces

# The original motivation for developing *Spindles.jl* was the search for special two-dimensional faces
# (or *2-faces* for short) of the spindle `s` and similar spindles. 
# To explain what we mean by "special", let us consider the following three facets (note that all inequalities
# in the description given in `s-48-5.txt` are indeed facet-defining):
face = [29, 37, 41]
labels[face]

# They indeed define a 2-face of `s`:
face in facesofdim(s, 2)

# To inspect `face`, we may use the function [`plot2face`](@ref) provided by *Spindles.jl* 
# to make a plot.
plot2face(s, face; ineqlabels=labels)
#src #md nothing #hide

# Each vertex is labeled by its index. Edges and the face itself get their labels from the incident facets, 
# since we passed the `labels` extracted above to the keyword argument `ineqlabels`. Note here that the
# three facets that contain `face` are omitted from the edge labels.

# We may customize the above plot even further. For example, let's add more information to the vertex labels.
# To print the distances of each vertex to the two apices of `s` on a second line
# beneath the vertex index, we first generate all labels in the desired format. Here, we use the format
# `"dist1 | dist2"` for the second line of the label, where `dist1` and `dist2` are placeholders for the
# distances to `apices(s)[1]` and `apices(s)[2]`, respectively.
dist_labels = map(1:nvertices(s)) do v
    "$v\n" * join(dist.((s,), apices(s), v), " | ")
end

# !!! note "Julia syntax"
#     ````julia
#     dist.((s,), apices(s), v)
#     ````
#     is a shorthand for
#     ````julia
#     [dist(s, apex, v) for apex in apices(s)]
#     ````
#     Wrapping `s` in a tuple makes sure that the Julia "broadcast dot" is only applied
#     to the second argument of `dist`, namely `apices(s)`, and not to the first argument `s` 
#     (which is not iterable).

# Our custom vertex labels can now be passed to `plot2face` as follows:
plot2face(s, face; ineqlabels=labels, vertexlabels=dist_labels, usecoordinates=false)
#src #md nothing #hide

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
apices(s)
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
# the distance of $V_1$ to `apices(s)[1]` is 0 and that of any vertex in $V_2$ to `apices(s)[2]` is 3.

#src We will come back to the choice of this number $k$ in a moment. First,
# Let's visualize the two sets $V_1$ and $V_2$. Again, we tweak the arguments passed to
# `plot2face` and label the vertices of the face by which set they belong to. For example, this
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
plot2face(s, face; ineqlabels=nothing, vertexlabels=set_labels, usecoordinates=false, title="V₁ and V₂")

# Note that there are exactly two edges of the face `15⁺ 19⁺ 21⁺` whose endpoints do not belong
# to neither $V_1$ nor $V_2$ (and, hence, are only labeled by their index in the plot above). These edges are those
# between `25` and `57`, and between `33` and `81`.
# Let's mark them up in the plot using the keyword argument `directed_edges`:
plot2face(s, face; 
    ineqlabels=nothing, vertexlabels=set_labels, 
	directed_edges=([25,57], [33,81]),
    usecoordinates=false, title="V₁ and V₂"
)

# Not only are the two edges marked up in the plot, they are also drawn as *directed* edges now.
# To see why (and how this direction is determined by `plot2face`),
# recall that each of them is contained in a shortest path between the apices of `s`
# that walks along parts of the face `15⁺ 19⁺ 21⁺`. For example, coming from the second apex
# (the one not contained in the face) and heading towards the first apex `1`,
# the two red edges are traversed in exactly the direction indicated above. 
# If we look at the "true" geometry of `15⁺ 19⁺ 21⁺`, though, we could also start from any vertex in $V_2$
# and follow one of the two red arrows (through the interior of the face!)
# as far as possible without leaving the face.
plot2face(s, face; 
    ineqlabels=nothing, vertexlabels=set_labels, 
	directed_edges=([25,57], [33,81]),
    usecoordinates=true, title="V₁ and V₂"
)

# The geometry of the 2-face tells us that the point on the boundary that we hit must be on one of the
# two edges incident to the apex `1`. From that point, we walk along the edge and reach `1` within
# (at most) two steps on the face, rather than three steps along its boundary.
# So, in a relaxed regime where paths may pass through the interior of a face, one might consider taking
# three edges steps from the second apex to some vertex in $V_2$, then apply the two-step "shortcut" through
# the interior of the face `15⁺ 19⁺ 21⁺`, and end up at the first apex `1`. This yields (at most) 5 steps in total.
# Recall that in the traditional regime where paths through the interior are forbidden, one cannot do better than 6 steps.

# !!! note
#     It is important to note here that, unlike paths along edges,
#     this shortcut has a direction associated to it. The direction
#     is determined by the geometry of the 2-face `15⁺ 19⁺ 21⁺` and is indicated by the direction of the two
#     red edges. When making a plot with `plot2face` as above, they are always drawn in such a way that the arrows
#     "point away" from each other.

# Shortcuts like this are precisely what makes faces such as `15⁺ 19⁺ 21⁺` interesting for analyzing `s`
# in the setting of the so-called *circuit diameter conjecture*, a relaxation of the Hirsch conjecture
# that allows for paths through the interior of a polytope.

# Let us call a 2-face of a spindle a *good 2-face* if it allows for such a shortcut between the apices as above
# (regardless of its direction). 
# *Spindles.jl* provides a function [`isgood2face`](@ref) that tests a face for being good.

isgood2face(s, face)

# The result is wrapped in a bespoke data type called
# [`FaceState`](@ref Spindles.FaceState). The field `good` indicates whether or not
# the tested face is good, and the two vertex sets $V_1$ and $V_2$ that certify the property
# of being good are stored in the field `vsets` (see also the documentation on the
# [`FaceState`](@ref Spindles.FaceState) type):

fstate = isgood2face(s, face)
fstate.good, fstate.vsets

# Feel free to compare the output with the sets $V_1$ and $V_2$ that we identified above.

#src ==========================
# ## Finding all good 2-faces

# Using [`isgood2face`](@ref), all good 2-faces of `s` are easily enumerated.
for f in sort(facesofdim(s, 2))
    if isgood2face(s, f).good
        println(join(labels[f], " "))
    end
end

# In particular, for each good 2-face, there must exist paths from both apices to
# some vertex on the face of total length at most 3. 
# Interestingly, all 2-faces of `s` that satisfy this weaker condition are good:
for f in sort(facesofdim(s, 2))
    min_total_length = sum(
        minimum(
            dist(s, a, v) for v in incidentvertices(s, f)
        ) for a in apices(s)
    )
    if min_total_length <= 3
        println(join(labels[f], " "), "\t", isgood2face(s, f).good)
    end
end

# If you would like to explore one of the actual counterexamples to the Hirsch conjecture
# that was built from a spindle like `s`, please read on [here](@ref "Spindles and the Hirsch conjecture II").
