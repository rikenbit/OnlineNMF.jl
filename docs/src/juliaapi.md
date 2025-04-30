# OnlineNMF.jl (Julia API)

## Non-negative Matrix Factorization (NMF)
```@docs
nmf(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, alpha::Number=1, beta::Number=2, graphv::Number=0, l1u::Number=eps(Float32), l1v::Number=eps(Float32), l2u::Number=eps(Float32), l2v::Number=eps(Float32), dim::Number=3, numepoch::Number=5, chunksize::Number=1, algorithm::AbstractString="frobenius", lower::Number=0, upper::Number=1.0f+38, initU::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, initL::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing)
```

## Discretized Non-negative Matrix Factorization (DNMF)
```@docs
dnmf(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, beta::Number=2, binu::Number=eps(Float32), binv::Number=eps(Float32), teru::Number=eps(Float32), terv::Number=eps(Float32), graphv::Number=0, l1u::Number=eps(Float32), l1v::Number=eps(Float32), l2u::Number=eps(Float32), l2v::Number=eps(Float32), dim::Number=3, numepoch::Number=5, chunksize::Number=1, lower::Number=0, upper::Number=1.0f+38, initU::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, initL::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing)
```

## Sparse Non-negative Matrix Factorization (SNMF)
```@docs
sparse_nmf(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, alpha::Number=1, beta::Number=2, graphv::Number=0, l1u::Number=eps(Float32), l1v::Number=eps(Float32), l2u::Number=eps(Float32), l2v::Number=eps(Float32), dim::Number=3, numepoch::Number=5, chunksize::Number=1, algorithm::AbstractString="frobenius", lower::Number=0, upper::Number=1.0f+38, initU::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, initL::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing)
```

## Sparse Discretized Non-negative Matrix Factorization (SDNMF)
```@docs
sparse_dnmf(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, beta::Number=2, binu::Number=eps(Float32), binv::Number=eps(Float32), teru::Number=eps(Float32), terv::Number=eps(Float32), graphv::Number=0, l1u::Number=eps(Float32), l1v::Number=eps(Float32), l2u::Number=eps(Float32), l2v::Number=eps(Float32), dim::Number=3, numepoch::Number=5, chunksize::Number=1, lower::Number=0, upper::Number=1.0f+38, initU::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, initL::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing)
```

## BinCOO Non-negative Matrix Factorization (BinCOONMF)
```@docs
bincoo_nmf(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, alpha::Number=1, beta::Number=2, graphv::Number=0, l1u::Number=eps(Float32), l1v::Number=eps(Float32), l2u::Number=eps(Float32), l2v::Number=eps(Float32), dim::Number=3, numepoch::Number=5, chunksize::Number=1, algorithm::AbstractString="frobenius", lower::Number=0, upper::Number=1.0f+38, initU::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, initL::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing)
```

## BinCOO Discretized Non-negative Matrix Factorization (BinCOODNMF)
```@docs
bincoo_dnmf(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, beta::Number=2, binu::Number=eps(Float32), binv::Number=eps(Float32), teru::Number=eps(Float32), terv::Number=eps(Float32), graphv::Number=0, l1u::Number=eps(Float32), l1v::Number=eps(Float32), l2u::Number=eps(Float32), l2v::Number=eps(Float32), dim::Number=3, numepoch::Number=5, chunksize::Number=1, lower::Number=0, upper::Number=1.0f+38, initU::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, initL::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing)
```

## Graph Laplacian (L = D - A, where D is a degree matrix and A is an adjacent matrix).
```@docs
graph_laplacian(A::AbstractArray, norm::Bool=true)
```
