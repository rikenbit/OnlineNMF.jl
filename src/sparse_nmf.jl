"""
    sparse_nmf(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, alpha::Number=1, beta::Number=2, graphv::Number=0, l1u::Number=eps(Float32), l1v::Number=eps(Float32), l2u::Number=eps(Float32), l2v::Number=eps(Float32), dim::Number=3, numepoch::Number=5, chunksize::Number=1, algorithm::AbstractString="frobenius", lower::Number=0, upper::Number=1.0f+38, initU::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, initL::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing)

    Sparse Non-negative Matrix Factorization (SNMF).

Input Arguments
---------
- `input` : Julia Binary file generated by `OnlinePCA.mm2bin` function.
- `outdir` : The directory user want to save the result.
- `alpha` : The parameter of Alpha-divergence.
- `beta` : The parameter of Beta-divergence.
- `graphv` : Graph regularization parameter for the factor matrix V.
- `l1u` : L1-regularization parameter for the factor matrix U.
- `l1v` : L1-regularization parameter for the factor matrix V.
- `l2u` : L2-regularization parameter for the factor matrix U.
- `l2v` : L2-regularization parameter for the factor matrix V.
- `dim` : The number of dimension of NMF.
- `numepoch` : The number of epochs.
- `chunksize: The number of rows reading at once (e.g. 5000).
- `algorithm`: Update Algorithm. `frobenius`, `kl`, `is`, `pearson`, `hellinger`, `neyman`, `alpha`, and `beta` are available.
- `lower` : Stopping Criteria (When the relative change of error is below this value, the calculation is terminated).
- `upper` : Stopping Criteria (When the relative change of error is above this value, the calculation is terminated).
- `initU` : The CSV file saving the initial values of factor matrix U.
- `initV` : The CSV file saving the initial values of factor matrix V.
- `initL` : The CSV file saving the initial values of graph laplacian L.
- `logdir` : The directory where intermediate files are saved in every epoch.

Output Arguments
---------
- `U` : Factor matrix (No. rows of the data matrix × dim)
- `V` : Factor matrix (No. columns of the data matrix × dim)
- stop : Whether the calculation is converged
"""
function sparse_nmf(;
    input::AbstractString="",
    outdir::Union{Nothing,AbstractString}=nothing,
    alpha::Number=1,
    beta::Number=2,
    graphv::Number=0,
    l1u::Number=eps(Float32),
    l1v::Number=eps(Float32),
    l2u::Number=eps(Float32),
    l2v::Number=eps(Float32),
    dim::Number=3,
    numepoch::Number=5,
    chunksize::Number=1,
    algorithm::AbstractString="frobenius",
    lower::Number=0,
    upper::Number=1.0f+38,
    initU::Union{Nothing,AbstractString}=nothing,
    initV::Union{Nothing,AbstractString}=nothing,
    initL::Union{Nothing,AbstractString}=nothing,
    logdir::Union{Nothing,AbstractString}=nothing,
)
    # Initial Setting
    nmfmodel = SPARSE_NMF()
    alpha,
    beta,
    graphv,
    l1u,
    l1v,
    l2u,
    l2v,
    U,
    V,
    L,
    N,
    M,
    numepoch,
    chunksize,
    algorithm,
    logdir,
    lower,
    upper = init_sparse_nmf(
        input,
        alpha,
        beta,
        graphv,
        l1u,
        l1v,
        l2u,
        l2v,
        dim,
        numepoch,
        chunksize,
        algorithm,
        initU,
        initV,
        initL,
        logdir,
        lower,
        upper
    )
    # Perform NMF
    out = each_sparse_nmf(
        input,
        alpha,
        beta,
        graphv,
        l1u,
        l1v,
        l2u,
        l2v,
        U,
        V,
        L,
        N,
        M,
        numepoch,
        chunksize,
        algorithm,
        logdir,
        lower,
        upper,
        nmfmodel,
    )
    if outdir isa String
        mkpath(outdir)
        output(outdir, out, lower)
    end
    return out
end

