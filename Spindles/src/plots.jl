# ================================
# Plots
# ================================

using Plots

export plot2face

# return cyclic indices u,v (arrow from u to v) together with Boolean flag that indicates 
# whether the direction is unique (False if edge and reference_edge are parallel)
function directedge(p::Polytope, edge::Vector{Int}, facet::Int)
    u, v = edge

    # direction from u to v
    verts = hcat(vertices(p)...)'   # TODO performance
    r = verts[v,:] - verts[u,:]
    # index of first nonzero entry (exists since u and v are distinct)
    i = findfirst(@. !isapprox(r, 0))
    r ./= abs(r[i]) # normalize
    dotproduct = collect(Polyhedra.halfspaces(p.poly))[facet].a' * r

    # check whether the vector r points away from or towards the halfspace (or is parallel to the hyperplane)
    if dotproduct == 0
        # parallel
        return (u,v), false  # arbitrary direction
    elseif dotproduct > 0
        # direction r points 'towards' the halfspace, so needs to be reversed
        return (v,u), true
    else
        # direction r already points away
        return (u,v), true
    end
end

# given two nonzero vectors x and y in dimension at least 2, find two coordinates
# such that the projections of x and y onto these coordinates
# are linearly independent if and only if x and y are linearly independent
function proj_onto_indices(x::Vector{<:Real}, y::Vector{<:Real})
    # implementation strategy: use Gaussian elimination

    # TODO assert nonzero

    # find first nonzero component (must exist since x is nonzero)
    i = findfirst(@. !isapprox(x, 0))  # TODO abs tol
    #i !== nothing || # TODO what to return for type stability?

    # perform a single Gauss step to eliminate component i of y
    # (note that the choice of i ensures that we do not divide by zero here)
    y_elim = y - x * y[i] / x[i]
    
    # find the first nonzero component of the resulting vector
    # note that entry i must be zero by construction
    @assert isapprox(y_elim[i], 0)
    j = findfirst(@. !isapprox(y_elim, 0))  # TODO
    # such a j must exist since x and y are linearly independent
    # now the 2x2 matrix induced by components i and j of x and y_elim is of the form [* *; 0 *] and has rank 2,
    # so projecting out all but i,j leaves projections of x and y_elim (and therefore y) linearly independent.
    return (i,j)
end

