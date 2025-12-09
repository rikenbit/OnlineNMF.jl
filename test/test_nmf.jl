#####################################
println("####### NMF (Alpha, Julia API) #######")
tmp_nmf_alpha = mktempdir()

out_nmf_alpha = nmf(input=joinpath(tmp, "Data.zst"), dim=3, alpha=1, algorithm="alpha", chunksize=100, numepoch=100, logdir=tmp_nmf_alpha)
U, V, stop = out_nmf_alpha

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
zero_data = zeros(Float64, 10, 5)
writedlm(joinpath(tmp_nmf_alpha, "Zero.csv"), zero_data, ",")
csv2bin(csvfile=joinpath(tmp_nmf_alpha, "Zero.csv"), binfile=joinpath(tmp_nmf_alpha, "Zero.zst"))
@test_throws Exception nmf(input=joinpath(tmp_nmf_alpha, "Zero.zst"), dim=2, algorithm="alpha")

# Negative matrix
negative_data = copy(data)
negative_data[1,1] = - negative_data[1,1]
writedlm(joinpath(tmp_nmf_alpha, "Negative.csv"), negative_data, ",")
@test_throws InexactError csv2bin(csvfile=joinpath(tmp_nmf_alpha, "Negative.csv"), binfile=joinpath(tmp_nmf_alpha, "Negative.zst"))

# Single row data
single_row_data = copy(data)[1, :]'
writedlm(joinpath(tmp_nmf_alpha, "SingleRow.csv"), single_row_data, ",")
csv2bin(csvfile=joinpath(tmp_nmf_alpha, "SingleRow.csv"), binfile=joinpath(tmp_nmf_alpha, "SingleRow.zst"))
@test_throws Exception nmf(input=joinpath(tmp_nmf_alpha, "SingleRow.zst"), dim=2, algorithm="alpha")

# Single column data
single_col_data = copy(data)[:, 1]
writedlm(joinpath(tmp_nmf_alpha, "SingleCol.csv"), single_col_data, ",")
csv2bin(csvfile=joinpath(tmp_nmf_alpha, "SingleCol.csv"), binfile=joinpath(tmp_nmf_alpha, "SingleCol.zst"))
@test_throws Exception nmf(input=joinpath(tmp_nmf_alpha, "SingleCol.zst"), dim=2, algorithm="alpha")

# Non-divisible chunk size
out_chunk_odd = nmf(input=joinpath(tmp, "Data.zst"), dim=3, algorithm="alpha", chunksize=51)
@test size(out_chunk_odd[1]) == (300, 3)
@test size(out_chunk_odd[2]) == (99, 3)
@test size(out_chunk_odd[3]) == ()

# Extreme parameters
@test_throws Exception nmf(input=joinpath(tmp, "Data.zst"), dim=3, graphv=-1, algorithm="alpha", chunksize=100)
@test_throws Exception nmf(input=joinpath(tmp, "Data.zst"), dim=3, l1u=-1, algorithm="alpha", chunksize=100)
@test_throws Exception nmf(input=joinpath(tmp, "Data.zst"), dim=3, l1v=-1, algorithm="alpha", chunksize=100)
@test_throws Exception nmf(input=joinpath(tmp, "Data.zst"), dim=3, l2u=-1, algorithm="alpha", chunksize=100)
@test_throws Exception nmf(input=joinpath(tmp, "Data.zst"), dim=3, l2v=-1, algorithm="alpha", chunksize=100)
@test_throws Exception nmf(input=joinpath(tmp, "Data.zst"), dim=-1, algorithm="alpha", chunksize=100)
@test_throws Exception nmf(input=joinpath(tmp, "Data.zst"), dim=100, algorithm="alpha", chunksize=100)
@test_throws Exception nmf(input=joinpath(tmp, "Data.zst"), dim=3, numepoch=-1, algorithm="alpha", chunksize=100)
@test_throws Exception nmf(input=joinpath(tmp, "Data.zst"), dim=3, algorithm="alpha", chunksize=-1)

# Error handling test
@test_throws SystemError nmf(input="nonexistent_file.zst", dim=3, algorithm="alpha")
#####################################

#####################################
println("####### NMF (Beta, Julia API) #######")
tmp_nmf_beta = mktempdir()

out_nmf_beta = nmf(input=joinpath(tmp, "Data.zst"), dim=3, beta=2, algorithm="beta", chunksize=100, numepoch=100, logdir=tmp_nmf_beta)
U, V, stop = out_nmf_beta

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
zero_data = zeros(Float64, 10, 5)
writedlm(joinpath(tmp_nmf_beta, "Zero.csv"), zero_data, ",")
csv2bin(csvfile=joinpath(tmp_nmf_beta, "Zero.csv"), binfile=joinpath(tmp_nmf_beta, "Zero.zst"))
@test_throws Exception nmf(input=joinpath(tmp_nmf_beta, "Zero.zst"), dim=2, beta=2, algorithm="beta")