function each_sparse_nmf(
    input,
    alpha,
    beta,
    graphv,
    l1u,
    l1v,
    l2u,
    l2v,
    U,
    V,
    L,
    N,
    M,
    numepoch,
    chunksize,
    algorithm,
    logdir,
    lower,
    upper,
    nmfmodel,
)
    # If not 0 the calculation is converged
    stop = 0
    s = 1
    # Each epoch s
    progress = Progress(numepoch)
    while (stop == 0 && s <= numepoch)
        next!(progress)
        # Update U
        U = update_spU(input, N, M, U, V, alpha, beta, l1u, l2u, chunksize, algorithm)
        # NaN
        checkNaN(U)
        # Update V
        V = update_spV(
            input,
            N,
            M,
            U,
            V,
            L,
            alpha,
            beta,
            graphv,
            l1v,
            l2v,
            chunksize,
            algorithm,
        )
        # NaN
        checkNaN(V)
        # Normalization
        norm = sum(U, dims=1)
        U = U ./ norm
        V = V .* norm
        # save log file
        if logdir isa String
            stop = outputlog(s, input, logdir, U, V, lower, upper, nmfmodel, chunksize)
        end
        s += 1
    end
    # Return
    return U, V, stop
end

# Update U (Alpha-divergence)
function update_spU(input, N, M, U, V, alpha, beta, l1u, l2u, chunksize, algorithm::ALPHA)
    numer = update_spU_numer_ALPHA(input, N, M, U, V, alpha, chunksize)
    denom = update_U_denom_ALPHA(N, V)
    update_factor = ifelse.(denom .== 0, 1.0, (numer ./ denom) .^ (1 / alpha))
    U .* update_factor
end

