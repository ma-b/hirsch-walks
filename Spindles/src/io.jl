using DelimitedFiles

export readineq, writeineq

# convert the string "1/3" to the rational 1//3
str2rat(str::AbstractString, ::Type{T}) where T<:Integer =
    Rational(reduce(//, parse.(T, split(str, '/'))))

# conversely, print rationals in custom format, e.g., 1//3 as "1/3" and 7//1 as "7"
rat2str(x::Rational) =
    denominator(x) == 1 ? string(numerator(x)) : "$(numerator(x))/$(denominator(x))"

# stringify a numeric matrix in custom format (with single slash) for rationals
function matrix2str(A::AbstractMatrix{<:Real})
    map(A) do x
        x isa Rational ? rat2str(x) : string(x)
    end
end

# read a rational matrix in custom format above, use type T for numerators and denominators
function readrational(filename::AbstractString, ::Type{T}) where T<:Integer
    arr = readdlm(filename, String)
    return str2rat.(arr, T)
end

"""
    readineq(fname, T; labels=true, comment_char='#'])

Read `A, b, labels` from file `fname`. The element type of `A` and `b` is `Rational{T}`.

Lines starting with a `comment_char` character and all characters on a line following 
a `comment_char` are ignored.

See also [`writeineq`](@ref).

# Keywords
* `labels`:
* `comment_char`: 
"""
function readineq(fname::AbstractString, ::Type{T}; 
                  labels::Bool=true, comment_char::AbstractChar='#') where T<:Integer
    arr = readdlm(fname, String, comments=true, comment_char=comment_char)
    
    if size(arr,2) < Int(labels) + 2
        throw(ArgumentError("too few columns: need at least $(Int(labels)+2)"))
    end

    firstcol = Int(labels) + 1
    rowlabels = labels ? arr[:,1] : nothing
    b, A = str2rat.(arr[:,firstcol], T), -str2rat.(arr[:,(firstcol+1):end], T)

    return A, b, rowlabels
end


# pad each entry with whitespaces to the left such that the length of the resulting string equals
# the maximum length of any entry in the same column
function alignright!(A::AbstractMatrix{<:AbstractString})
    colwidths = maximum(length, A; dims=1)
    for j=1:size(A,2)
        A[:,j] = lpad.(A[:,j], colwidths[j])
    end
    A
end

"""
    writeineq(fname, A::AbstractMatrix, b::AbstractVector [, rowlabels];
        labels=true, comments=[], comment_char='#'
    )

Write the coefficient matrix `A` and the vector of right-hand sides `b` of
a system of linear inequalities to the file `fname`.

The file format is `[rowlabels b -A]` where `rowlabels` is a vector of strings,
or just `[b -A]` (without a label column) if `labels` is `false`.

If no `rowlabels` are specified and `labels` is `true`, use the row indices as default labels.

See also [`readineq`](@ref).

# Keywords

* `labels`: If `true` (default), print a first column with row labels as given by the argument `rowlabels`.
  If no `rowlabels` are provided, each row is labeled by its index (ranging from 1 to the number of rows of `A`).
* `comments`: A vector of strings. 
  Each element in `comments` will be printed on its own line, following a `comment_char` 
  and a whitespace. Possible internal line breaks are ignored. The data `A` and `b` is 
  printed below the last line of comments.
* `comment_char`: An `AbstractChar` that indicates the start of a comment line (default is `'#'`).

# Examples

````jldoctest
julia> A = [1 0; 0 1; -1 0; 0 -1];

julia> b = [1, 1, 1, 1];

julia> labels = ["α", "β", "γ", "δ"];

julia> writeineq("ineq.txt", A, b, labels; comments=["A nice polytope"])

julia> print(read("ineq.txt", String))
# A nice polytope
α  1  -1   0
β  1   0  -1
γ  1   1   0
δ  1   0   1

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
 "α"
 "β"
 "γ"
 "δ"

julia> rm("ineq.txt")
````
"""
function writeineq(fname::AbstractString, A::AbstractMatrix, b::AbstractVector,
    labels::Vector{<:AbstractString};  # row labels
    comments::Vector{<:AbstractString} = AbstractString[], 
    comment_char::AbstractChar='#'
)
    size(A,1) == length(b) || throw(DimensionMismatch("matrix A has dimensions $(size(A)), right-hand side vector b has length $(length(b))"))
    length(labels) == size(A,1) || throw(DimensionMismatch("got $(length(rowlabels)) labels for $(size(A,1)) rows"))  

    arr = [labels matrix2str([b -A])]
    alignright!(arr)  # align columns by padding entries with whitespaces

    # write comment lines
    comments = map(x -> replace(x, r"\r|\n" => ""), comments)  # remove line breaks
    write(fname, join(["$(comment_char) $(c)\n" for c in comments]))
    
    # write matrix
    open(fname, "a") do io  # append to file
        rows = join.(eachrow(arr), "  ")
        write(io, join(rows, "\n"))
    end
    nothing
end

function writeineq(fname::AbstractString, A::AbstractMatrix, b::AbstractVector;
    labels::Bool=true,
    comments::Vector{<:AbstractString} = AbstractString[], 
    comment_char::AbstractChar='#'
)
    if labels
        rowlabels = string.(1:size(A,1))
    else
        rowlabels = ["" for i=1:size(A,1)]
    end
    writeineq(fname, A, b, rowlabels; comments=comments, comment_char=comment_char)
end
