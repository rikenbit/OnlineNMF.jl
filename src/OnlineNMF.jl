module OnlineNMF

using DelimitedFiles:
    writedlm, readdlm
using Random:
    randperm
using LinearAlgebra:
    Diagonal
using ProgressMeter:
	Progress, next!
using ArgParse:
    ArgParseSettings, parse_args, @add_arg_table
using CodecZstd:
	ZstdCompressorStream, ZstdDecompressorStream
using SparseArrays:
    sparse
using LoopVectorization:
    @view, @turbo
using Base.Threads

export output, parse_commandline, nmf, dnmf

include("Utils.jl")
include("nmf.jl")
include("dnmf.jl")
include("gdnmf.jl")
include("sparse_nmf.jl")
include("sparse_dnmf.jl")
include("sparse_gdnmf.jl")

end