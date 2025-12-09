#####################################
println("####### Sparse-NMF (Alpha, Julia API) #######")
tmp_sparse_nmf_alpha = mktempdir()

out_sparse_nmf_alpha = sparse_nmf(input=joinpath(tmp, "Data.mtx.zst"), dim=3, alpha=1, algorithm="alpha", chunksize=100, numepoch=100, logdir=tmp_sparse_nmf_alpha)
U, V, stop = out_sparse_nmf_alpha

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
# Zero matrix
zero_data = spzeros(Float64, 10, 5)
mmwrite(joinpath(tmp_sparse_nmf_alpha, "Zero.mtx"), zero_data)
mm2bin(mmfile=joinpath(tmp_sparse_nmf_alpha, "Zero.mtx"), binfile=joinpath(tmp_sparse_nmf_alpha, "Zero.mtx.zst"))
@test_throws Exception sparse_nmf(input=joinpath(tmp_sparse_nmf_alpha, "Zero.mtx.zst"), dim=2, algorithm="alpha")

# Negative matrix
negative_data = copy(sparse_data)
negative_data[1,1] = - negative_data[1,1]
mmwrite(joinpath(tmp_sparse_nmf_alpha, "Negative.mtx"), negative_data)
@test_throws Exception mm2bin(mmfile=joinpath(tmp_sparse_nmf_alpha, "Negative.mtx"), binfile=joinpath(tmp_sparse_nmf_alpha, "Negative.mtx.zst"))

