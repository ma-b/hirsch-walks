export readineq

using DelimitedFiles

function str2rat(str::AbstractString, ::Type{T}) where T<:Integer 
    Rational(reduce(//, parse.(T, split(str, '/'))))
end
function rat2str(x::Rational)
    x.den == 1 ? string(x.num) : @sprintf("%d/%d", x.num, x.den)
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
function readineq(filename::AbstractString, ::Type{T}; comment_char::AbstractChar='#') where T<:Integer
    arr = readdlm(filename, ' ', String, comments=true, comment_char=comment_char)
    labels = arr[:,1]
    
    b, A = str2rat.(arr[:,2], T), -str2rat.(arr[:,3:end], T)
    return A, b, labels
end


"""
    writeineq(filename, outfilename [, plusminus])

Create file with inequality description in the form [b -A]. First column contains row/facet labels.

Write to `outfilename`.
"""
function writeineq(outfilename::AbstractString, A::Matrix, b::Vector;
    labels::Union{Nothing, Vector{<:AbstractString}}=nothing, labels_plusminus::Bool=false,
    comments::Vector{<:AbstractString}=AbstractString[], comment_char::AbstractChar='#')
    
    size(A,1) == length(b) || throw(DimensionMismatch("...")) # TODO
    
    if labels === nothing
        if labels_plusminus && iseven(size(A,1))
            # TODO warning if plusminus is set and odd number of rows
            labels = vcat([[string(Int(i))*"+", string(Int(i))*"-"] for i=1:size(A,1)//2]...)
        else
            labels = string.(1:size(A,1))
        end
    else
        length(labels) == size(A,1) || throw(DimensionMismatch("got $(length(rowlabels)) labels for $(size(A,1)) rows"))
    end    

    arr = [labels rat2str.([b -A])]

    # write comment lines
    # TODO remove '\n'
    write(outfilename, join([@sprintf("%s %s\n", comment_char, c) for c in comments]))
    
    # write matrix
    open(outfilename, "a") do io  # append to file
        writedlm(io, arr, ' ')
    end
end