"""
    plot2face(
        p::Polytope, indices;
        usecoordinates = true,
        vertexlabels   = string.(1:nvertices(p)),
        ineqlabels     = string.(1:nhalfspaces(p)),
        directed_edges = nothing,
        kw...
    )

Make a plot of the 2-face of `p` that is defined by the inequalities indexed by the collection `indices`, 
either as a 2D projection onto the plane if `usecoordinates` is `true`, or as a
(combinatorial) plot of its graph otherwise.

The implementation relies on [Plots.jl](https://github.com/JuliaPlots/Plots.jl).

# Keywords

* `usecoordinates`: If `true` (default), plot a 2D projection onto a coordinate subspace.
  Otherwise draw the graph.
* `vertexlabels`: An indexable collection (such as `AbstractVector` or `AbstractDict`) of strings, 
  or `nothing` to disable vertex labels. If not `nothing`, the label of vertex `i` is 
  `vertexlabels[i]`, where missing values are treated as `""`. 
  If unspecified, use vertex indices as default labels.
* `ineqlabels`: A collection of strings to be used as facet labels, or `nothing` to disable labels.
  If unspecified, use inequality indices as default labels.
* `directed_edges`: An optional tuple of edges `([s,t], [u,v])` to be marked up in the plot. 
  Non-parallel edges are drawn as directed edges in the following way: 
  If the inequality ``\\langle a,x \\rangle \\le \\beta`` defines the edge `[s,t]`, 
  then the other edge `[u,v]` is directed from `u` to `v` if and only if 
  ``\\langle a, v-u \\rangle < 0`` (and vice versa).

The remaining keyword arguments `kw...` are passed to [`plot`](https://docs.juliaplots.org/dev/api/#RecipesBase.plot)
and can be any plot, subplot, or axis attributes.
See also the [Plots.jl documentation pages](https://docs.juliaplots.org/latest/attributes/) 
for a list of available attributes. Some of them are used with a 
different value than their default value in Plots.jl. 
These include `size`, `aspect_ratio`, `title`, `legend`, `framestyle`, `ticks`, and others.

To override the default behaviour of any of the above attributes, pass them as explicit keyword arguments in `kw`
to `plot2face`. Anything in `kw` takes precedence over the default behaviour in `plot2face`, except for (most)
attributes related to annotations, which are hardcoded in `plot2face`.
"""
function plot2face(p::Polytope, indices::AbstractVector{Int}; 
    # custom keyword arguments:
    usecoordinates::Bool = true, 
    vertexlabels::Union{Nothing, AbstractVector{<:AbstractString}, AbstractDict{Int, <:AbstractString}} = string.(1:nvertices(p)),
    ineqlabels::Union{Nothing, AbstractVector{<:AbstractString}} = string.(1:nhalfspaces(p)),
    unique_labels_only::Bool = true,
    directed_edges::Union{Nothing, Tuple{Vector{Int}, Vector{Int}}} = nothing,
    kw...
)
    verticesinface = incidentvertices(p, indices)
    n = length(verticesinface)

    # helper function to concatenate multiple inequality labels into a single string
    concatlabels(labels::AbstractVector{<:AbstractString}) = join(
        unique_labels_only ? unique(labels) : labels, ' '
    )
    
    # list the vertices in cyclic order around the polygon
    cyclic = cyclicorder(Graphs.induced_subgraph(graph(p), verticesinface)...)
    cyclic !== nothing || throw(ArgumentError("the given face is not 2-dimensional"))

    # ---- coordinates ----

    if usecoordinates
        verts = hcat(vertices(p)...)'  # TODO only use subset of vertices

        # project out all but 2 coordinates in such a way that the projection is 2-dimensional again:
        # the projection is 1-dimensional if the images of all vertices, in particular of the first three 
        # (recall that there are at least three), are collinear.

        # these two vectors are nonzero (and linearly independent) since they are differences of distinct vertices
        r12 = verts[cyclic[1],:] - verts[cyclic[2],:]
        r13 = verts[cyclic[1],:] - verts[cyclic[3],:]
        # TODO normalize?

        i,j = proj_onto_indices(r12, r13)
        xs, ys = verts[cyclic,i], verts[cyclic,j]  # TODO convert to float

        # use indices of projection coordinates as axis labels
        subscript_unicode(n::Int) =
            n >= 0 ? join(['\u2080'+d for d in digits(n)]) : throw(ArgumentError("negative subscripts not allowed"))
        xguide, yguide = "x" .* subscript_unicode.([i,j])
    else
        angles = [2*pi*i/n for i=1:n]
        xs, ys = cos.(angles), sin.(angles)
        xguide, yguide = "", ""  # no axis labels
    end

    # clear plot pane
    plot(;
        ticks=nothing, legend=false, framestyle=:box, size=(300,300),
        aspect_ratio = usecoordinates ? :auto : :equal,
        title = ineqlabels !== nothing ? concatlabels(ineqlabels[indices]) : "",
        xguide=xguide, yguide=yguide,
        kw...
    )
    plot!(Shape(xs,ys); lw=2, lc=:steelblue, fillcolor=:lightsteelblue1, fillalpha=.5)
    scatter!(xs, ys; markercolor=:steelblue, markersize=5, markerstrokewidth=0)


    # ---- labels ----

    # constants for fine-tuning label placement
    M = 15
    K = 3
    L = 5

    # vertex and edge labels are unformly shifted outwards from the respective vertex positions
    # and edge midpoints, away from the barycentre of face

    # first compute the barycentre
    bx, by = sum(xs)/length(xs), sum(ys)/length(ys)

    # compute normalized offset vectors
    lengths =  @. sqrt((xs-bx)^2 + (ys-by)^2)
    xlabel_offset, ylabel_offset = map(arr -> (maximum(arr) .- minimum(arr)) / M, [xs,ys])  # TODO
    xs_offset = @. (xs.-bx) / lengths * xlabel_offset
    ys_offset = @. (ys.-by) / lengths * ylabel_offset

    # vertex labels
    if vertexlabels !== nothing
        for i=1:n
            # if index/key not found, don't print a label
            labeltext = get(vertexlabels, cyclic[i], "")

            annotate!(
                xs[i]+K*xs_offset[i], ys[i]+K*ys_offset[i], 
                text(labeltext, 10, :center), 
                #size=12,   # TODO font size
                #color=:blue
            )
        end
    end

    # edge labels
    if ineqlabels !== nothing
        for i=1:n
            j = mod(i,n)+1  # successor of i on the cycle
            tightfacets = _incidenthalfspaces(p, cyclic[[i,j]])
            tightfacets = [f for f in tightfacets if !(f in indices)]
            annotate!(
                (sum(xs[[i,j]]) + sum(xs_offset[[i,j]])) / 2,
                (sum(ys[[i,j]]) + sum(ys_offset[[i,j]])) / 2,
                text(concatlabels(ineqlabels[tightfacets]), 8, :center, :steelblue)
            )
        end

        # face label
        annotate!(bx, by, text(concatlabels(ineqlabels[indices]), 10, :center, :steelblue))
		
        # plot title has already been set above, possibly with facet labels too
    end

    # set limits
    plot!(
        xlim=[minimum(xs) - L*xlabel_offset, maximum(xs) + L*xlabel_offset], 
        ylim=[minimum(ys) - L*ylabel_offset, maximum(ys) + L*ylabel_offset]
    )

    # ---- mark up edges ----
    if directed_edges !== nothing
        if !all(@. length(directed_edges) == 2) || !all(Graphs.has_edge(graph(p), e...) for e in directed_edges)
            throw(ArgumentError("invalid edges"))
        end

        for k=1:2
            # get an edge-defining inequality for the other edge
            edgefacets = incidenthalfspaces(p, directed_edges[k==1 ? 2 : 1])
            ineq = findfirst(f -> !(f in indices), edgefacets)

            (u,v), uniquedir = directedge(p, directed_edges[k], edgefacets[ineq])
            # get the indices of the endpoints of the current edge as they appear in the cyclic order
            i,j = map(x -> findfirst(cyclic .== x), [u,v])
            plot!(
                xs[[i,j]], ys[[i,j]]; 
                linecolor=:red, linewidth=3, arrow=uniquedir
                #arrow=arrow(:head, 10, 101)
            )
        end
    end

    current()
end