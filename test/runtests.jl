using Test, SafeTestsets
import Logging: Warn, ConsoleLogger, with_logger

with_logger(ConsoleLogger(stderr, Warn)) do
    @safetestset "Mcraptor functions" begin
        include("./raptor_algorithm/raptor_functions/test_pareto.jl")
    end
    @safetestset "Timetable creation" begin
        include("./raptor_timetable/test_timetable_creation.jl")
    end
    @safetestset "Timetable creation" begin
        include("./raptor_timetable/test_timetable_functions.jl")
    end
    @safetestset "Gtfs Timetable" begin
        include("./gtfs/test_gtfs_parse.jl")
    end
end