using Documenter, Raptor

makedocs(;
    sitename="Raptor.jl",
    format=Documenter.HTML(; ansicolor = true, prettyurls=get(ENV, "CI", nothing) == "true"),
    pages=[
        "Home" => "index.md",
        "Getting started" =>
            ["Create Timetable" => "timetable.md", "Run McRaptor" => "mcraptor.md"],
        "Toy example" => "toy_example.md",
    ],
)

deploydocs(; repo="github.com/TjebbeH/Raptor.jl.git", push_preview=true)
