using Documenter, Literate
using Spindles
using Polyhedra, Graphs  # TODO

# generate example files using Literate.jl
const EXAMPLES = [
    ("firststeps", "First steps"),
    ("hirsch", "Spindles and the Hirsch conjecture I"),
    ("hirsch2", "Spindles and the Hirsch conjecture II")
]
EXAMPLEDIR = joinpath(@__DIR__, "..", "examples")
OUTPUTDIR = joinpath(@__DIR__, "src", "tutorials")

for (example, name) in EXAMPLES
    Literate.markdown(joinpath(EXAMPLEDIR, example * ".jl"), OUTPUTDIR; preprocess=replace_path_md)
    #Literate.notebook(joinpath(EXAMPLEDIR, example * ".jl"), EXAMPLEDIR; name=name, preprocess=replace_path_nb)
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
