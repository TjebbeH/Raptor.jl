using Raptor
using Dates
using Logging
using Test
import Raptor: is_transfer
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

# include("../create_test_timetable2.jl")
timetable = create_test_timetable2();
today = Date(2021, 10, 21)

origin = "HT"
departure_time_min = today + Time(9, 0);
departure_time_max = today + Time(20);

range_query = RangeMcRaptorQuery(origin, departure_time_min, departure_time_max, timetable);
journeys = run_mc_raptor_and_construct_journeys(timetable, range_query);

# We expect two possible journeys from HT to AC:
# One with an earlier departure time but only 1 transfer in ASA
# One with a later departure time and 2 transfers, arriving at the same time as the other journey
print(journeys["AC"])
@test length(journeys["AC"]) == 2

# Because departure times are sorted reversly, the last found journey is the one that departs the earliest
earliest_journey = journeys["AC"][end]
@test length(earliest_journey.legs) == 3
@test [leg.trip.name for leg in earliest_journey.legs if !is_transfer(leg)] == ["101", "201"]
@test earliest_journey.legs[end].to_label.number_of_trips == 2
