using Documenter, DigiPopData

makedocs(
    sitename = "DigiPopData",
    authors = "Ivan Borisov, Evgeny Metelkin",
    modules = [DigiPopData],
    format = Documenter.HTML(),
    pages = [
        "Home" => "index.md",
        "API" => "api.md",
    ]
)

deploydocs(
    repo = "github.com/insysbio/DigiPopData.git",
    devbranch = "main"
)
