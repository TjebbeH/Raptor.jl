using Raptor
using Dates
using Logging
using Test
using JET

include("../create_test_timetable.jl")
timetable = create_test_timetable();
today = Date(2021, 10, 21)

origin = "S2"
departure_time_min = today + Time(8);
departure_time_max = today + Time(20);

range_query = RangeMcRaptorQuery(origin, departure_time_min, departure_time_max, timetable);
journeys = run_mc_raptor_and_construct_journeys(timetable, range_query);

destination_station_S4 = try_to_get_station("S4", timetable);
@test length(journeys[destination_station_S4]) == 3

destination_station_S7 = try_to_get_station("S7", timetable);
@test length(journeys[destination_station_S7]) == 2

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
