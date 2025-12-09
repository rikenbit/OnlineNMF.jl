#####################################
println("####### Sparse-DNMF (Julia API) #######")
tmp_sparse_dnmf = mktempdir()

out_sparse_dnmf_beta = sparse_dnmf(input=joinpath(tmp, "Data.mtx.zst"), dim=3, beta=2, chunksize=100, numepoch=100, logdir=tmp_sparse_dnmf)
U, V, stop = out_sparse_dnmf_beta

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
# Zero matrix
zero_data = spzeros(Float64, 10, 5)
mmwrite(joinpath(tmp_sparse_dnmf, "Zero.mtx"), zero_data)
mm2bin(mmfile=joinpath(tmp_sparse_dnmf, "Zero.mtx"), binfile=joinpath(tmp_sparse_dnmf, "Zero.mtx.zst"))
@test_throws Exception sparse_dnmf(input=joinpath(tmp_sparse_dnmf, "Zero.mtx.zst"), dim=2, beta=2)

# Negative matrix
negative_data = copy(sparse_data)
negative_data[1,1] = - negative_data[1,1]
mmwrite(joinpath(tmp_sparse_dnmf, "Negative.mtx"), negative_data)
@test_throws Exception mm2bin(mmfile=joinpath(tmp_sparse_dnmf, "Negative.mtx"), binfile=joinpath(tmp_sparse_dnmf, "Negative.mtx.zst"))

# Single row data
single_row_data = sparse(copy(data)[1, :]')
mmwrite(joinpath(tmp_sparse_dnmf, "SingleRow.mtx"), single_row_data)
mm2bin(mmfile=joinpath(tmp_sparse_dnmf, "SingleRow.mtx"), binfile=joinpath(tmp_sparse_dnmf, "SingleRow.mtx.zst"))
@test_throws Exception sparse_dnmf(input=joinpath(tmp_sparse_dnmf, "SingleRow.mtx.zst"), dim=2, beta=2)

# Single column data
single_col_data = sparse(copy(data)[:, 1:1])
mmwrite(joinpath(tmp_sparse_dnmf, "SingleCol.mtx"), single_col_data)
mm2bin(mmfile=joinpath(tmp_sparse_dnmf, "SingleCol.mtx"), binfile=joinpath(tmp_sparse_dnmf, "SingleCol.mtx.zst"))
@test_throws Exception sparse_dnmf(input=joinpath(tmp_sparse_dnmf, "SingleCol.mtx.zst"), dim=2, beta=2)

# Non-divisible chunk size
out_chunk_odd = sparse_dnmf(input=joinpath(tmp, "Data.mtx.zst"), dim=3, chunksize=51)
@test size(out_chunk_odd[1]) == (300, 3)
@test size(out_chunk_odd[2]) == (99, 3)
@test size(out_chunk_odd[3]) == ()

# Extreme parameters (negative values should throw)
@test_throws Exception sparse_dnmf(input=joinpath(tmp, "Data.mtx.zst"), dim=3, binu=-1, chunksize=100)
@test_throws Exception sparse_dnmf(input=joinpath(tmp, "Data.mtx.zst"), dim=3, binv=-1, chunksize=100)
@test_throws Exception sparse_dnmf(input=joinpath(tmp, "Data.mtx.zst"), dim=3, teru=-1, chunksize=100)
@test_throws Exception sparse_dnmf(input=joinpath(tmp, "Data.mtx.zst"), dim=3, terv=-1, chunksize=100)
@test_throws Exception sparse_dnmf(input=joinpath(tmp, "Data.mtx.zst"), dim=3, graphv=-1, chunksize=100)
@test_throws Exception sparse_dnmf(input=joinpath(tmp, "Data.mtx.zst"), dim=3, l1u=-1, chunksize=100)
@test_throws Exception sparse_dnmf(input=joinpath(tmp, "Data.mtx.zst"), dim=3, l1v=-1, chunksize=100)
@test_throws Exception sparse_dnmf(input=joinpath(tmp, "Data.mtx.zst"), dim=3, l2u=-1, chunksize=100)
@test_throws Exception sparse_dnmf(input=joinpath(tmp, "Data.mtx.zst"), dim=3, l2v=-1, chunksize=100)
@test_throws Exception sparse_dnmf(input=joinpath(tmp, "Data.mtx.zst"), dim=-1, chunksize=100)
@test_throws Exception sparse_dnmf(input=joinpath(tmp, "Data.mtx.zst"), dim=100, chunksize=100)
@test_throws Exception sparse_dnmf(input=joinpath(tmp, "Data.mtx.zst"), dim=3, numepoch=-1, chunksize=100)
@test_throws Exception sparse_dnmf(input=joinpath(tmp, "Data.mtx.zst"), dim=3, chunksize=-1)

# Error handling test
@test_throws SystemError sparse_dnmf(input="nonexistent_file.mtx.zst", dim=3)
#####################################

#####################################
println("####### Sparse-DNMF (Command line) #######")
run(`$(julia) $(joinpath(bindir, "sparse_dnmf")) --input $(joinpath(tmp, "Data.mtx.zst")) --outdir $(tmp) --dim 3 --beta 2 --logdir $(tmp) --chunksize 100`)

testfilesize(true,
	joinpath(tmp, "U.csv"),
	joinpath(tmp, "V.csv"),
	joinpath(tmp, "RecError.csv"))
#####################################