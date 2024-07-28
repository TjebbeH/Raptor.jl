using Documenter, Raptor

makedocs(
    sitename="Raptor.jl",
    format = Documenter.HTML(; prettyurls = get(ENV, "CI", nothing) == "true"),
    pages = [
        "Home" => "index.md",
        "Parse GTFS data" => "gtfs.md"
    ]
)

deploydocs(
    repo = "github.com/TjebbeH/Raptor.jl.git",
)