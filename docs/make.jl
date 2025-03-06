using Documenter
using OnlineNMF

makedocs()

makedocs(
    format = :html,
    sitename = "OnlineNMF.jl",
    modules = [OnlineNMF],
    pages = [
        "Home" => "index.md",
        "Julia API" => "juliaapi.md",
        "Command line Tool" => "commandline.md"
    ])

deploydocs(
    repo = "github.com/rikenbit/OnlineNMF.jl.git",
    julia = "0.99",
    target = "build",
    deps = nothing,
    make = nothing)