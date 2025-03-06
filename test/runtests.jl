using OnlineNMF
using OnlineNMF: readcsv, writecsv
using Test
using Pkg
using DelimitedFiles
using Statistics
using Distributions

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

#####################################
X = Int64.(ceil.(rand(NegativeBinomial(1, 0.5), 300, 30)))
X[1:50, 1:10] .= 100*X[1:50, 1:10]
X[51:100, 11:20] .= 100*X[51:100, 11:20]
X[101:150, 21:30] .= 100*X[101:150, 21:30]
writecsv(joinpath(tmp, "X.csv"), X)

Y = Int64.(ceil.(rand(NegativeBinomial(1, 0.5), 300, 40)))
Y[1:50, 1:15] .= 100*Y[1:50, 1:15]
Y[51:100, 16:24] .= 100*Y[51:100, 16:24]
Y[101:150, 25:40] .= 100*Y[101:150, 25:40]
writecsv(joinpath(tmp, "Y.csv"), Y)

Z = Int64.(ceil.(rand(NegativeBinomial(1, 0.5), 300, 50)))
Z[1:50, 1:20] .= 100*Z[1:50, 1:20]
Z[51:100, 21:40] .= 100*Z[51:100, 21:40]
Z[101:150, 41:50] .= 100*Z[101:150, 41:50]
writecsv(joinpath(tmp, "Z.csv"), Z)
#####################################


#####################################
println("####### Binarization (Julia API) #######")
csv2bin(csvfile=joinpath(tmp, "X.csv"),
  binfile=joinpath(tmp, "X.zst"))
csv2bin(csvfile=joinpath(tmp, "Y.csv"),
  binfile=joinpath(tmp, "Y.zst"))
csv2bin(csvfile=joinpath(tmp, "Z.csv"),
  binfile=joinpath(tmp, "Z.zst"))

testfilesize(false, joinpath(tmp, "X.zst"))
testfilesize(false, joinpath(tmp, "Y.zst"))
testfilesize(false, joinpath(tmp, "Z.zst"))
####################################

# ####################################
# println("####### Binarization (Command line) #######")
# run(`$(julia) $(joinpath(bindir, "csv2bin")) --csvfile $(joinpath(tmp, "X.csv")) --binfile $(joinpath(tmp, "X.zst"))`)
# run(`$(julia) $(joinpath(bindir, "csv2bin")) --csvfile $(joinpath(tmp, "Y.csv")) --binfile $(joinpath(tmp, "Y.zst"))`)
# run(`$(julia) $(joinpath(bindir, "csv2bin")) --csvfile $(joinpath(tmp, "Z.csv")) --binfile $(joinpath(tmp, "Z.zst"))`)

# testfilesize(false, joinpath(tmp, "X.zst"))
# testfilesize(false, joinpath(tmp, "Y.zst"))
# testfilesize(false, joinpath(tmp, "Z.zst"))
# ####################################


# ####################################
# println("####### Multiplicative Update (Julia API) #######")
# # Alpha = 2 : Pearson divergence-based
# out_mu_alpha1 = mu(input=joinpath(tmp, "X.zst"), alpha=2,
#   dim=3, numepoch=10, numbatch=10, logdir=tmp)

# @test size(out_mu_alpha1[1][1]) == (30, 3)
# @test size(out_mu_alpha1[1][2]) == (40, 3)
# @test size(out_mu_alpha1[1][3]) == (50, 3)
# @test size(out_mu_alpha1[2][1]) == (3, )
# @test size(out_mu_alpha1[2][2]) == (3, )
# @test size(out_mu_alpha1[2][3]) == (3, )
# @test size(out_mu_alpha1[3][1]) == (300, 3)
# @test size(out_mu_alpha1[3][2]) == (300, 3)
# @test size(out_mu_alpha1[3][3]) == (300, 3)
# @test size(out_mu_alpha1[4][1]) == ()
# @test size(out_mu_alpha1[4][2]) == ()
# @test size(out_mu_alpha1[4][3]) == ()
# @test size(out_mu_alpha1[5][1]) == ()
# @test size(out_mu_alpha1[5][2]) == ()
# @test size(out_mu_alpha1[5][3]) == ()
# @test size(out_mu_alpha1[6][1]) == ()
# @test size(out_mu_alpha1[6][2]) == ()
# @test size(out_mu_alpha1[6][3]) == ()
# @test size(out_mu_alpha1[7][1]) == ()
# @test size(out_mu_alpha1[7][2]) == ()
# @test size(out_mu_alpha1[7][3]) == ()
# @test size(out_mu_alpha1[8]) == ()

