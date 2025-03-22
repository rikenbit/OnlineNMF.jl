#####################################
println("####### Sparse-NMF (Alpha, Julia API) #######")
out_sparse_nmf_alpha = sparse_nmf(input=joinpath(tmp, "Data.mtx.zst"), dim=3, alpha=1, algorithm="alpha")

@test size(out_sparse_nmf_alpha[1]) == (300, 3)
@test size(out_sparse_nmf_alpha[2]) == (99, 3)
@test size(out_sparse_nmf_alpha[3]) == ()
####################################

#####################################
println("####### Sparse-NMF (Beta, Julia API) #######")
out_sparse_nmf_beta = sparse_nmf(input=joinpath(tmp, "Data.mtx.zst"), dim=3, beta=2, algorithm="beta")

@test size(out_sparse_nmf_beta[1]) == (300, 3)
@test size(out_sparse_nmf_beta[2]) == (99, 3)
@test size(out_sparse_nmf_beta[3]) == ()
#####################################


#####################################
println("####### Sparse-NMF (Alpha, Command line) #######")
run(`$(julia) $(joinpath(bindir, "sparse_nmf")) --input $(joinpath(tmp, "Data.mtx.zst")) --outdir $(tmp) --dim 3 --alpha 1 --algorithm alpha --logdir $(tmp)`)

testfilesize(true,
	joinpath(tmp, "U.csv"),
	joinpath(tmp, "V.csv"),
	joinpath(tmp, "RecError.csv"))
#####################################

#####################################
println("####### Sparse-NMF (Beta, Command line) #######")
run(`$(julia) $(joinpath(bindir, "sparse_nmf")) --input $(joinpath(tmp, "Data.mtx.zst")) --outdir $(tmp) --dim 3 --beta 2 --algorithm beta --logdir $(tmp)`)

testfilesize(true,
	joinpath(tmp, "U.csv"),
	joinpath(tmp, "V.csv"),
	joinpath(tmp, "RecError.csv"))
#####################################