# Single row data
single_row_data = sparse(copy(data)[1, :]')
mmwrite(joinpath(tmp_sparse_nmf_alpha, "SingleRow.mtx"), single_row_data)
mm2bin(mmfile=joinpath(tmp_sparse_nmf_alpha, "SingleRow.mtx"), binfile=joinpath(tmp_sparse_nmf_alpha, "SingleRow.mtx.zst"))
@test_throws Exception sparse_nmf(input=joinpath(tmp_sparse_nmf_alpha, "SingleRow.mtx.zst"), dim=2, algorithm="alpha")

# Single column data
single_col_data = sparse(copy(data)[:, 1:1])
mmwrite(joinpath(tmp_sparse_nmf_alpha, "SingleCol.mtx"), single_col_data)
mm2bin(mmfile=joinpath(tmp_sparse_nmf_alpha, "SingleCol.mtx"), binfile=joinpath(tmp_sparse_nmf_alpha, "SingleCol.mtx.zst"))
@test_throws Exception sparse_nmf(input=joinpath(tmp_sparse_nmf_alpha, "SingleCol.mtx.zst"), dim=2, algorithm="alpha")

# Non-divisible chunk size
out_chunk_odd = sparse_nmf(input=joinpath(tmp, "Data.mtx.zst"), dim=3, algorithm="alpha", chunksize=51)
@test size(out_chunk_odd[1]) == (300, 3)
@test size(out_chunk_odd[2]) == (99, 3)
@test size(out_chunk_odd[3]) == ()

# Extreme parameters
@test_throws Exception sparse_nmf(input=joinpath(tmp, "Data.mtx.zst"), dim=3, graphv=-1, algorithm="alpha", chunksize=100)
@test_throws Exception sparse_nmf(input=joinpath(tmp, "Data.mtx.zst"), dim=3, l1u=-1, algorithm="alpha", chunksize=100)
@test_throws Exception sparse_nmf(input=joinpath(tmp, "Data.mtx.zst"), dim=3, l1v=-1, algorithm="alpha", chunksize=100)
@test_throws Exception sparse_nmf(input=joinpath(tmp, "Data.mtx.zst"), dim=3, l2u=-1, algorithm="alpha", chunksize=100)
@test_throws Exception sparse_nmf(input=joinpath(tmp, "Data.mtx.zst"), dim=3, l2v=-1, algorithm="alpha", chunksize=100)
@test_throws Exception sparse_nmf(input=joinpath(tmp, "Data.mtx.zst"), dim=-1, algorithm="alpha", chunksize=100)
@test_throws Exception sparse_nmf(input=joinpath(tmp, "Data.mtx.zst"), dim=100, algorithm="alpha", chunksize=100)
@test_throws Exception sparse_nmf(input=joinpath(tmp, "Data.mtx.zst"), dim=3, numepoch=-1, algorithm="alpha", chunksize=100)
@test_throws Exception sparse_nmf(input=joinpath(tmp, "Data.mtx.zst"), dim=3, algorithm="alpha", chunksize=-1)

# Error handling test
@test_throws SystemError sparse_nmf(input="nonexistent_file.mtx.zst", dim=3, algorithm="alpha")
#####################################

#####################################
println("####### Sparse-NMF (Beta, Julia API) #######")
tmp_sparse_nmf_beta = mktempdir()

out_sparse_nmf_beta = sparse_nmf(input=joinpath(tmp, "Data.mtx.zst"), dim=3, beta=2, algorithm="beta", chunksize=100, numepoch=100, logdir=tmp_sparse_nmf_beta)
U, V, stop = out_sparse_nmf_beta

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
# Zero matrix
zero_data = spzeros(Float64, 10, 5)
mmwrite(joinpath(tmp_sparse_nmf_beta, "Zero.mtx"), zero_data)
mm2bin(mmfile=joinpath(tmp_sparse_nmf_beta, "Zero.mtx"), binfile=joinpath(tmp_sparse_nmf_beta, "Zero.mtx.zst"))
@test_throws Exception sparse_nmf(input=joinpath(tmp_sparse_nmf_beta, "Zero.mtx.zst"), dim=2, beta=2, algorithm="beta")

# Negative matrix
negative_data = copy(sparse_data)
negative_data[1,1] = - negative_data[1,1]
mmwrite(joinpath(tmp_sparse_nmf_beta, "Negative.mtx"), negative_data)
@test_throws Exception mm2bin(mmfile=joinpath(tmp_sparse_nmf_beta, "Negative.mtx"), binfile=joinpath(tmp_sparse_nmf_beta, "Negative.mtx.zst"))

# Single row data
single_row_data = sparse(copy(data)[1, :]')
mmwrite(joinpath(tmp_sparse_nmf_beta, "SingleRow.mtx"), single_row_data)
mm2bin(mmfile=joinpath(tmp_sparse_nmf_beta, "SingleRow.mtx"), binfile=joinpath(tmp_sparse_nmf_beta, "SingleRow.mtx.zst"))
@test_throws Exception sparse_nmf(input=joinpath(tmp_sparse_nmf_beta, "SingleRow.mtx.zst"), dim=2, beta=2, algorithm="beta")

# Single column data
single_col_data = sparse(copy(data)[:, 1:1])
mmwrite(joinpath(tmp_sparse_nmf_beta, "SingleCol.mtx"), single_col_data)
mm2bin(mmfile=joinpath(tmp_sparse_nmf_beta, "SingleCol.mtx"), binfile=joinpath(tmp_sparse_nmf_beta, "SingleCol.mtx.zst"))
@test_throws Exception sparse_nmf(input=joinpath(tmp_sparse_nmf_beta, "SingleCol.mtx.zst"), dim=2, beta=2, algorithm="beta")

# Non-divisible chunk size
out_chunk_odd = sparse_nmf(input=joinpath(tmp, "Data.mtx.zst"), dim=3, beta=2, algorithm="beta", chunksize=51)
@test size(out_chunk_odd[1]) == (300, 3)
@test size(out_chunk_odd[2]) == (99, 3)
@test size(out_chunk_odd[3]) == ()

# Extreme parameters
@test_throws Exception sparse_nmf(input=joinpath(tmp, "Data.mtx.zst"), dim=3, graphv=-1, beta=2, algorithm="beta", chunksize=100)
@test_throws Exception sparse_nmf(input=joinpath(tmp, "Data.mtx.zst"), dim=3, l1u=-1, beta=2, algorithm="beta", chunksize=100)
@test_throws Exception sparse_nmf(input=joinpath(tmp, "Data.mtx.zst"), dim=3, l1v=-1, beta=2, algorithm="beta", chunksize=100)
@test_throws Exception sparse_nmf(input=joinpath(tmp, "Data.mtx.zst"), dim=3, l2u=-1, beta=2, algorithm="beta", chunksize=100)
@test_throws Exception sparse_nmf(input=joinpath(tmp, "Data.mtx.zst"), dim=3, l2v=-1, beta=2, algorithm="beta", chunksize=100)
@test_throws Exception sparse_nmf(input=joinpath(tmp, "Data.mtx.zst"), dim=-1, beta=2, algorithm="beta", chunksize=100)
@test_throws Exception sparse_nmf(input=joinpath(tmp, "Data.mtx.zst"), dim=100, beta=2, algorithm="beta", chunksize=100)
@test_throws Exception sparse_nmf(input=joinpath(tmp, "Data.mtx.zst"), dim=3, numepoch=-1, beta=2, algorithm="beta", chunksize=100)
@test_throws Exception sparse_nmf(input=joinpath(tmp, "Data.mtx.zst"), dim=3, beta=2, algorithm="beta", chunksize=-1)

# Error handling test
@test_throws SystemError sparse_nmf(input="nonexistent_file.mtx.zst", dim=3, beta=2, algorithm="beta")
#####################################

#####################################
println("####### Sparse-NMF (Alpha, Command line) #######")
run(`$(julia) $(joinpath(bindir, "sparse_nmf")) --input $(joinpath(tmp, "Data.mtx.zst")) --outdir $(tmp) --dim 3 --alpha 1 --algorithm alpha --logdir $(tmp) --chunksize 100`)

testfilesize(true,
	joinpath(tmp, "U.csv"),
	joinpath(tmp, "V.csv"),
	joinpath(tmp, "RecError.csv"))
#####################################

#####################################
println("####### Sparse-NMF (Beta, Command line) #######")
run(`$(julia) $(joinpath(bindir, "sparse_nmf")) --input $(joinpath(tmp, "Data.mtx.zst")) --outdir $(tmp) --dim 3 --beta 2 --algorithm beta --logdir $(tmp) --chunksize 100`)

testfilesize(true,
	joinpath(tmp, "U.csv"),
	joinpath(tmp, "V.csv"),
	joinpath(tmp, "RecError.csv"))
#####################################