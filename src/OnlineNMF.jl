module OnlineNMF

using DelimitedFiles:
    writedlm, readdlm
using Statistics:
    mean, var
using LinearAlgebra:
    Diagonal, lu!, qr!, svd, dot, norm, eigvecs
using Random:
    randperm
using ProgressMeter:
	Progress, next!
using ArgParse:
    ArgParseSettings, parse_args, @add_arg_table
using StatsBase:
	percentile
using DataFrames:
	DataFrame
using GLM:
	glm, coef, IdentityLink, @formula
using Distributions:
	Gamma, ccdf, Chisq
using CodecZstd:
	ZstdCompressorStream, ZstdDecompressorStream

export output, common_parse_commandline, csv2bin, mu, sinmf, ntd

include("Utils.jl")
include("csv2bin.jl")
include("mu.jl")
include("sinmf.jl")
include("ntd.jl")

end