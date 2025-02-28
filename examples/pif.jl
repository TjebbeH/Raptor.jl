using Random
Random.seed!(2025)
N = 10
k = 2

Y = rand(Float64, (N,k))

function maximal_elements_2d(Y)
    @show N = size(Y,1)
    if N == 1
        @show N
        return [Y]
    end
    
    half_N = cld(N,2)

    A = Y[1:half_N, :]
    B = Y[half_N+1:N, :]

    @show A_maxs = maximal_elements_2d(A)
    @show B_maxs = maximal_elements_2d(B)

    if length(B_maxs) == 1
        y_max_B_maxs = B_maxs[1][2]
    else
        y_max_B_maxs = maximum(B_maxs[:,2])
    end

    if length(A_maxs) == 1
        if A_maxs[1][2] > y_max_B_maxs
            B_maxs = B_maxs ; A_maxs[1]
        end
    else
        for a_max in A_maxs
            if a_max[2] > y_max_B_maxs
                B_maxs = B_maxs ; a_max[2]
            end
        end
    end
    return B_maxs
end

maximal_elements_2d(Y)
Y