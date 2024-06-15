using Test, SafeTestsets
import Logging: Warn, ConsoleLogger, with_logger

with_logger(ConsoleLogger(stderr, Warn)) do
    @safetestset "Aqua quality assurance test" begin
        include("./aqua.jl")
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
    @safetestset "Mcraptor functions" begin
        include("./raptor_algorithm/test_pareto.jl")
    end
    @safetestset "Raptor toy problem" begin
        include("./raptor_algorithm/test_run_mcraptor.jl")
    end
end
