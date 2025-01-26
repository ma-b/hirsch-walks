using DelimitedFiles

# T type of numerator and denominator
function readrational(filename::AbstractString, ::Type{T}) where T<:Integer
    arr = readdlm(filename, String)
    str2rat(str) = Rational(reduce(//, parse.(T, split(str, '/'))))
    return map(str2rat, arr)
end
