using Raptor
using Dates
using Logging
using Test
using JET

# include("../create_test_timetable.jl")
timetable = create_test_timetable();
today = Date(2021, 10, 21)

origin = "S2"
departure_time_min = today + Time(8);
departure_time_max = today + Time(20);

range_query = RangeMcRaptorQuery(origin, departure_time_min, departure_time_max, timetable);
journeys = run_mc_raptor_and_construct_journeys(timetable, range_query);

@test length(journeys["S4"]) == 3
@test length(journeys["S7"]) == 2

@testset "type-stabilities (JET)" begin
    @test_opt target_modules = (@__MODULE__,) run_mc_raptor_and_construct_journeys(
        timetable, range_query
    )
end
@testset "code calls (JET)" begin
    @test_call target_modules = (@__MODULE__,) run_mc_raptor_and_construct_journeys(
        timetable, range_query
    )
end
