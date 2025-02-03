joinpath("..", "src") in LOAD_PATH || push!(LOAD_PATH, joinpath("..", "src"))

using Documenter, Spindles

makedocs(
    sitename = "Spindles.jl",
    #doctest=false,
    #modules = [Spindles],  # https://stackoverflow.com/questions/57461225/jldoctest-blocks-in-julia-docstrings-included-in-documentation-but-tests-not-run
    pages = [
        "Home" => "index.md",
        "Tutorial" => "tutorial.md",
        "API reference" => [
            "Enumerating faces" => "faceenum.md",
            "Plotting faces" => "plots.md",
            "File I/O" => "io.md",
        ],
    ]
)
