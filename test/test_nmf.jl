#####################################
println("####### NMF (Alpha, Julia API) #######")
out_nmf_alpha = nmf(input=joinpath(tmp, "Data.zst"), dim=3, alpha=1, algorithm="alpha", chunksize=51)

@test size(out_nmf_alpha[1]) == (300, 3)
@test size(out_nmf_alpha[2]) == (99, 3)
@test size(out_nmf_alpha[3]) == ()
####################################

#####################################
println("####### NMF (Beta, Julia API) #######")
out_nmf_beta = nmf(input=joinpath(tmp, "Data.zst"), dim=3, beta=2, algorithm="beta", chunksize=51)

@test size(out_nmf_beta[1]) == (300, 3)
@test size(out_nmf_beta[2]) == (99, 3)
@test size(out_nmf_beta[3]) == ()
#####################################


#####################################
println("####### NMF (Alpha, Command line) #######")
run(`$(julia) $(joinpath(bindir, "nmf")) --input $(joinpath(tmp, "Data.zst")) --outdir $(tmp) --dim 3 --alpha 1 --algorithm alpha --logdir $(tmp) --chunksize 51`)

testfilesize(true,
	joinpath(tmp, "U.csv"),
	joinpath(tmp, "V.csv"),
	joinpath(tmp, "RecError.csv"))
#####################################

#####################################
println("####### NMF (Beta, Command line) #######")
run(`$(julia) $(joinpath(bindir, "nmf")) --input $(joinpath(tmp, "Data.zst")) --outdir $(tmp) --dim 3 --beta 2 --algorithm beta --logdir $(tmp) --chunksize 51`)

testfilesize(true,
	joinpath(tmp, "U.csv"),
	joinpath(tmp, "V.csv"),
	joinpath(tmp, "RecError.csv"))
#####################################