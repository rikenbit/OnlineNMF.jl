# OnlineNMF.jl
Online Non-negative Matrix Factorization

[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://rikenbit.github.io/OnlineNMF.jl/stable)
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://rikenbit.github.io/OnlineNMF.jl/latest)
[![Build Status](https://travis-ci.org/rikenbit/OnlineNMF.jl.svg?branch=master)](https://travis-ci.org/rikenbit/OnlineNMF.jl)
[![DOI](https://zenodo.org/badge/170862070.svg)](https://doi.org/10.5281/zenodo.8199413)

## Description
OnlineNMF.jl performs some online-NMF functions for extreamly large scale matrices.

## Algorithms

- Multiplicative Update (MU)
  - Alpha-divergence: [Cichocki, A. et al., 2008](https://www.sciencedirect.com/science/article/pii/S0167865508000767)
    - Alpha=2 : Pearson divergence-based NMF
    - Alpha=0 or 1 : Kullback–Leibler (KL) divergence-based NMF
    - Alpha=0.5 : Hellinger divergence-based NMF
  - Beta-divergence: [Févotte, C. et al., 2011](https://ieeexplore.ieee.org/document/6795238), [Nakano, M. et al., 2010](https://ieeexplore.ieee.org/document/5589233)
    - Beta=2 : Euclidean distance-based NMF with Gaussian distribution
    - Beta=1 : Kullback–Leibler divergence-based NMF with Poisson distribution
    - Beta=0 : Itakura-Saito divergence-based NMF with Gamma distribution
- Discretized Non-negative Matrix Factorization (DNMF): [Koki Tsuyuzaki, 2023](https://joss.theoj.org/papers/10.21105/joss.05664)

## Installation
<!-- ```julia
julia> using Pkg
julia> Pkg.add("OnlinePCA")
julia> Pkg.add("OnlineNMF")
```
 -->
```julia
# push the key "]" and type the following command.
(@julia) pkg> add https://github.com/rikenbit/OnlinePCA.jl
(@julia) pkg> add https://github.com/rikenbit/OnlineNMF.jl
(@julia) pkg> add PlotlyJS
# After that, push Ctrl + C to leave from Pkg REPL mode
```

## Basic API usage
### Preprocess of CSV
```julia
using OnlinePCA
using OnlinePCA: readcsv, writecsv
using OnlineNMF
using Distributions
using DelimitedFiles
using SparseArrays
using MatrixMarket

# CSV
tmp = mktempdir()
input = Int64.(ceil.(rand(Binomial(10, 0.05), 300, 99)))
input[1:50, 1:33] .= 100*input[1:50, 1:33]
input[51:100, 34:66] .= 100*input[51:100, 34:66]
input[101:150, 67:99] .= 100*input[101:150, 67:99]
writecsv(joinpath(tmp, "Data.csv"), input)

# Matrix Market (MM)
mmwrite(joinpath(tmp, "Data.mtx"), sparse(input))

# Binarization (Zstandard)
csv2bin(csvfile=joinpath(tmp, "Data.csv"), binfile=joinpath(tmp, "Data.zst"))

# Sparsification (Zstandard + MM format)
mm2bin(mmfile=joinpath(tmp, "Data.mtx"), binfile=joinpath(tmp, "Data.mtx.zst"))
```

### Setting for plot
```julia
using DataFrames
using PlotlyJS

function subplots(out_nmf, group)
	# data frame
	data_left = DataFrame(pc1=out_nmf[2][:,1], pc2=out_nmf[2][:,2], group=group)
	data_right = DataFrame(pc2=out_nmf[2][:,2], pc3=out_nmf[2][:,3], group=group)
	# plot
	p_left = Plot(data_left, x=:pc1, y=:pc2, mode="markers", marker_size=10, group=:group)
	p_right = Plot(data_right, x=:pc2, y=:pc3, mode="markers", marker_size=10,
	group=:group, showlegend=false)
	p_left.data[1]["marker_color"] = "red"
	p_left.data[2]["marker_color"] = "blue"
	p_left.data[3]["marker_color"] = "green"
	p_right.data[1]["marker_color"] = "red"
	p_right.data[2]["marker_color"] = "blue"
	p_right.data[3]["marker_color"] = "green"
	p_left.data[1]["name"] = "group1"
	p_left.data[2]["name"] = "group2"
	p_left.data[3]["name"] = "group3"
	p_left.layout["title"] = "PC1 vs PC2"
	p_right.layout["title"] = "PC2 vs PC3"
	p_left.layout["xaxis_title"] = "pc1"
	p_left.layout["yaxis_title"] = "pc2"
	p_right.layout["xaxis_title"] = "pc2"
	p_right.layout["yaxis_title"] = "pc3"
	plot([p_left p_right])
end

group=vcat(repeat(["group1"],inner=33), repeat(["group2"],inner=33), repeat(["group3"],inner=33))
```

### NMF based on Alpha-Divergence
```julia
out_nmf_alpha = nmf(input=joinpath(tmp, "Data.zst"), dim=3, alpha=1, algorithm="alpha")

subplots(out_nmf_alpha, group)
```

### NMF based on Beta-Divergence
```julia
out_nmf_beta = nmf(input=joinpath(tmp, "Data.zst"), dim=3, beta=2, algorithm="beta")

subplots(out_nmf_beta, group)
```
### Semi-Binary NMF based on Beta-Divergence
```julia
out_dnmf_beta = dnmf(input=joinpath(tmp, "Data.zst"), dim=3, beta=1, binu=10^2)
minimum(out_dnmf_beta[1])
maximum(out_dnmf_beta[1])

subplots(out_nmf_beta, group)
```

### Semi-Ternary NMF based on Beta-Divergence
```julia
out_dnmf_beta = dnmf(input=joinpath(tmp, "Data.zst"), dim=3, beta=1, teru=10^2)
minimum(out_dnmf_beta[1])
median(out_dnmf_beta[1])
maximum(out_dnmf_beta[1])

subplots(out_nmf_beta, group)
```

### Sparse-NMF based on Alpha-Divergence
```julia
out_nmf_alpha = sparse_nmf(input=joinpath(tmp, "Data.mtx.zst"), dim=3, alpha=1)

subplots(out_nmf_alpha, group)
```

### Sparse-NMF based on Beta-Divergence
```julia
out_nmf_beta = sparse_nmf(input=joinpath(tmp, "Data.mtx.zst"), dim=3, beta=2)

subplots(out_nmf_beta, group)
```
### Sparse-DNMF based on Beta-Divergence
```julia
out_nmf_beta = sparse_dnmf(input=joinpath(tmp, "Data.mtx.zst"), dim=3, beta=2)

subplots(out_nmf_beta, group)
```

## Command line usage
All the CSV preprocess functions and NMF functions also can be performed as command line tools with same parameter names like below.

```bash
# CSV → Julia Binary
julia YOUR_HOME_DIR/.julia/v0.x/OnlinePCA/bin/csv2bin \
    --csvfile Data.csv --binfile Data.zst

# NMF based on Alpha-Divergence
julia YOUR_HOME_DIR/.julia/v0.x/OnlineNMF/bin/nmf \
    --input Data.zst --dim 3 \
    --numepoch 10 --alpha 1

# NMF based on Beta-Divergence
julia YOUR_HOME_DIR/.julia/v0.x/OnlineNMF/bin/nmf \
    --input Data.zst --dim 3 \
    --numepoch 10 --beta 2

# DNMF based on Beta-Divergence
julia YOUR_HOME_DIR/.julia/v0.x/OnlineNMF/bin/dnmf \
    --input Data.zst --dim 3 \
    --numepoch 10 --beta 2

# Sparse-NMF based on Alpha-Divergence
julia YOUR_HOME_DIR/.julia/v0.x/OnlineNMF/bin/sparse_nmf \
    --input Data.mtx.zst --dim 3 \
    --numepoch 10 --alpha 1

# Sparse-NMF based on Beta-Divergence
julia YOUR_HOME_DIR/.julia/v0.x/OnlineNMF/bin/sparse_nmf \
    --input Data.mtx.zst --dim 3 \
    --numepoch 10 --beta 2

# Sparse-DNMF based on Beta-Divergence
julia YOUR_HOME_DIR/.julia/v0.x/OnlineNMF/bin/sparse_dnmf \
    --input Data.mtx.zst --dim 3 \
    --numepoch 10 --beta 2
```

## Contributing

If you have suggestions for how `OnlineNMF.jl` could be improved, or want to report a bug, open an issue! We'd love all and any contributions.

For more, check out the [Contributing Guide](CONTRIBUTING.md).

## Author
- Koki Tsuyuzaki