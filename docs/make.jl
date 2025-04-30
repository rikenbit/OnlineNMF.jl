using Documenter
using OnlineNMF

makedocs(
    sitename = "OnlineNMF.jl",
    modules = [OnlineNMF],
    format = Documenter.HTML(prettyurls = true),
    pages = [
        "Home" => "index.md",
        "Julia API" => "juliaapi.md",
        "Command line Tool" => "commandline.md"
    ])

deploydocs(
    repo = "github.com/rikenbit/OnlineNMF.jl.git",
    devbranch = "master",
    target = "build",
    deps = nothing,
    make = nothing)