function update_spU_numer_ALPHA(input, N, M, U, V, alpha, chunksize)
    numer = zeros(size(U))
    open(input, "r") do file
        stream = ZstdDecompressorStream(file)
        tmpN = zeros(UInt32, 1)
        tmpM = zeros(UInt32, 1)
        read!(stream, tmpN)
        read!(stream, tmpM)
        overflow_buf = UInt32[]
        n = 1
        while n <= N
            batch_size = min(chunksize, N - n + 1)
            max_size = (batch_size + 1) * M # For overflow
            rows = zeros(UInt32, max_size)
            cols = zeros(UInt32, max_size)
            vals = zeros(UInt32, max_size)
            count = 0
            ############### Overflow buffer ###############
            if length(overflow_buf) > 0
                count += 1
                # Re-mapping row index
                rows[count] = overflow_buf[1] - n + 1
                cols[count] = overflow_buf[2]
                vals[count] = overflow_buf[3]
                empty!(overflow_buf)
            end
            ###############################################
            while !eof(stream)
                buf = zeros(UInt32, 3)
                read!(stream, buf)
                row, col, val = buf[1], buf[2], buf[3]
                if n ≤ row < n + batch_size
                    count += 1
                    # Re-mapping row index
                    rows[count] = row - n + 1
                    cols[count] = col
                    vals[count] = val
                else
                    overflow_buf = buf
                    break
                end
            end
            # Remove 0s from the end
            resize!(rows, count)
            resize!(cols, count)
            resize!(vals, count)
            if count > 0
                X_chunk = sparse(rows, cols, vals, batch_size, M)
            else
                X_chunk = spzeros(batch_size, M)
            end
            U_chunk = @view U[n:n+batch_size-1, :]
            numer[n:n+batch_size-1, :] = Matrix(((X_chunk ./ (U_chunk * V')) .^ alpha) * V)
            n += batch_size
        end
        close(stream)
    end
    return numer
end

# Update U (Beta-divergence)
function update_spU(input, N, M, U, V, alpha, beta, l1u, l2u, chunksize, algorithm::BETA)
    numer = update_spU_numer_BETA(input, N, M, U, V, beta, chunksize)
    denom = update_U_denom_BETA(N, U, V, beta, l1u, l2u, chunksize)
    update_factor = ifelse.(denom .== 0, 1.0, (numer ./ denom) .^ rho(beta))
    U .* update_factor
end

function update_spU_numer_BETA(input, N, M, U, V, beta, chunksize)
    numer = zeros(size(U))
    open(input, "r") do file
        stream = ZstdDecompressorStream(file)
        tmpN = zeros(UInt32, 1)
        tmpM = zeros(UInt32, 1)
        read!(stream, tmpN)
        read!(stream, tmpM)
        overflow_buf = UInt32[]
        n = 1
        while n <= N
            batch_size = min(chunksize, N - n + 1)
            max_size = (batch_size + 1) * M # For overflow
            rows = zeros(UInt32, max_size)
            cols = zeros(UInt32, max_size)
            vals = zeros(UInt32, max_size)
            count = 0
            ############### Overflow buffer ###############
            if length(overflow_buf) > 0
                count += 1
                # Re-mapping row index
                rows[count] = overflow_buf[1] - n + 1
                cols[count] = overflow_buf[2]
                vals[count] = overflow_buf[3]
                empty!(overflow_buf)
            end
            ###############################################
            while !eof(stream)
                buf = zeros(UInt32, 3)
                read!(stream, buf)
                row, col, val = buf[1], buf[2], buf[3]
                if n ≤ row < n + batch_size
                    count += 1
                    # Re-mapping row index
                    rows[count] = row - n + 1
                    cols[count] = col
                    vals[count] = val
                else
                    overflow_buf = buf
                    break
                end
            end
            # Remove 0s from the end
            resize!(rows, count)
            resize!(cols, count)
            resize!(vals, count)
            if count > 0
                X_chunk = sparse(rows, cols, vals, batch_size, M)
            else
                X_chunk = spzeros(batch_size, M)
            end
            U_chunk = @view U[n:n+batch_size-1, :]
            numer[n:n+batch_size-1, :] =
                Matrix((((U_chunk * V') .^ (beta - 2)) .* X_chunk) * V)
            n += batch_size
        end
        close(stream)
    end
    return numer
end

# Update V (Alpha-divergence)
function update_spV(
    input,
    N,
    M,
    U,
    V,
    L,
    alpha,
    beta,
    graphv,
    l1v,
    l2v,
    chunksize,
    algorithm::ALPHA,
)
    numer = update_spV_numer_ALPHA(input, N, M, U, V, alpha, chunksize)
    denom = update_V_denom_ALPHA(M, U)
    update_factor = ifelse.(denom .== 0, 1.0, (numer ./ denom) .^ (1 / alpha))
    V .* update_factor
end

function update_spV_numer_ALPHA(input, N, M, U, V, alpha, chunksize)
    numer = zeros(size(V))
    open(input, "r") do file
        stream = ZstdDecompressorStream(file)
        tmpN = zeros(UInt32, 1)
        tmpM = zeros(UInt32, 1)
        read!(stream, tmpN)
        read!(stream, tmpM)
        overflow_buf = UInt32[]
        n = 1
        while n <= N
            batch_size = min(chunksize, N - n + 1)
            max_size = (batch_size + 1) * M # For overflow
            rows = zeros(UInt32, max_size)
            cols = zeros(UInt32, max_size)
            vals = zeros(UInt32, max_size)
            count = 0
            ############### Overflow buffer ###############
            if length(overflow_buf) > 0
                count += 1
                # Re-mapping row index
                rows[count] = overflow_buf[1] - n + 1
                cols[count] = overflow_buf[2]
                vals[count] = overflow_buf[3]
                empty!(overflow_buf)
            end
            ###############################################
            while !eof(stream)
                buf = zeros(UInt32, 3)
                read!(stream, buf)
                row, col, val = buf[1], buf[2], buf[3]
                if n ≤ row < n + batch_size
                    count += 1
                    # Re-mapping row index
                    rows[count] = row - n + 1
                    cols[count] = col
                    vals[count] = val
                else
                    overflow_buf = buf
                    break
                end
            end
            # Remove 0s from the end
            resize!(rows, count)
            resize!(cols, count)
            resize!(vals, count)
            if count > 0
                X_chunk = sparse(rows, cols, vals, batch_size, M)
            else
                X_chunk = spzeros(batch_size, M)
            end
            U_chunk = @view U[n:n+batch_size-1, :]
            numer .+= Matrix(((X_chunk ./ (U_chunk * V')) .^ alpha)' * U_chunk)
            n += batch_size
        end
        close(stream)
    end
    return numer
end

# Update V (Beta-divergence)
function update_spV(
    input,
    N,
    M,
    U,
    V,
    L,
    alpha,
    beta,
    graphv,
    l1v,
    l2v,
    chunksize,
    algorithm::BETA,
)
    numer = update_spV_numer_BETA(input, N, M, U, V, beta, chunksize)
    denom = update_V_denom_BETA(N, U, V, L, beta, graphv, l1v, l2v, chunksize)
    update_factor = ifelse.(denom .== 0, 1.0, (numer ./ denom) .^ rho(beta))
    V .* update_factor
end

function update_spV_numer_BETA(input, N, M, U, V, beta, chunksize)
    numer = zeros(size(V))
    open(input, "r") do file
        stream = ZstdDecompressorStream(file)
        tmpN = zeros(UInt32, 1)
        tmpM = zeros(UInt32, 1)
        read!(stream, tmpN)
        read!(stream, tmpM)
        overflow_buf = UInt32[]
        n = 1
        while n <= N
            batch_size = min(chunksize, N - n + 1)
            max_size = (batch_size + 1) * M # For overflow
            rows = zeros(UInt32, max_size)
            cols = zeros(UInt32, max_size)
            vals = zeros(UInt32, max_size)
            count = 0
            ############### Overflow buffer ###############
            if length(overflow_buf) > 0
                count += 1
                # Re-mapping row index
                rows[count] = overflow_buf[1] - n + 1
                cols[count] = overflow_buf[2]
                vals[count] = overflow_buf[3]
                empty!(overflow_buf)
            end
            ###############################################
            while !eof(stream)
                buf = zeros(UInt32, 3)
                read!(stream, buf)
                row, col, val = buf[1], buf[2], buf[3]
                if n ≤ row < n + batch_size
                    count += 1
                    # Re-mapping row index
                    rows[count] = row - n + 1
                    cols[count] = col
                    vals[count] = val
                else
                    overflow_buf = buf
                    break
                end
            end
            # Remove 0s from the end
            resize!(rows, count)
            resize!(cols, count)
            resize!(vals, count)
            if count > 0
                X_chunk = sparse(rows, cols, vals, batch_size, M)
            else
                X_chunk = spzeros(batch_size, M)
            end
            U_chunk = @view U[n:n+batch_size-1, :]
            numer .+= Matrix(((U_chunk * V') .^ (beta - 2) .* X_chunk)' * U_chunk)
            n += batch_size
        end
        close(stream)
    end
    return numer
end

# Initialization step in NMF
function init_sparse_nmf(
    input::AbstractString,
    alpha::Number,
    beta::Number,
    graphv::Number,
    l1u::Number,
    l1v::Number,
    l2u::Number,
    l2v::Number,
    dim::Number,
    numepoch::Number,
    chunksize::Number,
    algorithm::AbstractString,
    initU::Union{Nothing,AbstractString},
    initV::Union{Nothing,AbstractString},
    initL::Union{Nothing,AbstractString},
    logdir::Union{Nothing,AbstractString},
    lower::Number,
    upper::Number
)
    # Type Check
    N, M = nm(input)
    alpha = convert(Float32, alpha)
    beta = convert(Float32, beta)
    graphv = convert(Float32, graphv)
    l1u = convert(Float32, l1u)
    l1v = convert(Float32, l1v)
    l2u = convert(Float32, l2u)
    l2v = convert(Float32, l2v)
    dim = convert(Int64, dim)
    numepoch = convert(Int64, numepoch)
    chunksize = convert(Int64, chunksize)
    lower = convert(Float32, lower)
    upper = convert(Float32, upper)
    # Initialization of U and V
    U = load_or_random(initU, N, dim)
    V = load_or_random(initV, M, dim)
    L = load_or_random(initL, M, M, true)
    # Algorithm setting
    algorithm, alpha, beta = select_algorithm(algorithm, alpha, beta)
    # directory setting
    if logdir isa String
        if !isdir(logdir)
            mkpath(logdir)
        end
    end
    return alpha,
    beta,
    graphv,
    l1u,
    l1v,
    l2u,
    l2v,
    U,
    V,
    L,
    N,
    M,
    numepoch,
    chunksize,
    algorithm,
    logdir,
    lower,
    upper
end
