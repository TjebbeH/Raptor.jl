using Raptor
using Dates
using Logging
using Test

import Raptor: last_legs

include("../create_test_timetable.jl")
timetable = create_test_timetable();
today = Date(2021, 10, 21)

origin = "S2"
departure_time = today + Time(13, 15);

query = McRaptorQuery(origin, departure_time, timetable);

bag_round_stop, last_round = run_mc_raptor(timetable, query);
bag_last_round = bag_round_stop[last_round];

# Test if last legs are correctly reconstructed
destination = timetable.stations["S4"];
journeys_with_last_legs = last_legs(destination, bag_last_round);
@test length(journeys_with_last_legs) == 3

# Again with only 0 transfers
query = McRaptorQuery(origin, departure_time, timetable, 0);
bag_round_stop, last_round = run_mc_raptor(timetable, query);
bag_last_round = bag_round_stop[last_round];

destination = timetable.stations["S4"];
journeys_with_last_legs = last_legs(destination, bag_last_round);
@test length(journeys_with_last_legs) == 2

# Test if jouney leg dataframe is correctly constructed
range_query = RangeMcRaptorQuery(origin, today + Time(0), today + Time(23, 59), timetable);
journeys = run_mc_raptor_and_construct_journeys(timetable, range_query);

journey_df = journey_leg_dataframe(journeys["S4"])
@test nrow(journey_df) == 5 # 3 journeys where 2 have 1 leg and 1 has 2 legs with 1 transfer
@test length(unique(journey_df[!, "journey_hash"])) == 3
@test Set(unique(journey_df[!, "fare"])) == Set([0.0, 7.0])
@test Set(unique(journey_df[!, "mode"])) == Set(["train", "foot"])
