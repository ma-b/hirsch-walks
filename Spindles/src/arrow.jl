# compute a unit vector (with respect to the 2-norm)
# such that its angle (in radians) with the first standard basis vector (1,0) is α
function unitvector(α::Real)
    # shift angle in the range between -π and π
    while α < -π
        α += 2π
    end
    while α > π
        α -= 2π
    end

    if isapprox(abs(α), π/2)
        return [0, sign(α)]
    else
        # tan is π-periodic, so to distinguish a vector and its negative, we first need to
        # check whether the desired vector is contained in the halfplane x >= 0 or x < 0
        s = abs(α) <= π/2 ? 1 : -1
        vec = s * [1, tan(α)]
        return vec / sqrt(sum(vec .^ 2))  # normalize
    end
end

# θ angle by which the tip "opens" on either side
# relative shape factor in [0,1]
# ! shape will be used as a marker shape and therefore can be independent of the aspect ratio
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
@recipe function f(::Type{Val{:arrow}}, x, y, z; headsize=20, headpos=1, headshape=0.8)
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

    linewidth --> 1
    markerstrokewidth := plotattributes[:linewidth]
    markercolor       := plotattributes[:linecolor]
    markerstrokecolor := plotattributes[:markercolor]

    seriestype := :path
    x := xy[:,1]
    y := xy[:,2]
    ()
end