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

File format: labels b -A
Return `A, b, labels` where `A` is a matrix of type `Rational{T}`.

Lines starting with a `#` character and all characters on a line following `#` are ignored.

# Examples
```jldoctest
julia> str = "# unit square\na 1 -1 0\nb 1 0 -1\nc 1 1 0\nd 1 0 1";

julia> println(str)
# unit square
a 1 -1 0
b 1 0 -1
c 1 1 0
d 1 0 1

julia> open("ineq.txt", "w") do io
           write(io, str)
       end;

julia> A, b, labels = readineq("ineq.txt", Int);

julia> A
4×2 Matrix{Rational{Int64}}:
  1   0
  0   1
 -1   0
  0  -1

julia> b
4-element Vector{Rational{Int64}}:
 1
 1
 1
 1

julia> labels
4-element Vector{String}:
 "a"
 "b"
 "c"
 "d"

julia> rm("ineq.txt")
```
"""
function readineq(filename::AbstractString, ::Type{T}) where T<:Integer
    arr = readdlm(filename, ' ', String, comments=true, comment_char='#')
    rowlabels = arr[:,1]
    
    b, A = str2rat.(arr[:,2], T), -str2rat.(arr[:,3:end], T)
    return A, b, rowlabels
end
