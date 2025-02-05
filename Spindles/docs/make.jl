joinpath("..", "src") in LOAD_PATH || push!(LOAD_PATH, joinpath("..", "src"))

using Documenter, Spindles

# https://documenter.juliadocs.org/stable/man/doctests/#Module-level-metadata
# https://stackoverflow.com/questions/57461225/jldoctest-blocks-in-julia-docstrings-included-in-documentation-but-tests-not-run
DocMeta.setdocmeta!(Spindles, :DocTestSetup, :(using Spindles); recursive=true)

makedocs(
    sitename = "Spindles.jl",
    doctest = true, #:only, #false,  # :only for debugging doctests
    modules = [Spindles],
    pages = [
        "Home" => "index.md",
        "Tutorials" => [
            "tutorials/first-steps.md",
            "tutorials/spindles-and-the-hirsch-conjecture.md",
        ],
        "API reference" => [
            "Enumerating faces" => "faceenum.md",
            "Plotting faces" => "plots.md",
            "File I/O" => "io.md",
        ],
    ]
)