# Negative matrix
negative_data = copy(data)
negative_data[1,1] = - negative_data[1,1]
writedlm(joinpath(tmp_nmf_beta, "Negative.csv"), negative_data, ",")
@test_throws InexactError csv2bin(csvfile=joinpath(tmp_nmf_beta, "Negative.csv"), binfile=joinpath(tmp_nmf_beta, "Negative.zst"))

# Single row data
single_row_data = copy(data)[1, :]'
writedlm(joinpath(tmp_nmf_beta, "SingleRow.csv"), single_row_data, ",")
csv2bin(csvfile=joinpath(tmp_nmf_beta, "SingleRow.csv"), binfile=joinpath(tmp_nmf_beta, "SingleRow.zst"))
@test_throws Exception nmf(input=joinpath(tmp_nmf_beta, "SingleRow.zst"), dim=2, beta=2, algorithm="beta")

# Single column data
single_col_data = copy(data)[:, 1]
writedlm(joinpath(tmp_nmf_beta, "SingleCol.csv"), single_col_data, ",")
csv2bin(csvfile=joinpath(tmp_nmf_beta, "SingleCol.csv"), binfile=joinpath(tmp_nmf_beta, "SingleCol.zst"))
@test_throws Exception nmf(input=joinpath(tmp_nmf_beta, "SingleCol.zst"), dim=2, beta=2, algorithm="beta")

# Non-divisible chunk size
out_chunk_odd = nmf(input=joinpath(tmp, "Data.zst"), dim=3, beta=2, algorithm="beta", chunksize=51)
@test size(out_chunk_odd[1]) == (300, 3)
@test size(out_chunk_odd[2]) == (99, 3)
@test size(out_chunk_odd[3]) == ()

# Extreme parameters
@test_throws Exception nmf(input=joinpath(tmp, "Data.zst"), dim=3, graphv=-1, beta=2, algorithm="beta", chunksize=100)
@test_throws Exception nmf(input=joinpath(tmp, "Data.zst"), dim=3, l1u=-1, beta=2, algorithm="beta", chunksize=100)
@test_throws Exception nmf(input=joinpath(tmp, "Data.zst"), dim=3, l1v=-1, beta=2, algorithm="beta", chunksize=100)
@test_throws Exception nmf(input=joinpath(tmp, "Data.zst"), dim=3, l2u=-1, beta=2, algorithm="beta", chunksize=100)
@test_throws Exception nmf(input=joinpath(tmp, "Data.zst"), dim=3, l2v=-1, beta=2, algorithm="beta", chunksize=100)
@test_throws Exception nmf(input=joinpath(tmp, "Data.zst"), dim=-1, beta=2, algorithm="beta", chunksize=100)
@test_throws Exception nmf(input=joinpath(tmp, "Data.zst"), dim=100, beta=2, algorithm="beta", chunksize=100)
@test_throws Exception nmf(input=joinpath(tmp, "Data.zst"), dim=3, numepoch=-1, beta=2, algorithm="beta", chunksize=100)
@test_throws Exception nmf(input=joinpath(tmp, "Data.zst"), dim=3, beta=2, algorithm="beta", chunksize=-1)

# Error handling test
@test_throws SystemError nmf(input="nonexistent_file.zst", dim=3, beta=2, algorithm="beta")
#####################################


#####################################
println("####### NMF (Alpha, Command line) #######")
run(`$(julia) $(joinpath(bindir, "nmf")) --input $(joinpath(tmp, "Data.zst")) --outdir $(tmp) --dim 3 --alpha 1 --algorithm alpha --logdir $(tmp) --chunksize 100`)

testfilesize(true,
	joinpath(tmp, "U.csv"),
	joinpath(tmp, "V.csv"),
	joinpath(tmp, "RecError.csv"))
#####################################

#####################################
println("####### NMF (Beta, Command line) #######")
run(`$(julia) $(joinpath(bindir, "nmf")) --input $(joinpath(tmp, "Data.zst")) --outdir $(tmp) --dim 3 --beta 2 --algorithm beta --logdir $(tmp) --chunksize 100`)

testfilesize(true,
	joinpath(tmp, "U.csv"),
	joinpath(tmp, "V.csv"),
	joinpath(tmp, "RecError.csv"))
#####################################