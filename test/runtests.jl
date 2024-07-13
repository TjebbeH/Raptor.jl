using Test
import Logging: Warn, ConsoleLogger, with_logger

@testset "Tests" verbose = true begin
    with_logger(ConsoleLogger(stderr, Warn)) do
        include("./create_test_timetable.jl")

        @testset "Aqua quality assurance test" verbose = true begin
            include("./aqua.jl")
        end
        @testset "Timetable creation" verbose = true begin
            include("./raptor_timetable/test_timetable_creation.jl")
        end
        @testset "Timetable functions" verbose = true begin
            include("./raptor_timetable/test_timetable_functions.jl")
        end
        @testset "Gtfs Timetable" verbose = true begin
            include("./gtfs/test_gtfs_parse.jl")
        end
        @testset "Mcraptor functions" verbose = true begin
            include("./raptor_algorithm/test_pareto.jl")
        end
        @testset "McRaptor toy problem" verbose = true begin
            include("./raptor_algorithm/test_run_mcraptor.jl")
        end
        @testset "Range McRaptor toy problem" verbose = true begin
            include("./raptor_algorithm/test_run_range_mcraptor.jl")
        end
    end
end
