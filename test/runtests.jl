using Test, SafeTestsets


@time begin
    @time @safetestset "Mcraptor functions" begin
        include("./raptor_algorithm/raptor_functions/test_pareto.jl")
    end
    @time @safetestset "Timetable functions" begin
        include("./raptor_timetable/test_timetable_functions.jl")
    end
end
