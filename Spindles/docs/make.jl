push!(LOAD_PATH, joinpath("..", "src"))
#joinpath("..", "src") in LOAD_PATH || push!(LOAD_PATH, joinpath("..", "src"))

using Documenter, Spindles

# https://documenter.juliadocs.org/stable/man/doctests/#Module-level-metadata
# https://stackoverflow.com/questions/57461225/jldoctest-blocks-in-julia-docstrings-included-in-documentation-but-tests-not-run
DocMeta.setdocmeta!(Spindles, :DocTestSetup, :(using Spindles); recursive=true)

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
            "tutorials/first-steps.md",
            "tutorials/spindles-and-the-hirsch-conjecture.md",
        ],
        "API Reference" => [
            "Enumerating faces" => "man/faceenum.md",
            "Plotting faces" => "man/plots.md",
            "File I/O" => "man/io.md",
        ],
    ]
)
