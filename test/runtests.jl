using OnlineNMF
using OnlinePCA
using OnlinePCA: read_csv, write_csv
using Test
using ArgParse
using DelimitedFiles
using Statistics
using Distributions
using SparseArrays
using MatrixMarket

# Setting
## Input Directory
tmp = mktempdir()
julia = joinpath(Sys.BINDIR, "julia")
bindir = joinpath(dirname(pathof(OnlineNMF)), "..", "bin")

function testfilesize(remove::Bool, x...)
	for n = 1:length(x)
		@test filesize(x[n]) != 0
		if remove
			rm(x[n])
		end
	end
end

data = Int64.(ceil.(rand(NegativeBinomial(1, 0.5), 300, 99)))
data[1:50, 1:33] .= 100*data[1:50, 1:33]
data[51:100, 34:66] .= 100*data[51:100, 34:66]
data[101:150, 67:99] .= 100*data[101:150, 67:99]

# CSV
write_csv(joinpath(tmp, "Data.csv"), data)

# Matrix Market (MM)
mmwrite(joinpath(tmp, "Data.mtx"), sparse(data))

# CSV => Zstandard
csv2bin(csvfile=joinpath(tmp, "Data.csv"),
	binfile=joinpath(tmp, "Data.zst"))

# MM => Zstandard
mm2bin(mmfile=joinpath(tmp, "Data.mtx"),
	binfile=joinpath(tmp, "Data.mtx.zst"))

# Tests
println("Running all tests...")

include("test_nmf.jl")
include("test_dnmf.jl")
include("test_sparse_nmf.jl")
include("test_sparse_dnmf.jl")

println("All tests completed.")
