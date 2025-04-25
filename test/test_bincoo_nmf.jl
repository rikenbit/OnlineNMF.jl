#####################################
println("####### BinCOO-NMF (Alpha, Julia API) #######")
out_bincoo_nmf_alpha = bincoo_nmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=3, alpha=1, algorithm="alpha", chunksize=51)

@test size(out_bincoo_nmf_alpha[1]) == (300, 3)
@test size(out_bincoo_nmf_alpha[2]) == (99, 3)
@test size(out_bincoo_nmf_alpha[3]) == ()
####################################

#####################################
println("####### BinCOO-NMF (Beta, Julia API) #######")
out_bincoo_nmf_beta = bincoo_nmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=3, beta=2, algorithm="beta", chunksize=51)

@test size(out_bincoo_nmf_beta[1]) == (300, 3)
@test size(out_bincoo_nmf_beta[2]) == (99, 3)
@test size(out_bincoo_nmf_beta[3]) == ()
#####################################


#####################################
println("####### BinCOO-NMF (Alpha, Command line) #######")
run(`$(julia) $(joinpath(bindir, "bincoo_nmf")) --input $(joinpath(tmp, "Data.bincoo.zst")) --outdir $(tmp) --dim 3 --alpha 1 --algorithm alpha --logdir $(tmp) --chunksize 51`)

testfilesize(true,
	joinpath(tmp, "U.csv"),
	joinpath(tmp, "V.csv"),
	joinpath(tmp, "RecError.csv"))
#####################################

#####################################
println("####### BinCOO-NMF (Beta, Command line) #######")
run(`$(julia) $(joinpath(bindir, "bincoo_nmf")) --input $(joinpath(tmp, "Data.bincoo.zst")) --outdir $(tmp) --dim 3 --beta 2 --algorithm beta --logdir $(tmp) --chunksize 51`)

testfilesize(true,
	joinpath(tmp, "U.csv"),
	joinpath(tmp, "V.csv"),
	joinpath(tmp, "RecError.csv"))
#####################################