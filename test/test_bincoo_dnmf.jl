#####################################
println("####### BinCOO-DNMF (Julia API) #######")
tmp_bincoo_dnmf = mktempdir()

out_bincoo_dnmf_beta = bincoo_dnmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=3, beta=2, chunksize=100, numepoch=100, logdir=tmp_bincoo_dnmf)
U, V, stop = out_bincoo_dnmf_beta

# Size tests
@test size(U) == (300, 3)
@test size(V) == (99, 3)
@test size(stop) == ()

# Accuracy tests
@test stop >= 0

# Non-negativity tests
@test all(U .>= 0)
@test all(V .>= 0)

# Edge cases tests
# Non-divisible chunk size
out_chunk_odd = bincoo_dnmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=3, chunksize=51)
@test size(out_chunk_odd[1]) == (300, 3)
@test size(out_chunk_odd[2]) == (99, 3)
@test size(out_chunk_odd[3]) == ()

# Extreme parameters (negative values should throw)
@test_throws Exception bincoo_dnmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=3, binu=-1, chunksize=100)
@test_throws Exception bincoo_dnmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=3, binv=-1, chunksize=100)
@test_throws Exception bincoo_dnmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=3, teru=-1, chunksize=100)
@test_throws Exception bincoo_dnmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=3, terv=-1, chunksize=100)
@test_throws Exception bincoo_dnmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=3, graphv=-1, chunksize=100)
@test_throws Exception bincoo_dnmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=3, l1u=-1, chunksize=100)
@test_throws Exception bincoo_dnmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=3, l1v=-1, chunksize=100)
@test_throws Exception bincoo_dnmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=3, l2u=-1, chunksize=100)
@test_throws Exception bincoo_dnmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=3, l2v=-1, chunksize=100)
@test_throws Exception bincoo_dnmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=-1, chunksize=100)
@test_throws Exception bincoo_dnmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=100, chunksize=100)
@test_throws Exception bincoo_dnmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=3, numepoch=-1, chunksize=100)
@test_throws Exception bincoo_dnmf(input=joinpath(tmp, "Data.bincoo.zst"), dim=3, chunksize=-1)

# Error handling test
@test_throws SystemError bincoo_dnmf(input="nonexistent_file.bincoo.zst", dim=3)
#####################################

#####################################
println("####### BinCOO-DNMF (Command line) #######")
run(`$(julia) $(joinpath(bindir, "bincoo_dnmf")) --input $(joinpath(tmp, "Data.bincoo.zst")) --outdir $(tmp) --dim 3 --beta 2 --logdir $(tmp) --chunksize 100`)

testfilesize(true,
	joinpath(tmp, "U.csv"),
	joinpath(tmp, "V.csv"),
	joinpath(tmp, "RecError.csv"))
#####################################