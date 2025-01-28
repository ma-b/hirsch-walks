export plot2face

using Plots
using Printf

# return cyclic indices u,v (arrow from u to v) together with Boolean flag that indicates 
# whether the direction is unique (False if edge and reference_edge are parallel)
function directedge(s::Spindle, edge::Vector{Int}, facet::Int)
    u,v = edge

    # direction from u to v
    verts = hcat(vertices(s)...)'   # TODO performance
    r = verts[v,:] - verts[u,:]
    # index of first nonzero entry (exists since u and v are distinct)
    i = findfirst(@. !isapprox(r, 0))
    #@show i
    r ./= abs(r[i]) # normalize
    dotproduct = s.B[facet,:]' * r

    # check whether the vector r points away from or towards the halfspace (or is parallel to the hyperplane)
    if dotproduct == 0
        # parallel
        return nothing, false
    elseif dotproduct > 0
        # direction r points 'towards' the halfspace, so needs to be reversed
        return (v,u), true
    else
        # direction r already points away
        return (u,v), true
    end
end

label(facets::Vector{Int}, labels::Vector{<:AbstractString}) = join(labels[facets], ' ')

"""
    plot2face(s, facets [,...])

2D projection or combinatorial plot (graph)
"""
function plot2face(s::Spindle, facets::Vector{Int}; 
    usecoordinates::Bool=false, edgepair::Union{Nothing, Tuple{Vector{Int}, Vector{Int}}}=nothing,  # TODO more specific type for markupedges
    #facelabel::Bool=true, edgelabels::Bool
    #labels=label(:face, :edge, :vertex)
    facetlabels::Union{Nothing, Vector{<:AbstractString}}=nothing, #map(string, 1:size(s.B,1))
    figsize::Tuple{Int, Int}=(300,300),
    #plot_kwargs...
)
    if !graphiscomputed(s)
        computegraph!(s)
    end

    verticesinface = collect(incidentvertices(s, facets))
    face_subgraph, vmap = induced_subgraph(s.graph, verticesinface)
    edgesinface = [(vmap[src(e)], vmap[dst(e)]) for e in Graphs.edges(face_subgraph)]
    n = length(verticesinface)

    # we avoid building the graph using Graphs package...
    # TODO compare @time Graphs.induced_subgraph
    # and instead build adjacency list, probably not much more expensive than building a high-level graph?
    # or try adj matrix? sum over row/col must be 2 everywhere
    adj = Dict(v => [] for v in verticesinface)
    for (u,v) in edgesinface
        push!(adj[u],v)
        push!(adj[v],u)
    end

    cyclic = cyclicorder(adj)

    # ---- coordinates ----

    if usecoordinates
        verts = hcat(vertices(s)...)'  # TODO performance? only use subset of vertices...

        # project out all but 2 coordinates in such a way that the projection is 2-dimensional again:
        # the projection is 1-dimensional if all vertices, in particular the first three (recall that there
        # are at least three), are collinear.

        r12 = verts[cyclic[1],:] - verts[cyclic[2],:]
        r13 = verts[cyclic[1],:] - verts[cyclic[3],:]
        # must be lin indep
        # TODO normalize?
        #@show r12
        #@show r13

        # TODO better check absolute value > EPS ?
        # find first nonzero component
        i = findfirst(r12 .!= 0)
        #@show i

        # perform one Gauss step to eliminate component i of r2 (note: no zero division because of choice of i)
        r13_elim = r13 - r12 * r13[i] / r12[i]
        #@show r13_elim #r12 * r13[i] / r12[i]#r13_
        
        # find first nonzero component of resulting vector
        # note that entry i must be zero (or approx?)
        @assert isapprox(r13_elim[i], 0)  # TODO or == 0
        j = findfirst(@. !isapprox(r13_elim, 0))  # TODO test
        # such a j must exist since r1 and r2 are lin indep (collinear => not vertices)
        # now the 2x2 matrix induced by components i and j of r1 and r2_ is of the form [* *; 0 *] and has rank 2,
        # so projecting out all but i,j leaves projections of r1 and r2_ (and therefore r2) linearly independent.
        #proj_onto_coords = i,j
        #@show i,j
        
        xs, ys = verts[cyclic,i], verts[cyclic,j]
        # TODO better convert to float
    else
        R = 1
        angles = [2*pi*i/n for i=1:n]
        xs, ys = R * map(cos, angles), R * map(sin, angles)
    end

    # clear plot pane
    plot(
        #border=:none, ticks=(0),
        ticks=nothing, legend=false, aspect_ratio=usecoordinates ? :auto : :equal, 
        framestyle=:box, size=figsize
    )
    plot!(Shape(xs,ys), lw=2, lc=:steelblue, fillcolor=:lightsteelblue1, fillalpha=.5)
    scatter!(xs, ys, markercolor=:steelblue, markersize=5, markerstrokewidth=0)


    # ---- labels ----

    # barycentre of face
    bx, by = sum(xs)/length(xs), sum(ys)/length(ys)

    # normalize offset vectors
    lengths = @. sqrt((xs-bx)^2 + (ys-by)^2)
    M = 3  # factor by which the normalized offset vector is scaled
    xlabel_offset, ylabel_offset = map(arr -> (maximum(arr) .- minimum(arr)) / M, [xs,ys])  # TODO

    xs_offset = (xs.-bx) / lengths * xlabel_offset
    ys_offset = (ys.-by) / lengths * ylabel_offset

    if facetlabels === nothing
        facetlabels = map(string, 1:size(s.B,1))
    end

    
    # vertex labels
    for i=1:n
        dists = [dist_toapex(s, a, cyclic[i]) for a in apices(s)]
        annotate!(
            xs[i]+2*xs_offset[i], ys[i]+2*ys_offset[i], 
            text("$(cyclic[i])\n$(@sprintf("%d | %d", dists...))", 10, :center), 
            #size=12,   # TODO font size
            #color=:blue
            #, horizontalalignment='center', verticalalignment='center'
        )
    end

    # edge labels
    if true #show_edge_labels:
        for i=1:n
            j = mod(i,n)+1  # successor of i on the cycle
            tightfacets = findall(s.inc[cyclic[i]] .& s.inc[cyclic[j]])  # TODO exclude facets
            tightfacets = [f for f in tightfacets if !(f in facets)] # is Bool vector more efficient than BitVector?
            annotate!(
                (xs[i]+xs[j]+xs_offset[i]+xs_offset[j])/2, 
                (ys[i]+ys[j]+ys_offset[i]+ys_offset[j])/2,
                text(label(tightfacets, facetlabels), 8, :center)
            )
        end
    end

    title!(label(facets, facetlabels))
    if true #show_face_label:
        annotate!(bx, by, text(label(facets, facetlabels), :center, 10, :steelblue))  # TODO vert/horiz text alignment? # gray35
    end

    # set limits
    L = 1
    plot!(
        xlim=[minimum(xs) - L*xlabel_offset, maximum(xs) + L*xlabel_offset], 
        ylim=[minimum(ys) - L*ylabel_offset, maximum(ys) + L*ylabel_offset]
    )

    # ---- mark up edges ----
    if edgepair !== nothing
        # TODO check two edges, and of length 2 each

        for k=1:2
            # TODO # get edge-defining inequality for reference edge
            efacets = findall(reduce(.&, s.inc[edgepair[k==1 ? 2 : 1]]))
            efacets = [f for f in efacets if !(f in facets)]
            #@show efacets
            if length(efacets) > 1
                println("degenerate endpoints")
            end
            ineq = efacets[1]  # get single element

            (u,v), uniquedir = directedge(s, edgepair[k], ineq)
            i,j = map(x -> findfirst(cyclic .== x), [u,v])
            plot!(xs[[i,j]],ys[[i,j]], linecolor=:red, linewidth=3, 
                arrow=uniquedir
                #arrow=arrow(:head, 10, 101)
            )
        end
    end

    return current()
end