using Test, SafeTestsets


@time @safetestset "Mcraptor functions" begin
    include("./raptor_algorithm/raptor_functions/test_pareto.jl")
end
@time @safetestset "Timetable creation" begin
    include("./raptor_timetable/test_timetable_creation.jl")
end
@time @safetestset "Gtfs Timetable" begin
    include("./gtfs/test_gtfs_parse.jl")
end