# # Alpha = 1 : KL divergence-based

# # Alpha = 0.5 : Hellinger divergence-based

# # Alpha = -1 : Neyman divergence-based

# # Beta = 2 : Euclid distance-based

# # Beta = 0 : Itakura-Saito divergence-based


# ####################################

# ####################################
# println("####### Multiplicative Update (Command line) #######")


# ####################################

# ####################################
# println("####### Simultaneous NMF (Julia API) #######")
# # Alpha = 2 : Pearson divergence-based
# out_sinmf1 = sinmf(
#   input=[joinpath(tmp, "X.zst"),
#     joinpath(tmp, "Y.zst"),
#     joinpath(tmp, "Z.zst")],
#   alpha = 2,
#   dim=3,
#   numepoch=10,
#   numbatch=10,
#   logdir=tmp)

# @test size(out_sinmf1[1][1]) == (30, 3)
# @test size(out_sinmf1[1][2]) == (40, 3)
# @test size(out_sinmf1[1][3]) == (50, 3)
# @test size(out_sinmf1[2][1]) == (3, )
# @test size(out_sinmf1[2][2]) == (3, )
# @test size(out_sinmf1[2][3]) == (3, )
# @test size(out_sinmf1[3][1]) == (300, 3)
# @test size(out_sinmf1[3][2]) == (300, 3)
# @test size(out_sinmf1[3][3]) == (300, 3)
# @test size(out_sinmf1[4][1]) == ()
# @test size(out_sinmf1[4][2]) == ()
# @test size(out_sinmf1[4][3]) == ()
# @test size(out_sinmf1[5][1]) == ()
# @test size(out_sinmf1[5][2]) == ()
# @test size(out_sinmf1[5][3]) == ()
# @test size(out_sinmf1[6][1]) == ()
# @test size(out_sinmf1[6][2]) == ()
# @test size(out_sinmf1[6][3]) == ()
# @test size(out_sinmf1[7][1]) == ()
# @test size(out_sinmf1[7][2]) == ()
# @test size(out_sinmf1[7][3]) == ()
# @test size(out_sinmf1[8]) == ()

# # Alpha = 1 : KL divergence-based

# # Alpha = 0.5 : Hellinger divergence-based

# # Alpha = -1 : Neyman divergence-based

# # Beta = 2 : Euclid distance-based

# # Beta = 0 : Itakura-Saito divergence-based


# ####################################

# ####################################
# println("####### Simultaneous NMF (Command line) #######")

# ####################################

# ####################################
# println("####### Non-negative Tucker decomposition (Julia API) #######")
# # Alpha = 2 : Pearson divergence-based
# out_mu_alpha1 = ntd(input=joinpath(tmp, "X.zst"), alpha=2,
#   dim=3, numepoch=10, numbatch=10, logdir=tmp)

# @test size(out_mu_alpha1[1][1]) == (30, 3)
# @test size(out_mu_alpha1[1][2]) == (40, 3)
# @test size(out_mu_alpha1[1][3]) == (50, 3)
# @test size(out_mu_alpha1[2][1]) == (3, )
# @test size(out_mu_alpha1[2][2]) == (3, )
# @test size(out_mu_alpha1[2][3]) == (3, )
# @test size(out_mu_alpha1[3][1]) == (300, 3)
# @test size(out_mu_alpha1[3][2]) == (300, 3)
# @test size(out_mu_alpha1[3][3]) == (300, 3)
# @test size(out_mu_alpha1[4][1]) == ()
# @test size(out_mu_alpha1[4][2]) == ()
# @test size(out_mu_alpha1[4][3]) == ()
# @test size(out_mu_alpha1[5][1]) == ()
# @test size(out_mu_alpha1[5][2]) == ()
# @test size(out_mu_alpha1[5][3]) == ()
# @test size(out_mu_alpha1[6][1]) == ()
# @test size(out_mu_alpha1[6][2]) == ()
# @test size(out_mu_alpha1[6][3]) == ()
# @test size(out_mu_alpha1[7][1]) == ()
# @test size(out_mu_alpha1[7][2]) == ()
# @test size(out_mu_alpha1[7][3]) == ()
# @test size(out_mu_alpha1[8]) == ()

# # Alpha = 1 : KL divergence-based

# # Alpha = 0.5 : Hellinger divergence-based

# # Alpha = -1 : Neyman divergence-based

# # Beta = 2 : Euclid distance-based

# # Beta = 0 : Itakura-Saito divergence-based


# ####################################
