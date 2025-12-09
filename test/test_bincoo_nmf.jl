#####################################
println("####### BinCOO-NMF (Alpha, Julia API) #######")
tmp_bincoo_nmf_alpha = mktempdir()

out_bincoo_nmf_alpha = bincoo_nmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=3, alpha=1, algorithm="alpha", chunksize=100, numepoch=100, logdir=tmp_bincoo_nmf_alpha)
U, V, stop = out_bincoo_nmf_alpha

# Size tests
@test size(U) == (300, 3)
@test size(V) == (99, 3)
@test size(stop) == ()

# Accuracy tests
@test mean(abs.(data - U * V')) < 20

# Non-negativity tests
@test all(U .>= 0)
@test all(V .>= 0)

# Edge cases tests
# Non-divisible chunk size
out_chunk_odd = bincoo_nmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=3, algorithm="alpha", chunksize=51)
@test size(out_chunk_odd[1]) == (300, 3)
@test size(out_chunk_odd[2]) == (99, 3)
@test size(out_chunk_odd[3]) == ()

# Extreme parameters
@test_throws Exception bincoo_nmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=3, graphv=-1, algorithm="alpha", chunksize=100)
@test_throws Exception bincoo_nmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=3, l1u=-1, algorithm="alpha", chunksize=100)
@test_throws Exception bincoo_nmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=3, l1v=-1, algorithm="alpha", chunksize=100)
@test_throws Exception bincoo_nmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=3, l2u=-1, algorithm="alpha", chunksize=100)
@test_throws Exception bincoo_nmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=3, l2v=-1, algorithm="alpha", chunksize=100)
@test_throws Exception bincoo_nmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=-1, algorithm="alpha", chunksize=100)
@test_throws Exception bincoo_nmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=100, algorithm="alpha", chunksize=100)
@test_throws Exception bincoo_nmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=3, numepoch=-1, algorithm="alpha", chunksize=100)
@test_throws Exception bincoo_nmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=3, algorithm="alpha", chunksize=-1)

# Error handling test
@test_throws SystemError bincoo_nmf(input="nonexistent_file.bincoo.zst", dim=3, algorithm="alpha")
#####################################

#####################################
println("####### BinCOO-NMF (Beta, Julia API) #######")
tmp_bincoo_nmf_beta = mktempdir()

out_bincoo_nmf_beta = bincoo_nmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=3, beta=2, algorithm="beta", chunksize=100, numepoch=100, logdir=tmp_bincoo_nmf_beta)
U, V, stop = out_bincoo_nmf_beta

# Size tests
@test size(U) == (300, 3)
@test size(V) == (99, 3)
@test size(stop) == ()

# Accuracy tests
@test mean(abs.(data - U * V')) < 20

# Non-negativity tests
@test all(U .>= 0)
@test all(V .>= 0)

# Edge cases tests
# Non-divisible chunk size
out_chunk_odd = bincoo_nmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=3, beta=2, algorithm="beta", chunksize=51)
@test size(out_chunk_odd[1]) == (300, 3)
@test size(out_chunk_odd[2]) == (99, 3)
@test size(out_chunk_odd[3]) == ()

# Extreme parameters
@test_throws Exception bincoo_nmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=3, graphv=-1, beta=2, algorithm="beta", chunksize=100)
@test_throws Exception bincoo_nmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=3, l1u=-1, beta=2, algorithm="beta", chunksize=100)
@test_throws Exception bincoo_nmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=3, l1v=-1, beta=2, algorithm="beta", chunksize=100)
@test_throws Exception bincoo_nmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=3, l2u=-1, beta=2, algorithm="beta", chunksize=100)
@test_throws Exception bincoo_nmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=3, l2v=-1, beta=2, algorithm="beta", chunksize=100)
@test_throws Exception bincoo_nmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=-1, beta=2, algorithm="beta", chunksize=100)
@test_throws Exception bincoo_nmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=100, beta=2, algorithm="beta", chunksize=100)
@test_throws Exception bincoo_nmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=3, numepoch=-1, beta=2, algorithm="beta", chunksize=100)
@test_throws Exception bincoo_nmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=3, beta=2, algorithm="beta", chunksize=-1)

# Error handling test
@test_throws SystemError bincoo_nmf(input="nonexistent_file.bincoo.zst", dim=3, beta=2, algorithm="beta")
#####################################

#####################################
println("####### BinCOO-NMF (Alpha, Command line) #######")
run(`$(julia) $(joinpath(bindir, "bincoo_nmf")) --input $(joinpath(tmp, "Data.bincoo.zst")) --outdir $(tmp) --dim 3 --alpha 1 --algorithm alpha --logdir $(tmp) --chunksize 100`)

testfilesize(true,
	joinpath(tmp, "U.csv"),
	joinpath(tmp, "V.csv"),
	joinpath(tmp, "RecError.csv"))
#####################################

#####################################
println("####### BinCOO-NMF (Beta, Command line) #######")
run(`$(julia) $(joinpath(bindir, "bincoo_nmf")) --input $(joinpath(tmp, "Data.bincoo.zst")) --outdir $(tmp) --dim 3 --beta 2 --algorithm beta --logdir $(tmp) --chunksize 100`)

testfilesize(true,
	joinpath(tmp, "U.csv"),
	joinpath(tmp, "V.csv"),
	joinpath(tmp, "RecError.csv"))
#####################################