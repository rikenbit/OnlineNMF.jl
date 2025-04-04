#####################################
println("####### DNMF (Julia API) #######")
out_dnmf_beta = dnmf(input=joinpath(tmp, "Data.zst"), dim=3, beta=2, chunksize=51)

@test size(out_dnmf_beta[1]) == (300, 3)
@test size(out_dnmf_beta[2]) == (99, 3)
@test size(out_dnmf_beta[3]) == ()
#####################################


#####################################
println("####### DNMF (Command line) #######")
run(`$(julia) $(joinpath(bindir, "dnmf")) --input $(joinpath(tmp, "Data.zst")) --outdir $(tmp) --dim 3 --beta 2 --logdir $(tmp) --chunksize 51`)

testfilesize(true,
	joinpath(tmp, "U.csv"),
	joinpath(tmp, "V.csv"),
	joinpath(tmp, "RecError.csv"))
#####################################