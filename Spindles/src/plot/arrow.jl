# ================================
# Series recipe for arrows
# ================================

# θ angle by which the tip "opens" on either side
# relative shape factor in [0,1]
# ! shape will be used as a marker shape and can therefore be independent of the aspect ratio
function arrowhead(rotation::Real; θ::Real=π/8, relshape::Real=0.75)
    relshape = max(min(relshape, 1), 0)  # truncate if necessary to fit between 0 and 1
    points = [  # cylic list of vertices of (not necessarily convex) polygon
        zeros(2) -unitvector(rotation+θ) -relshape*cos(θ) * unitvector(rotation) -unitvector(rotation-θ) zeros(2)
    ]
    Plots.Shape(points[1,:], points[2,:])
end

# series recipe
# last line segment gets an arrowhead
# arrow keyword in standard recipes has a bug and does not scale properly for many subplots
@recipe function f(::Type{Val{:arrow}}, x, y, z; headsize=25, headpos=1, headshape=0.8)
    if plotattributes[:subplot].attr[:aspect_ratio] isa Real
        ratio = plotattributes[:subplot].attr[:aspect_ratio]
    else
        @warn "non-numeric aspect ratio not supported by series type arrow"
        ratio = 1
    end

    # between -π/2 and π/2
    α = atan((y[end]-y[end-1]) / (x[end]-x[end-1]) * ratio)
    if x[end] < x[end-1]  # direction of last line segment is in left halfplane
        α -= π
    end

    λ = max(min(headpos, 1), 0)  # truncate if necessary to fit between 0 and 1
    # split last line segment into two parts, according to the multiplier headpos
    xy = [x y; x[end] y[end]]
    xy[end-1,:] = (1-λ) * xy[end-2,:] + λ * xy[end,:]  # interpolate

    # TODO :auto (not :none) seems to disable markers?
    markershapes = Vector{Union{Symbol, Plots.Shape}}(repeat([:auto], size(xy,1)))
    markershapes[end-1] = arrowhead(α; relshape=headshape)
    
    markershape := markershapes
    markersize := headsize
    
    markercolor       := plotattributes[:linecolor]
    markerstrokecolor := plotattributes[:linecolor]
    markeralpha       := plotattributes[:linealpha]
    markerstrokealpha := plotattributes[:linealpha]

    linewidth --> 1
    markerstrokewidth := plotattributes[:linewidth]    
    markerstrokestyle := :solid

    seriestype := :path
    x := xy[:,1]
    y := xy[:,2]
    ()
end