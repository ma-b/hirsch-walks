# ================================
# Plots
# ================================

# see https://docs.juliaplots.org/stable/recipes/
using RecipesBase
using Plots: text  # TODO can we get rid of Plots dependency?

# return cyclic indices u,v (arrow from u to v) together with Boolean flag that indicates 
# whether the direction is unique (False if edge and reference_edge are parallel)
function directedge(p::Polytope, edge::Vector{Int}, facet::Int)
    u, v = edge  # TODO arg check

    # direction from u to v
    verts = collect(vertices(p))[[u,v]]
    r = verts[2] - verts[1]
    # index of first nonzero entry (exists since u and v are distinct)
    i = findfirst(@. !isapprox(r, 0))
    r ./= abs(r[i]) # normalize
    dotproduct = collect(Polyhedra.halfspaces(p.poly))[facet].a' * r  # FIXME non-public API?

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
    i,j
end


# WARNING: type annotations on kwargs not supported in recipes
@recipe function f(p::Polytope, indices::AbstractVector{<:Integer};
    # custom keyword arguments:
    usecoordinates=true,  #::Bool
    vertexlabels=string.(1:nvertices(p)), #::Union{Nothing, AbstractVector{<:AbstractString}, AbstractDict{Int, <:AbstractString}}
    ineqlabels=string.(1:nhalfspaces(p)), #::Union{Nothing, AbstractVector{<:AbstractString}}
    unique_labels_only=true, #::Bool
    markup_edges=nothing,  #::Union{Nothing, Tuple{Vector{Int}, Vector{Int}}}
    markup_linecolor=:darkorange2, markup_linewidth=3,
    linecolor=:steelblue,  # aliases like `lc` still seem to work(?)
)
    # TODO check arguments

    if markup_edges !== nothing && 
            (!all(@. length(markup_edges) == 2) || !all(Graphs.has_edge(graph(p), e...) for e in markup_edges))
        throw(ArgumentError("invalid edges"))
    end

    # warn user if trying to set the value of an attribute whose value
    # is forced with `:=` (as opposed to the overridable `-->`)  below
    attr_hardcoded = [:legend, :framestyle, :markerstrokewidth]
    attrs = ["\"$attr\"" for attr in attr_hardcoded if haskey(plotattributes, attr)]
    if !isempty(attrs)
        if length(attrs) <= 2
            str = join(attrs, " and ")
        elseif length(attrs) > 2
            str = join(attrs[1:end-1], ", ") * ", and " * attrs[end]
        end
        @warn "setting attribute" * (length(attrs)>1 ? "s" : "") * " " * str * " has no effect here"
    end

    # ----------------------

    verticesinface = incidentvertices(p, indices)
    n = length(verticesinface)

    # list the vertices in cyclic order around the polygon
    cyclic = cyclicorder(Graphs.induced_subgraph(graph(p), verticesinface)...)
    cyclic !== nothing || throw(ArgumentError("the given face is not 2-dimensional"))

    # shorthands for indices of successor and predecessor of i in the cyclic order of vertices
    succ(i::Int) = mod(i,  n) + 1  # (i-1)+1
    pred(i::Int) = mod(i-2,n) + 1  # (i-1)-1

    # ---- coordinates ----

    if usecoordinates
        verts = hcat(collect(vertices(p))[cyclic]...)'

        # project out all but 2 coordinates in such a way that the projection is 2-dimensional again:
        # the projection is 1-dimensional if the images of all vertices, in particular of the first three 
        # (a 2-face has at least 3 vertices), are collinear.

        # these two vectors are nonzero (and linearly independent) since they are differences of distinct vertices
        # (note here that a 2-face has at least 3 vertices)
        r12 = verts[1,:] - verts[2,:]
        r13 = verts[1,:] - verts[3,:]  # TODO normalize?

        i,j = proj_onto_indices(r12, r13)
        x, y = verts[:,i], verts[:,j]  # TODO convert to float?

        # use indices of projection coordinates as default axis labels
        subscript_unicode(n::Int) =
            n >= 0 ? join(['\u2080'+d for d in digits(n)]) : throw(ArgumentError("negative subscripts not allowed"))
        xguide --> "x" * subscript_unicode(i)
        yguide --> "x" * subscript_unicode(j)
    else
        angles = [2π*i/n + π/2 for i=0:(n-1)]  # start counting counter-clockwise from the top (π/2)
        x, y = cos.(angles), sin.(angles)
        
        # no axis labels by default
        xguide --> ""
        yguide --> ""
    end

    # set up plot

    size --> (300, 300)
    ticks --> nothing
    legend := false
    framestyle := :box

    # concatenate multiple inequality labels into a single string
    concatlabels(labels::AbstractVector{<:AbstractString}) = 
        join( unique_labels_only ? unique(labels) : labels, ' ' )
    title --> (ineqlabels !== nothing ? concatlabels(get.(Ref(ineqlabels), indices, "")) : "")

    # ---- calculate aspect ratio ----

    # default aspect ratio fills the entire plot area
    # from https://docs.juliaplots.org/latest/generated/attributes_subplot/
    # >> Plot area is resized so that 1 y-unit is the same size as `aspect_ratio` x-units.
    xrange = maximum(x) - minimum(x)
    yrange = maximum(y) - minimum(y)
    ratio = xrange / yrange * plotattributes[:size][2] / plotattributes[:size][1]
    
    # replace all symbolic values by numeric ratio
    # :equal is replaced by 1, :auto and :none by ratio of plot area
    if !haskey(plotattributes, :aspect_ratio)
        aspect_ratio := ratio #(usecoordinates ? ratio : 1)
    elseif !(plotattributes[:aspect_ratio] isa Real)  # assuming that valid argument types are Real and Symbol(?)
        if plotattributes[:aspect_ratio] == :equal
            aspect_ratio := 1
        else  # :auto, :none
            aspect_ratio := ratio
        end
    end
    
    # ---- plot series ----
    
    # polygon
    @series begin
        seriestype := :shape
        linewidth --> 2
        linecolor := linecolor
        fillcolor --> :lightsteelblue1
        fillalpha --> 0.5
        x, y
    end

    # vertex markers
    @series begin
        seriestype := :scatter
        markercolor --> linecolor
        markersize --> 5
        markerstrokewidth := 0
        x, y
    end

    # barycentre of face
    bx, by = sum(x)/length(x), sum(y)/length(y)

    # edge labels

    # compute the angle (in radians) of the edge between vertex i and its successor in the cyclic order
    # !!! this is the angle as plotted and not necessarily the true angle 
    #     since aspect ratio might be different from 1
    function edge_angle(i::Int, ratio::Real)
        @assert 1 <= i <= n
        j = succ(i)

        if isapprox(x[i], x[j])  # edge is (nearly) vertical
            # choose the unique rotation angle from ± π/2 so that text can be read normally
            # when rotating the polygon around to make the current edge the top (horizontal) edge,
            # i.e., the sign of the angle depends on whether the vertical edge is on the left or on the right
            α = sign(bx-x[i]) * π/2
        else
            # need to rescale x in accordance with aspect ratio 
            α = atan((y[j]-y[i]) / (x[j]-x[i]) * ratio)  # in radians
        end
        α
    end

    # compute outer normal vector of the edge between i and its successor in the cyclic order, i.e.,
    # a vector that, in the plot(!), is orthogonal to the drawn edge between i and its successor
    function outernormal(i::Int, ratio::Real)
        #α = edge_angle(i, ratio)
        #vec = [1, tan(α+π/2)]

        j = succ(i)
        # actual edge direction in plot is (see above)
        edgedir = [x[j]-x[i], (y[j]-y[i]) * ratio]
        #vec = [(y[j]-y[i]) * ratio, x[i]-x[j]]  # TODO without ratio, this vector is orthogonal to the true edge
        vec = [edgedir[2], -edgedir[1]]

        vec = vec ./ sqrt(sum(vec .^ 2))  # normalize by 2-norm
        # make orthogonal in plot
        vec[1] *= ratio  # TODO
        # normalize length relative to yrange
        vec = vec .* yrange / 16

        # `vec` is orthogonal but not necessarily an *outer* normal
        # to this end, take any point in the interior of the polygon, e.g., the barycentre
        # then the dot product of ... with any outer normal must be nonnegative
        if vec[1] * (x[i]-bx) / ratio^2 + vec[2] * (y[i]-by) < 0  # !!! rescale to get back true dot product
            # both first entries have been scaled by `ratio` each
            vec *= -1  # reverse direction to point in same direction as diff vector from barycentre
        end
        vec
    end

    # outer normals of edges
    normals = outernormal.(1:n, plotattributes[:aspect_ratio])

    if ineqlabels !== nothing
        # incident halfspaces of each edge
        tightfacets = [
            [f for f in _incidenthalfspaces(p, cyclic[[i, succ(i)]]) if !(f in indices)] 
            for i=1:n
        ]

        # angles of edges
        α = edge_angle.(1:n, plotattributes[:aspect_ratio])

        @series begin
            seriestype := :scatter
            markeralpha := 0  # only annotations
            # FIXME text() needs Plots dependency...?
            series_annotations := [text(
                concatlabels(get.(Ref(ineqlabels), tightfacets[i], "")), 
                8, :center, linecolor, rotation = α[i] * 180/π  # rotation angle is in degrees
            ) for i=1:n]

            labelx = [(x[i] + x[succ(i)])/2 + normals[i][1] for i=1:n]
            labely = [(y[i] + y[succ(i)])/2 + normals[i][2] for i=1:n]
            labelx, labely
        end

        # face label
        @series begin
            seriestype := :scatter
            markeralpha := 0
            series_annotations := [text(concatlabels(get.(Ref(ineqlabels), indices, "")), 10, :center, linecolor)]
            [bx], [by]
        end
    end

    # vertex labels
    if vertexlabels !== nothing
        @series begin
            seriestype := :scatter
            markeralpha := 0  # only annotations

            # if index/key not found, don't print a label
            series_annotations := [text(get(vertexlabels, cyclic[i], ""), 10, :center) for i=1:n]

            # offset vector = twice the mean of outer normals of both edges incident to i
            labelx = [x[i] + normals[i][1] + normals[pred(i)][1] for i=1:n]
            labely = [y[i] + normals[i][2] + normals[pred(i)][2] for i=1:n]
            labelx, labely
        end
    end

    # mark up edges
    if markup_edges !== nothing
        for k=1:2
            # get an edge-defining inequality for the other edge
            edgefacets = incidenthalfspaces(p, markup_edges[k==1 ? 2 : 1])
            ineq = findfirst(f -> !(f in indices), edgefacets)

            (u,v), uniquedir = directedge(p, markup_edges[k], edgefacets[ineq])
            # get the indices of the endpoints of the current edge as they appear in the cyclic order
            i,j = map(x -> findfirst(cyclic .== x), [u,v])
            
            @series begin
                linecolor := markup_linecolor
                linewidth := markup_linewidth
                arrow := uniquedir
                x[[i,j]], y[[i,j]] 
            end
        end
    end

    ()
end


# for compatibility with older versions
export plot2face
using Plots: plot
function plot2face(args...; kw...)
    @warn "`plot2face` is deprecated and has been replaced by `plot`"
    plot(args...; kw...)
end