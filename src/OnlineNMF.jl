module OnlineNMF

using ArgParse:
    ArgParseSettings, parse_args, @add_arg_table!
using CodecZstd:
    ZstdCompressorStream, ZstdDecompressorStream
using DelimitedFiles:
    writedlm, readdlm
using LinearAlgebra:
    Diagonal
using LoopVectorization:
    @view, @turbo
using ProgressMeter:
    Progress, next!
using Random:
    randperm
using SparseArrays:
    sparse

export output, parse_commandline, nmf, dnmf, sparse_nmf, sparse_dnmf, bincoo_nmf, bincoo_dnmf, graph_laplacian

include("Utils.jl")
include("nmf.jl")
include("dnmf.jl")
include("sparse_nmf.jl")
include("sparse_dnmf.jl")
include("bincoo_nmf.jl")
include("bincoo_dnmf.jl")
include("graph_laplacian.jl")

end