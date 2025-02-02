export readineq

using DelimitedFiles

function str2rat(str::AbstractString, ::Type{T}) where T<:Integer 
    Rational(reduce(//, parse.(T, split(str, '/'))))
end

"""
    readrational(filename, T)

`T` type of numerator and denominator

eltype(arr) == Rational{T}
"""
function readrational(filename::AbstractString, ::Type{T}) where T<:Integer
    arr = readdlm(filename, String)
    return str2rat.(arr, T)
end

"""
    readineq(filename, T)
"""
function readineq(filename::AbstractString, ::Type{T}) where T<:Integer
    arr = readdlm(filename, ' ', String, comments=true, comment_char='#')
    rowlabels = arr[:,1]
    
    b, A = str2rat.(arr[:,2], T), -str2rat.(arr[:,3:end], T)
    return A, b, rowlabels
end
