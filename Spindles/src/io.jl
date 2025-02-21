export readineq

using DelimitedFiles

function str2rat(str::AbstractString, ::Type{T}) where T<:Integer 
    Rational(reduce(//, parse.(T, split(str, '/'))))
end
function rat2str(x::Rational)
    x.den == 1 ? string(numerator(x)) : @sprintf("%d/%d", numerator(x), denominator(x))
end

"""
    readrational(filename, T)

`T` type of numerator and denominator
"""
function readrational(filename::AbstractString, ::Type{T}) where T<:Integer
    arr = readdlm(filename, String)
    return str2rat.(arr, T)
end

"""
    readineq(filename, T [, comment_char])

File format: `labels b -A`
Return `A, b, labels` where `A` is a matrix of type `Rational{T}`.

Lines starting with a `comment_char` character (default is `'#'`) and all characters on a line following 
a `comment_char` are ignored.

# Examples
```jldoctest
julia> str = "# unit square\\na 1 -1 0\\nb 1 0 -1\\nc 1 1 0\\nd 1 0 1";

julia> println(str)
# unit square
a 1 -1 0
b 1 0 -1
c 1 1 0
d 1 0 1

julia> open("square.txt", "w") do io
           write(io, str)
       end;

julia> A, b, labels = readineq("square.txt", Int);

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

julia> rm("square.txt")
```
"""
function readineq(filename::AbstractString, ::Type{T}; comment_char::AbstractChar='#', labels::Bool=true) where T<:Integer
    arr = readdlm(filename, ' ', String, comments=true, comment_char=comment_char)
    
    labs = labels ? arr[:, 1] : nothing    
    b, A = str2rat.(arr[:, labels ? 2 : 1], T), -str2rat.(arr[:, (labels ? 3 : 2):end], T)
    return A, b, labs
end


"""
    writeineq(outfilename, A::AbstractMatrix, b::AbstractVector [, labels, labels_plusminus, comments, comment_char])

Write the inequality description ``Ax \\le b`` to `outfilename`.

The file format is `[labels b -A]`. First column contains inequality labels.

# Keywords
* `labels`: If not specified, use inequality indices.
* `labels_plusminus::Bool`: Defaults to `false`
* `comments`: Each element in `comments` will be printed on its own line, starting with `comment_char` 
  and a whitespace. Possible internal line breaks are ignored.
* `comment_char`: default is `'#'`
"""
function writeineq(outfilename::AbstractString, A::AbstractMatrix, b::AbstractVector;
    labels::Union{Nothing, Vector{<:AbstractString}}=nothing, labels_plusminus::Bool=false,
    comments::Vector{<:AbstractString}=AbstractString[], comment_char::AbstractChar='#')
    
    size(A,1) == length(b) || throw(DimensionMismatch("...")) # TODO
    
    if labels === nothing
        if labels_plusminus && iseven(size(A,1))
            # TODO warning if plusminus is set and odd number of rows
            labels = vcat([[string(Int(i))*"⁺", string(Int(i))*"⁻"] for i=1:size(A,1)//2]...)
        else
            labels = string.(1:size(A,1))
        end
    else
        length(labels) == size(A,1) || throw(DimensionMismatch("got $(length(rowlabels)) labels for $(size(A,1)) rows"))
    end    

    arr = [labels rat2str.([b -A])]

    # write comment lines
    comments = map(x -> replace(x, r"\r|\n" => ""), comments)  # remove line breaks
    write(outfilename, join(["$(comment_char) $(c)\n" for c in comments]))
    
    # write matrix
    open(outfilename, "a") do io  # append to file
        writedlm(io, arr, ' ')
    end
end
