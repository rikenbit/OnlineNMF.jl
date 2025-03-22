#####################################
println("####### Sparse-DNMF (Julia API) #######")
out_sparse_dnmf_beta = sparse_dnmf(input=joinpath(tmp, "Data.mtx.zst"), dim=3, beta=2)

@test size(out_sparse_dnmf_beta[1]) == (300, 3)
@test size(out_sparse_dnmf_beta[2]) == (99, 3)
@test size(out_sparse_dnmf_beta[3]) == ()
#####################################


#####################################
println("####### Sparse-DNMF (Command line) #######")
run(`$(julia) $(joinpath(bindir, "sparse_dnmf")) --input $(joinpath(tmp, "Data.mtx.zst")) --outdir $(tmp) --dim 3 --beta 2 --logdir $(tmp)`)

testfilesize(true,
	joinpath(tmp, "U.csv"),
	joinpath(tmp, "V.csv"),
	joinpath(tmp, "RecError.csv"))
#####################################