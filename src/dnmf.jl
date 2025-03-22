"""
    dnmf(;input::AbstractString="", outdir::Union{Nothing,AbstractString}=nothing, beta::Number=2, binu::Number=eps(Float32), binv::Number=eps(Float32), teru::Number=eps(Float32), terv::Number=eps(Float32), graphv::Number=0, l1u::Number=eps(Float32), l1v::Number=eps(Float32), l2u::Number=eps(Float32), l2v::Number=eps(Float32), dim::Number=3, numepoch::Number=5, chunksize::Number=1, lower::Number=0, upper::Number=1.0f+38, initU::Union{Nothing,AbstractString}=nothing, initV::Union{Nothing,AbstractString}=nothing, initL::Union{Nothing,AbstractString}=nothing, logdir::Union{Nothing,AbstractString}=nothing)

    Discretized Non-negative Matrix Factorization (DNMF).

Input Arguments
---------
- `input` : Julia Binary file generated by `OnlinePCA.mm2bin` function.
- `outdir` : The directory user want to save the result.
- `beta` : The parameter of Beta-divergence.
- `binu` : Binary {0,1} regularization parameter for the factor matrix U.
- `binv` : Binary {0,1} regularization parameter for the factor matrix V.
- `teru` : Ternary {0,1,2} regularization parameter for the factor matrix U.
- `terv` : Ternary {0,1,2} regularization parameter for the factor matrix V.
- `graphv` : Graph regularization parameter for the factor matrix V.
- `l1u` : L1-regularization parameter for the factor matrix U.
- `l1v` : L1-regularization parameter for the factor matrix V.
- `l2u` : L2-regularization parameter for the factor matrix U.
- `l2v` : L2-regularization parameter for the factor matrix V.
- `dim` : The number of dimension of NMF.
- `numepoch` : The number of epochs.
- `chunksize: The number of rows reading at once (e.g. 5000).
- `lower` : Stopping Criteria (When the relative change of error is below this value, the calculation is terminated)
- `upper` : Stopping Criteria (When the relative change of error is above this value, the calculation is terminated)
- `initU` : The CSV file saving the initial values of factor matrix U.
- `initV` : The CSV file saving the initial values of factor matrix V.
- `initL` : The CSV file saving the initial values of graph laplacian L.
- `logdir` : The directory where intermediate files are saved, in every epoch.

Output Arguments
---------
- `U` : Factor matrix (No. rows of the data matrix × dim)
- `V` : Factor matrix (No. columns of the data matrix × dim)
- stop : Whether the calculation is converged
"""
function dnmf(;
    input::AbstractString="",
    outdir::Union{Nothing,AbstractString}=nothing,
    beta::Number=2,
    binu::Number=eps(Float32),
    binv::Number=eps(Float32),
    graphv::Number=0,
    teru::Number=eps(Float32),
    terv::Number=eps(Float32),
    l1u::Number=eps(Float32),
    l1v::Number=eps(Float32),
    l2u::Number=eps(Float32),
    l2v::Number=eps(Float32),
    dim::Number=3,
    numepoch::Number=5,
    chunksize::Number=1,
    lower::Number=0,
    upper::Number=1.0f+38,
    initU::Union{Nothing,AbstractString}=nothing,
    initV::Union{Nothing,AbstractString}=nothing,
    initL::Union{Nothing,AbstractString}=nothing,
    logdir::Union{Nothing,AbstractString}=nothing,
)
    # Initialization of NMF
    nmfmodel = DNMF()
    beta,
    binu,
    binv,
    teru,
    terv,
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
    logdir,
    lower,
    upper = init_dnmf(
        input,
        outdir,
        beta,
        binu,
        binv,
        teru,
        terv,
        graphv,
        l1u,
        l1v,
        l2u,
        l2v,
        dim,
        numepoch,
        chunksize,
        initU,
        initV,
        initL,
        logdir,
        lower,
        upper
    )
    # Perform DNMF
    out = each_dnmf(
        input,
        beta,
        binu,
        binv,
        teru,
        terv,
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

function each_dnmf(
    input,
    beta,
    binu,
    binv,
    teru,
    terv,
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
        U = update_dU(input, N, M, U, V, beta, binu, teru, l1u, l2u, chunksize)
        # NaN
        checkNaN(U)
        # Update V
        V = update_dV(input, N, M, U, V, L, beta, binv, terv, graphv, l1v, l2v, chunksize)
        # NaN
        checkNaN(V)
        # save log file
        if logdir isa String
            stop = outputlog(s, input, logdir, U, V, lower, upper, nmfmodel, chunksize)
        end
        s += 1
    end
    # Return
    return U, V, stop
end

# Update U (Beta-divergence)
function update_dU(input, N, M, U, V, beta, binu, teru, l1u, l2u, chunksize)
    numer = update_dU_numer_BETA(input, N, M, U, V, beta, binu, teru, chunksize)
    denom = update_dU_denom_BETA(N, U, V, beta, binu, teru, l1u, l2u, chunksize)
    update_factor = ifelse.(denom .== 0, 1.0, (numer ./ denom) .^ rho(beta))
    U .* update_factor
end

function update_dU_numer_BETA(input, N, M, U, V, beta, binu, teru, chunksize)
    tmpN = zeros(UInt32, 1)
    tmpM = zeros(UInt32, 1)
    numer = zeros(size(U))
    open(input, "r") do file
        stream = ZstdDecompressorStream(file)
        read!(stream, tmpN)
        read!(stream, tmpM)
        n = 1
        while n <= N
            batch_size = min(chunksize, N - n + 1)
            buffer = zeros(UInt32, batch_size * M)
            read!(stream, buffer)
            X_chunk = permutedims(reshape(buffer, M, batch_size))
            U_chunk = @view U[n:n+batch_size-1, :]
            @turbo numer[n:n+batch_size-1, :] =
                (((U_chunk * V') .^ (beta - 2)) .* X_chunk) * V +
                3 * binu .* (U_chunk .^ 2) +
                teru .* (30 .* U_chunk .^ 4 .+ 36 .* U_chunk .^ 2)
            n += batch_size
        end
        close(stream)
    end
    return numer
end

function update_dU_denom_BETA(N, U, V, beta, binu, teru, l1u, l2u, chunksize)
    denom = zeros(size(U))
    n = 1
    while n <= N
        batch_size = min(chunksize, N - n + 1)
        U_chunk = @view U[n:n+batch_size-1, :]
        @turbo denom[n:n+batch_size-1, :] =
            ((U_chunk * V') .^ (beta - 1)) * V .+ l1u +
            l2u .* U_chunk +
            binu .* (2 .* U_chunk .^ 3 .+ U_chunk) +
            teru .* (6 .* U_chunk .^ 5 .+ 52 .* U_chunk .^ 3 .+ 8 .* U_chunk)
        n += batch_size
    end
    return denom
end

# Update V (Beta-divergence)
function update_dV(input, N, M, U, V, L, beta, binv, terv, graphv, l1v, l2v, chunksize)
    numer = update_dV_numer_BETA(input, N, M, U, V, beta, binv, terv, chunksize)
    denom = update_dV_denom_BETA(N, U, V, L, beta, binv, terv, graphv, l1v, l2v, chunksize)
    update_factor = ifelse.(denom .== 0, 1.0, (numer ./ denom) .^ rho(beta))
    V .* update_factor
end

function update_dV_numer_BETA(input, N, M, U, V, beta, binv, terv, chunksize)
    tmpN = zeros(UInt32, 1)
    tmpM = zeros(UInt32, 1)
    numer = zeros(size(V))
    open(input, "r") do file
        stream = ZstdDecompressorStream(file)
        read!(stream, tmpN)
        read!(stream, tmpM)
        n = 1
        while n <= N
            batch_size = min(chunksize, N - n + 1)
            buffer = zeros(UInt32, batch_size * M)
            read!(stream, buffer)
            X_chunk = permutedims(reshape(buffer, M, batch_size))
            U_chunk = @view U[n:n+batch_size-1, :]
            @turbo numer .+=
                ((U_chunk * V') .^ (beta - 2) .* X_chunk)' * U_chunk +
                3 * binv .* (V .^ 2) +
                terv .* (30 .* V .^ 4 .+ 36 .* V .^ 2)
            n += batch_size
        end
        close(stream)
    end
    return numer
end

function update_dV_denom_BETA(N, U, V, L, beta, binv, terv, graphv, l1v, l2v, chunksize)
    denom = zeros(size(V))
    n = 1
    while n <= N
        batch_size = min(chunksize, N - n + 1)
        U_chunk = @view U[n:n+batch_size-1, :]
        @turbo denom .+=
            ((U_chunk * V') .^ (beta - 1))' * U_chunk .+ l1v +
            l2v .* V +
            binv .* (2 .* V .^ 3 .+ V) +
            terv .* (6 .* V .^ 5 .+ 52 .* V .^ 3 .+ 8 .* V) +
            graphv .* (L * V)
        n += batch_size
    end
    return denom
end

# Initialization step in DNMF
function init_dnmf(
    input::AbstractString,
    outdir::Union{Nothing,AbstractString},
    beta::Number,
    binu::Number,
    binv::Number,
    teru::Number,
    terv::Number,
    graphv::Number,
    l1u::Number,
    l1v::Number,
    l2u::Number,
    l2v::Number,
    dim::Number,
    numepoch::Number,
    chunksize::Number,
    initU::Union{Nothing,AbstractString},
    initV::Union{Nothing,AbstractString},
    initL::Union{Nothing,AbstractString},
    logdir::Union{Nothing,AbstractString},
    lower::Number,
    upper::Number
)
    # Type Check
    N, M = nm(input)
    binu = convert(Float32, binu)
    binv = convert(Float32, binv)
    teru = convert(Float32, teru)
    terv = convert(Float32, terv)
    graphv = convert(Float32, graphv)
    # Initialization by NMF
    out_nmf = nmf(
        input=input,
        outdir=outdir,
        alpha=1,
        beta=beta,
        l1u=l1u,
        l1v=l1v,
        l2u=l2u,
        l2v=l2v,
        dim=dim,
        numepoch=numepoch,
        chunksize=chunksize,
        algorithm="beta",
        lower=lower,
        upper=upper,
        initU=initU,
        initV=initV,
        logdir=logdir,
    )
    U = out_nmf[1]
    V = out_nmf[2]
    # Normalization
    Du = Diagonal(vec(maximum(U, dims=1)))
    Dv = Diagonal(vec(maximum(V, dims=1)))
    U = U * Diagonal(1.0 ./ sqrt.(Du.diag)) * sqrt(Dv)
    V = V * Diagonal(1.0 ./ sqrt.(Dv.diag)) * sqrt(Du)
    # Initialization of L
    L = load_or_zero(initL, M)
    return beta,
    binu,
    binv,
    teru,
    terv,
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
    logdir,
    lower,
    upper
end
