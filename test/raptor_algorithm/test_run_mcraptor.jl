using Raptor
using Dates
using Logging
using Test

include("../create_test_timetable.jl")
timetable= create_test_timetable();
today = Date(2021,10,21)


origin = "S2"
destination = "S4"
departure_time = today + Time(13, 15);

query = McRaptorQuery(origin, destination, departure_time, timetable);

bag_round_stop, last_round = run_mc_raptor(timetable, query);
options42 = bag_round_stop[last_round][timetable.stops["s42"]].options
@test length(options42) == 3
@test minimum(o.label.arrival_time for o in options42) == today + Time(15,2) # note we walk to platform 2.
@test minimum(o.label.fare for o in options42) == 0.0
@test minimum(o.label.number_of_trips for o in options42) == 1

# journeys = reconstruct_journeys(query, bag_round_stop, last_round);
# display_journeys(journeys)