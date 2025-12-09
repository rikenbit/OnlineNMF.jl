#####################################
println("####### DNMF (Julia API) #######")
tmp_dnmf = mktempdir()

out_dnmf_beta = dnmf(input=joinpath(tmp, "Data.zst"), dim=3, beta=2, chunksize=100, numepoch=100, logdir=tmp_dnmf)
U, V, stop = out_dnmf_beta

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
writedlm(joinpath(tmp_dnmf, "Zero.csv"), zero_data, ",")
csv2bin(csvfile=joinpath(tmp_dnmf, "Zero.csv"), binfile=joinpath(tmp_dnmf, "Zero.zst"))
@test_throws Exception dnmf(input=joinpath(tmp_dnmf, "Zero.zst"), dim=2, beta=2)

# Negative matrix
negative_data = copy(data)
negative_data[1,1] = - negative_data[1,1]
writedlm(joinpath(tmp_dnmf, "Negative.csv"), negative_data, ",")
@test_throws InexactError csv2bin(csvfile=joinpath(tmp_dnmf, "Negative.csv"), binfile=joinpath(tmp_dnmf, "Negative.zst"))

# Single row data
single_row_data = copy(data)[1, :]'
writedlm(joinpath(tmp_dnmf, "SingleRow.csv"), single_row_data, ",")
csv2bin(csvfile=joinpath(tmp_dnmf, "SingleRow.csv"), binfile=joinpath(tmp_dnmf, "SingleRow.zst"))
@test_throws Exception dnmf(input=joinpath(tmp_dnmf, "SingleRow.zst"), dim=2, beta=2)

# Single column data
single_col_data = copy(data)[:, 1]
writedlm(joinpath(tmp_dnmf, "SingleCol.csv"), single_col_data, ",")
csv2bin(csvfile=joinpath(tmp_dnmf, "SingleCol.csv"), binfile=joinpath(tmp_dnmf, "SingleCol.zst"))
@test_throws Exception dnmf(input=joinpath(tmp_dnmf, "SingleCol.zst"), dim=2, beta=2)

# Non-divisible chunk size
out_chunk_odd = dnmf(input=joinpath(tmp, "Data.zst"), dim=3, chunksize=51)
@test size(out_chunk_odd[1]) == (300, 3)
@test size(out_chunk_odd[2]) == (99, 3)
@test size(out_chunk_odd[3]) == ()

# Extreme parameters (negative values should throw)
@test_throws Exception dnmf(input=joinpath(tmp, "Data.zst"), dim=3, binu=-1, chunksize=100)
@test_throws Exception dnmf(input=joinpath(tmp, "Data.zst"), dim=3, binv=-1, chunksize=100)
@test_throws Exception dnmf(input=joinpath(tmp, "Data.zst"), dim=3, teru=-1, chunksize=100)
@test_throws Exception dnmf(input=joinpath(tmp, "Data.zst"), dim=3, terv=-1, chunksize=100)
@test_throws Exception dnmf(input=joinpath(tmp, "Data.zst"), dim=3, graphv=-1, chunksize=100)
@test_throws Exception dnmf(input=joinpath(tmp, "Data.zst"), dim=3, l1u=-1, chunksize=100)
@test_throws Exception dnmf(input=joinpath(tmp, "Data.zst"), dim=3, l1v=-1, chunksize=100)
@test_throws Exception dnmf(input=joinpath(tmp, "Data.zst"), dim=3, l2u=-1, chunksize=100)
@test_throws Exception dnmf(input=joinpath(tmp, "Data.zst"), dim=3, l2v=-1, chunksize=100)
@test_throws Exception dnmf(input=joinpath(tmp, "Data.zst"), dim=-1, chunksize=100)
@test_throws Exception dnmf(input=joinpath(tmp, "Data.zst"), dim=100, chunksize=100)
@test_throws Exception dnmf(input=joinpath(tmp, "Data.zst"), dim=3, numepoch=-1, chunksize=100)
@test_throws Exception dnmf(input=joinpath(tmp, "Data.zst"), dim=3, chunksize=-1)

# Error handling test
@test_throws SystemError dnmf(input="nonexistent_file.zst", dim=3)
#####################################


#####################################
println("####### DNMF (Command line) #######")
run(`$(julia) $(joinpath(bindir, "dnmf")) --input $(joinpath(tmp, "Data.zst")) --outdir $(tmp) --dim 3 --beta 2 --logdir $(tmp) --chunksize 100`)

testfilesize(true,
	joinpath(tmp, "U.csv"),
	joinpath(tmp, "V.csv"),
	joinpath(tmp, "RecError.csv"))
#####################################