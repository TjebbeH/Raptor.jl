using Test, SafeTestsets


@time begin
    @time @safetestset "Mcraptor functions" begin
        include("./mcraptor/test_raptor_functions.jl")
    end
end
