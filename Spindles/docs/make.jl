joinpath("..", "src") in LOAD_PATH || push!(LOAD_PATH, joinpath("..", "src"))

using Documenter, Spindles

makedocs(
    sitename = "Spindles.jl",
    #doctest=:only,
    pages = [
        "Home" => "index.md",
        "Manual" => [
            "Enumerating faces" => "faceenum.md",
            "Plotting faces" => "plots.md",
            "File I/O" => "io.md",
        ]
    ]
)
