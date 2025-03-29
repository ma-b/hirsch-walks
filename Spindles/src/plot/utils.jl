# ================================
# Utility functions for plots
# ================================

TOL = 1e-16  # FIXME

# return cyclic indices u,v (arrow from u to v) together with Boolean flag that indicates 
# whether the direction is unique (False if edge and reference_edge are parallel)
function directedge(p::Polytope, edge::Union{Tuple{Int, Int}, AbstractVector{Int}}, facet::Int)
    u, v = edge  # TODO arg check

    # direction from u to v
    verts = collect(vertices(p))[[u,v]]
    r = verts[2] - verts[1]
    # index of first nonzero entry (exists since u and v are distinct)
    i = findfirst(@. !isapprox(r, 0; atol=TOL))
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
function proj_onto_indices(x::AbstractVector{<:Real}, y::AbstractVector{<:Real})
    # implementation strategy: use Gaussian elimination

    # TODO assert nonzero

    # find first nonzero component (must exist since x is nonzero)
    i = findfirst(@. !isapprox(x, 0; atol=TOL))
    #i !== nothing || # TODO what to return for type stability?

    # perform a single Gauss step to eliminate component i of y
    # (note that the choice of i ensures that we do not divide by zero here)
    y_elim = y - x * y[i] / x[i]
    
    # find the first nonzero component of the resulting vector
    # note that entry i must be zero by construction
    @assert isapprox(y_elim[i], 0; atol=TOL)
    j = findfirst(@. !isapprox(y_elim, 0; atol=TOL))
    # such a j must exist since x and y are linearly independent
    # now the 2x2 matrix induced by components i and j of x and y_elim is of the form [* *; 0 *] and has rank 2,
    # so projecting out all but i,j leaves projections of x and y_elim (and therefore y) linearly independent.
    i,j
end


# --------------------------------
# transformations between true geometry and plot canvas
#
# From https://docs.juliaplots.org/latest/generated/attributes_subplot/:
# >> Plot area is resized so that 1 y-unit is the same size as `aspect_ratio` x-units.
#
# The transformation from a true vector to its drawn counterpart on the canvas is therefore given by
# (x, y) -> (x / ratio, y)
# --------------------------------

# Compute the angle (in radians) between the vector (x,y) and (1,0) as seen in the final plot
# (i.e., respecting the aspect ratio)
function angle(x::Real, y::Real, ratio::Real)
    # need to apply the canvas transformation first to rescale the vector in accordance with aspect ratio
    atan(y / x * ratio)  # in radians
    # TODO assuming abs(atan(±Inf)) = π/2 (when x=0)
end

# Compute a vector that is orthogonal to the vector (x,y) when plotting both on a canvas with given aspect ratio,
# and unit vector w.r.t. 2-norm (TODO wrt y-units?)
function orthogonal_vector(x::Real, y::Real, ratio::Real)
    # on the plot canvas, the following vector is orthogonal to the direction of the plotted line segment
    orth = [y * ratio, -x]
    orth = orth ./ sqrt(sum(orth .^ 2))  # normalize by 2-norm
    
    # to obtain this vector after plotting, we need to apply the inverse transformation
    orth[1] *= ratio
    orth
end


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