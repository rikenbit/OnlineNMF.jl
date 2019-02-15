# OnlineNMF.jl
Online Non-negative Matrix Factorization

## Description
OnlineNMF.jl binarizes multiple CSV files, summarizes the information of data matrices and, performs some online-NMF functions for extreamly large scale matrices.

## Algorithms

- Multiplicative Update (MU)
  - Alpha-divergence
    - Alpha=2 : Pearson divergence-based
    - Alpha=1 : Kullback–Leibler divergence-based
    - Alpha=0.5 : Hellinger divergence-based
    - Alpha=-1 : Neyman divergence-based
  - Beta-divergence
    - Beta=2 : Euclid distance-based
    - Beta=0 : Itakura-Saito divergence-based
- Simultaneous NMF (siNMF)
- Non-negative Tucker decomposition (NTD)

## Installation
<!-- ```julia
julia> Pkg.add("OnlineNMF")
```
 -->
```julia
# push the key "]" and type the following command.
(v1.0) pkg> add https://github.com/rikenbit/OnlineNMF.jl
(v1.0) pkg> add PlotlyJS
# After that, push Ctrl + C to leave from Pkg REPL mode
```

## Basic API usage
### Preprocess of CSV
...

### Setting for plot
...

### Alpha-Divergence
...

### Beta-Divergence
...

### siNMF
...

### NTD
...

## Command line usage
...

## Distributed Computing with Mulitple Stepsize Setting
...
