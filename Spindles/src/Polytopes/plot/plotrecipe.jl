# ================================
# User recipe for plotting 2-faces
# (see also https://docs.juliaplots.org/stable/recipes/)
# ================================

### TODO remove the following function in next versions
function plot2face(args...; kw...)
    @warn "`plot2face` is deprecated, use `plot` instead."
    Plots.plot(args...; kw...)
end


# return keyword dict with all attributes prefixed by `prefix`
# and their full attribute names (aliases don't work inside recipes)
function extract_prefix_kwargs(kwargs::Dict{Symbol, <:Any}, prefix::AbstractString, attrs)
    kw = Dict{Symbol, Any}()

    for (key, val) in kwargs
        if startswith(prefix)(string(key))
            newattr = Symbol(chopprefix(string(key), prefix))

            for attr in attrs
                # the list returned by aliases does not include the attribute itself, 
                # so we need to check it separately
                # (note that for custom attributes not from Plots.jl, this list will be empty)
                if newattr == attr || newattr in Plots.aliases(attr)
                    kw[attr] = val
                end
            end
        end
    end
    kw
end

# type annotations on kwargs not supported in recipes
@recipe function f(p::Polytope, indices::AbstractVector{<:Integer};
    # custom keyword arguments:
    usecoordinates=true,
    vertexlabels=string.(1:nvertices(p)),
    ineqlabels=string.(1:nhalfspaces(p)),
    unique_labels_only=true,
    markup_edges=nothing,
    linecolor=:steelblue,  # aliases like `lc` still work(?) # TODO
)
    # TODO check arguments: ignore invalid values
    if !(usecoordinates isa Bool)
        usecoordinates = true
    end

    if markup_edges !== nothing && !isempty(markup_edges)  # [] or () is treated as nothing
        if length(markup_edges) !== 2
            error("got $(length(markup_edges)) elements, expected 2")
        end

        isedge(e) = try length(e) == 2 && Graphs.has_edge(graph(p), e...) catch; false end
        i = findfirst(!isedge, markup_edges)
        if i !== nothing
            error("not an edge: $(markup_edges[i])")
        end
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
        # matrix with one row for each vertex of the face
        verts = hcat(collect(vertices(p))[cyclic]...)'

        # project out all but 2 coordinates in such a way that the projection is 2-dimensional again:
        # the projection is 1-dimensional if the images of all vertices, in particular of the first three 
        # (a 2-face has at least 3 vertices), are collinear.

        # these two vectors are nonzero (and linearly independent) since they are differences of distinct vertices
        # (note here that a 2-face has at least 3 vertices)
        i, j = proj_onto_indices(verts[1,:] - verts[2,:], verts[1,:] - verts[3,:])
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
    # wrap `ineqlabels` in Ref() to enable broadcasting over collection of dict keys
    title --> (ineqlabels !== nothing ? concatlabels(get.(Ref(ineqlabels), indices, "")) : "")

    # ---- set aspect ratio ----

    xrange = maximum(x) - minimum(x)
    yrange = maximum(y) - minimum(y)
    # default aspect ratio: fill the entire plot area
    ratio = xrange / yrange * plotattributes[:size][2] / plotattributes[:size][1]
    
    # replace all symbolic values by numeric ratio
    # :equal is replaced by 1, :auto and :none by ratio of plot area
    if !haskey(plotattributes, :aspect_ratio)
        aspect_ratio := ratio
    elseif !(plotattributes[:aspect_ratio] isa Real)  # assuming that valid argument types are Real and Symbol(?)
        if plotattributes[:aspect_ratio] == :equal
            aspect_ratio := 1
        else  # :auto, :none
            aspect_ratio := ratio
            @warn "Skipped non-numeric value for aspect ratio: $(plotattributes[:aspect_ratio])"
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

    # mark up edges
    if markup_edges !== nothing
        # series attributes with their default values
        markup_attrs = Dict(
            :linealpha => nothing,
            :linecolor => :darkorange2,
            :linestyle => :solid,
            :linewidth => 3,
            :headsize => 20,
            :headpos  => 1,
            :headshape => 0.7,
        )
        # extract and "de-alias" custom attributes prefixed with "markup_"
        markup_kwargs = extract_prefix_kwargs(plotattributes, "markup_", keys(markup_attrs))

        for k=1:2
            # get an edge-defining inequality for the other edge
            edgefacets = incidenthalfspaces(p, collect(markup_edges[(k==1)+1]))  # need `collect` for tuples
            ineq = findfirst(f -> !(f in indices), edgefacets)

            (u,v), uniquedir = directedge(p, markup_edges[k], edgefacets[ineq])
            # get the indices of the endpoints of the current edge as they appear in the cyclic order
            i,j = map(x -> findfirst(cyclic .== x), [u,v])
            
            @series begin
                if uniquedir  # draw arrow only if non-parallel edges
                    seriestype := :arrow
                end
                # set series attributes
                for (attr, val) in markup_attrs
                    plotattributes[attr] = get(markup_kwargs, attr, val)
                end
                x[[i,j]], y[[i,j]]
            end
        end
    end
    
    # edge labels

    # barycentre of face
    bx, by = sum(x)/length(x), sum(y)/length(y)

    # compute angle of drawn edge between i and j (i.e., angle as shown on the canvas)
    function edge_angle(i::Int)
        j = succ(i)
        α = angle(x[j]-x[i], y[j]-y[i], plotattributes[:aspect_ratio])
        
        if isapprox(abs(α), π/2)  # (near-)vertical edge
            # choose the unique rotation angle from ± π/2 so that text can be read normally
            # when rotating the polygon around to make the current edge the top (horizontal) edge,
            # i.e., the sign of the angle depends on whether the vertical edge is on the left or on the right
            α = sign(bx - x[i]) * π/2
        end
        α
    end

    # compute outer normal vector of the drawn edge between i and its successor in the cyclic order, i.e.,
    # a vector that, on the plot canvas, is orthogonal to the drawn edge between i and its successor
    # and "points outwards"
    function outernormal(i::Int; scale::Real=yrange/16)
        j = succ(i)
        vec = orthogonal_vector(x[j]-x[i], y[j]-y[i], plotattributes[:aspect_ratio])
        
        # this vector is orthogonal but not necessarily an *outer* normal of the edge between i and j.
        # to make it one, take any point in the interior of the polygon, e.g., the barycentre,
        # then the dot product of ... with any outer normal must be nonnegative
        # (dot product on the canvas, i.e., need to apply the transformation to both vectors first)
        if vec[1] * (x[i]-bx) / ratio^2 + vec[2] * (y[i]-by) < 0
            vec *= -1
        end
        
        # possibly rescale vector
        vec .* scale
    end
    normals = outernormal.(1:n)

    if ineqlabels !== nothing
        # incident halfspaces of each edge
        tightfacets = [
            [f for f in _incidenthalfspaces(p, cyclic[[i, succ(i)]]) if !(f in indices)] 
            for i=1:n
        ]

        @series begin
            seriestype := :scatter
            markeralpha := 0  # no markers, only annotations
            # FIXME text() requires Plots
            series_annotations := [Plots.text(
                concatlabels(get.(Ref(ineqlabels), tightfacets[i], "")), 
                8, :center, linecolor, rotation = edge_angle(i) * 180/π  # rotation angle is in degrees
            ) for i=1:n]

            labelx = [(x[i] + x[succ(i)])/2 + normals[i][1] for i=1:n]
            labely = [(y[i] + y[succ(i)])/2 + normals[i][2] for i=1:n]
            labelx, labely
        end

        # face label
        @series begin
            seriestype := :scatter
            markeralpha := 0
            series_annotations := [(concatlabels(get.(Ref(ineqlabels), indices, "")), 10, :center, linecolor)]
            [bx], [by]
        end
    end

    # vertex labels
    if vertexlabels !== nothing
        @series begin
            seriestype := :scatter
            markeralpha := 0  # no markers, only annotations

            # if index/key not found, don't print a label
            series_annotations := [(get(vertexlabels, cyclic[i], ""), 10, :center) for i=1:n]

            # offset vector = twice the mean of outer normals of both edges incident to i
            labelx = [x[i] + normals[i][1] + normals[pred(i)][1] for i=1:n]
            labely = [y[i] + normals[i][2] + normals[pred(i)][2] for i=1:n]
            labelx, labely
        end
    end

    ()
end
