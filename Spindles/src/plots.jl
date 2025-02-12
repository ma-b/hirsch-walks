export plot2face

using Plots
using Printf

# return cyclic indices u,v (arrow from u to v) together with Boolean flag that indicates 
# whether the direction is unique (False if edge and reference_edge are parallel)
function directedge(s::Spindle, edge::Vector{Int}, facet::Int)
    u, v = edge

    # direction from u to v
    verts = hcat(vertices(s)...)'   # TODO performance
    r = verts[v,:] - verts[u,:]
    # index of first nonzero entry (exists since u and v are distinct)
    i = findfirst(@. !isapprox(r, 0))
    r ./= abs(r[i]) # normalize
    dotproduct = collect(Polyhedra.halfspaces(s.p))[facet].a' * r

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

label(facets::Vector{Int}, labels::Vector{<:AbstractString}) = join(unique(labels[facets]), ' ')

"""
    plot2face(
        s, facets;
        facetlabels = nothing,
        usecoordinates = false,
        showdist = false,
        edgepair = nothing,
        figsize = (300,300)
    )

2D projection or combinatorial plot (graph)

# Keywords
* `facetlabels`
* `usecoordinates` indicates whether the plot shows a 2D projection or the graph of the 2-face.
* `showdist`

... 
"""
function plot2face(s::Spindle, facets::Vector{Int}; 
    usecoordinates::Bool=false, edgepair::Union{Nothing, Tuple{Vector{Int}, Vector{Int}}}=nothing,
    showdist::Bool=false, facetlabels::Union{Nothing, Vector{<:AbstractString}}=nothing,
    figsize::Tuple{Int, Int}=(300,300), M::Int=15, K::Int=3, L::Int=5
)
    verticesinface = collect(incidentvertices(s, facets))
    n = length(verticesinface)
    
    # list the vertices in cyclic order around the polygon
    cyclic = cyclicorder(induced_subgraph(graph(s), verticesinface)...)

    # ---- coordinates ----

    if usecoordinates
        verts = hcat(vertices(s)...)'  # TODO only use subset of vertices

        # project out all but 2 coordinates in such a way that the projection is 2-dimensional again:
        # the projection is 1-dimensional if the images of all vertices, in particular of the first three 
        # (recall that there are at least three), are collinear.

        function proj_onto_indices(x::Vector{<:Number}, y::Vector{<:Number})
            # TODO assert nonzero

            # find first nonzero component (must exist since x is nonzero)
            i = findfirst(@. !isapprox(x, 0))  # TODO abs tol

            # perform one Gauss step to eliminate component i of y (note: no zero division because of choice of i)
            y_elim = y - x * y[i] / x[i]
            
            # find first nonzero component of resulting vector
            # note that entry i must be zero by construction
            @assert isapprox(y_elim[i], 0)
            j = findfirst(@. !isapprox(y_elim, 0))  # TODO
            # such a j must exist since x and y are linearly independent
            # now the 2x2 matrix induced by components i and j of x and y_elim is of the form [* *; 0 *] and has rank 2,
            # so projecting out all but i,j leaves projections of x and y_elim (and therefore y) linearly independent.
            return (i,j)
        end

        # these two vectors are nonzero (and linearly independent) since they are differences of distinct vertices
        r12 = verts[cyclic[1],:] - verts[cyclic[2],:]
        r13 = verts[cyclic[1],:] - verts[cyclic[3],:]
        # TODO normalize?

        i,j = proj_onto_indices(r12, r13)
        xs, ys = verts[cyclic,i], verts[cyclic,j]  # TODO convert to float
    else
        R = 1
        angles = [2*pi*i/n for i=1:n]
        xs, ys = R * map(cos, angles), R * map(sin, angles)
    end

    # clear plot pane
    plot(
        ticks=nothing, legend=false, aspect_ratio=usecoordinates ? :auto : :equal, 
        framestyle=:box, size=figsize
    )
    plot!(Shape(xs,ys), lw=2, lc=:steelblue, fillcolor=:lightsteelblue1, fillalpha=.5)
    scatter!(xs, ys, markercolor=:steelblue, markersize=5, markerstrokewidth=0)


    # ---- labels ----

    if facetlabels === nothing
        facetlabels = map(string, 1:nhalfspaces(s))
    end

    # vertex and edge labels are unformly shifted outwards from the respective vertex positions and edge midpoints,
    # away from the barycentre of face

    # first compute the barycentre
    bx, by = sum(xs)/length(xs), sum(ys)/length(ys)

    # compute normalized offset vectors
    lengths =  @. sqrt((xs-bx)^2 + (ys-by)^2)
    xlabel_offset, ylabel_offset = map(arr -> (maximum(arr) .- minimum(arr)) / M, [xs,ys])  # TODO
    xs_offset = @. (xs.-bx) / lengths * xlabel_offset
    ys_offset = @. (ys.-by) / lengths * ylabel_offset

    # vertex labels
    for i=1:n
        dists = [dist(s, a, cyclic[i]) for a in apices(s)]
        labeltext = "$(cyclic[i])"
        if showdist
            labeltext *= "\n$(@sprintf("%d | %d", dists...))"
        end

        annotate!(
            xs[i]+K*xs_offset[i], ys[i]+K*ys_offset[i], 
            text(labeltext, 10, :center), 
            #size=12,   # TODO font size
            #color=:blue
        )
    end

    # edge labels
    for i=1:n
        j = mod(i,n)+1  # successor of i on the cycle
        tightfacets = findall(s.inc[cyclic[i]] .& s.inc[cyclic[j]])
        tightfacets = [f for f in tightfacets if !(f in facets)]
        annotate!(
            (sum(xs[[i,j]]) + sum(xs_offset[[i,j]])) / 2,
            (sum(ys[[i,j]]) + sum(ys_offset[[i,j]])) / 2,
            text(label(tightfacets, facetlabels), 8, :center)
        )
    end

    title!(label(facets, facetlabels))
    # face label
    annotate!(bx, by, text(label(facets, facetlabels), :center, 10, :steelblue))

    # set limits
    #L = 1
    plot!(
        xlim=[minimum(xs) - L*xlabel_offset, maximum(xs) + L*xlabel_offset], 
        ylim=[minimum(ys) - L*ylabel_offset, maximum(ys) + L*ylabel_offset]
    )

    # ---- mark up edges ----
    if edgepair !== nothing
        if !all(@. length(edgepair) == 2) || !all(Graphs.has_edge(graph(s), e...) for e in edgepair)
            throw(ArgumentError("invalid edges"))
        end

        for k=1:2
            # get edge-defining inequality for reference edge
            efacets = findall(reduce(.&, s.inc[edgepair[k==1 ? 2 : 1]]))
            ineq = findfirst(f -> !(f in facets), efacets)

            (u,v), uniquedir = directedge(s, edgepair[k], efacets[ineq])
            # get the indices of the endpoints of the edge as they appear in the cyclic order
            i,j = map(x -> findfirst(cyclic .== x), [u,v])
            plot!(
                xs[[i,j]], ys[[i,j]], 
                linecolor=:red, linewidth=3, arrow=uniquedir
                #arrow=arrow(:head, 10, 101)
            )
        end
    end

    return current()
end