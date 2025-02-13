using Documenter, Literate
using Spindles
using Polyhedra, Graphs  # TODO

# generate example files using Literate.jl
const EXAMPLES = [
    ("firststeps", "First steps"),
    ("hirsch", "Spindles and the Hirsch conjecture I"),
    #("hirsch2", "Spindles and the Hirsch conjecture II"),
]
EXAMPLE_DIR = joinpath(@__DIR__, "..", "examples")
OUTPUT_DIR = joinpath(@__DIR__, "src", "tutorials")

# replace all input file paths that appear as strings (starting with " ) in function calls 
function replace_paths(content)
    input_files = [filename for filename in readdir(EXAMPLE_DIR) if splitext(filename)[2] == ".txt"]
    content = replace(content, [
        '\"' * filename => '\"' * replace(joinpath("..", "..", "..", "examples", filename), "\\" => "\\\\") 
        for filename in input_files
    ]...)
    return content
end

for (example, name) in EXAMPLES
    Literate.markdown(
        joinpath(EXAMPLE_DIR, example * ".jl"), OUTPUT_DIR; 
        preprocess = replace_paths #∘ replace_nbviewer_url
    )
    Literate.notebook(
        joinpath(EXAMPLE_DIR, example * ".jl"), EXAMPLE_DIR; 
        name=name, execute=true,
        #preprocess = replace_nbviewer_url
    )
end

# See https://documenter.juliadocs.org/stable/man/doctests/#Setup-Code
# https://stackoverflow.com/questions/57461225/jldoctest-blocks-in-julia-docstrings-included-in-documentation-but-tests-not-run
DocMeta.setdocmeta!(Spindles, :DocTestSetup, :(using Spindles); recursive=true)

makedocs(
    modules = [Spindles],
    sitename = "Spindles.jl",
    doctest = true,
    format=Documenter.HTML(;
        #prettyurls=get(ENV, "CI", "false") == "true",
        #assets=String[],
        collapselevel=1,
        #canonical="https://ma-b.github.io/hirsch-walks",
    ),
    pages = [
        "Home" => "index.md",
        "Tutorials" => [
            name => "tutorials/$(example).md"
            for (example, name) in EXAMPLES
        ],
        "API Reference" => [
            "Index" => "man/api.md",
            "Representation" => "man/representation.md",
            "Faces" => "man/faces.md",
            "Plots" => "man/plots.md",
            "File I/O" => "man/io.md",
        ],
    ]
)

deploydocs(
    repo = "github.com/ma-b/hirsch-walks.git",
    devbranch = "main",
)
