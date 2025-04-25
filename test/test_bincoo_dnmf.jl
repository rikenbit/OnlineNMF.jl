#####################################
println("####### BinCOO-DNMF (Julia API) #######")
out_bincoo_dnmf_beta = bincoo_dnmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=3, beta=2, chunksize=51)

@test size(out_bincoo_dnmf_beta[1]) == (300, 3)
@test size(out_bincoo_dnmf_beta[2]) == (99, 3)
@test size(out_bincoo_dnmf_beta[3]) == ()
#####################################


#####################################
println("####### BinCOO-DNMF (Command line) #######")
run(`$(julia) $(joinpath(bindir, "bincoo_dnmf")) --input $(joinpath(tmp, "Data.bincoo.zst")) --outdir $(tmp) --dim 3 --beta 2 --logdir $(tmp) --chunksize 51`)

testfilesize(true,
	joinpath(tmp, "U.csv"),
	joinpath(tmp, "V.csv"),
	joinpath(tmp, "RecError.csv"))
#####################################