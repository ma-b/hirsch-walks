push!(LOAD_PATH, joinpath("..", "src"))
#joinpath("..", "src") in LOAD_PATH || push!(LOAD_PATH, joinpath("..", "src"))

using Documenter #, DocumenterInterLinks
using Spindles
using Polyhedra

# https://documenter.juliadocs.org/stable/man/doctests/#Module-level-metadata
# https://stackoverflow.com/questions/57461225/jldoctest-blocks-in-julia-docstrings-included-in-documentation-but-tests-not-run
DocMeta.setdocmeta!(Spindles, :DocTestSetup, :(using Spindles); recursive=true)

#=
# https://documenter.juliadocs.org/stable/man/guide/#External-Cross-References
links = InterLinks(
    "Graphs" => "https://juliagraphs.org/Graphs.jl/dev/objects.inv"
)=#

makedocs(
    modules = [Spindles],
    sitename = "Spindles.jl",
    doctest = false, #:only, #false,  # :only for debugging doctests
    format=Documenter.HTML(;
        #prettyurls=get(ENV, "CI", "false") == "true",
        #assets=String[],
        collapselevel=1,
        #canonical="https://ma-b.github.io/hirsch-walks",
    ),
    pages = [
        "Home" => "index.md",
        "Tutorials" => [
            "tutorials/firststeps.md",
            "tutorials/hirsch.md",
        ],
        "API Reference" => [
            "Representation" => "man/representation.md",
            "Faces" => "man/faces.md",
            "Plots" => "man/plots.md",
            "File I/O" => "man/io.md",
        ],
    ]
)
