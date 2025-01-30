export readrational

using DelimitedFiles

"""
    readrational(filename, T)

`T` type of numerator and denominator

eltype(arr) == Rational{T}
"""
function readrational(filename::AbstractString, ::Type{T}) where T<:Integer
    arr = readdlm(filename, String)
    str2rat(str) = Rational(reduce(//, parse.(T, split(str, '/'))))
    return map(str2rat, arr)
end
