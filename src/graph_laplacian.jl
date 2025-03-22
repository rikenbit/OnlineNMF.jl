"""
    graph_laplacian(A::AbstractArray, norm::Bool=true)

    Graph Laplacian (L = D - A, where D is a degree matrix and A is an adjacent matrix).

Input Arguments
---------
- `A` : A symmetric numerical matrix.
- `norm` : Whether to normalize the graph Laplacian or not.

Output Arguments
---------
- Graph Laplacian Matrix (No. rows/columns of A × No. rows/columns of A)
"""
function graph_laplacian(A::AbstractArray, norm::Bool=true)
    if check_symmetric(A)
        if norm
            D = Diagonal(sum(A, dims=1)[:])
            return D^(-0.5) * A * D^(-0.5)
        else
            D = Diagonal(sum(A, dims=1)[:])
            return D - A
        end
    else
        error("The adjacency matrix must be symmetric")
    end
end

check_symmetric(A::AbstractArray) = isapprox(A, A', atol=1e-8)
