using Revise

using Raptor
using Dates

# import Raptor: create_raptor_timetable
# import Raptor: save_timetable
# gtfs_dir = joinpath([@__DIR__, "..", "src","gtfs","data","gtfs_nl_2024_05_20"])
# date = Date(2024,5,20)
# timetable = create_raptor_timetable(gtfs_dir,date);
# save_timetable(timetable)

import Raptor: load_timetable
date = Date(2024, 5, 20)
timetable = load_timetable();

origin = "VS"
destination = "AKM"
departure_time = DateTime(2024, 5, 20, 8, 0, 0);

using BenchmarkTools
using Logging
query = McRaptorQuery(origin, departure_time, timetable);
@time bag_round_stop, last_round = run_mc_raptor(timetable, query);
@time journeys = reconstruct_journies_to_all_destinations(query.origin, timetable, bag_round_stop, last_round);
destination_station = try_to_get_station(destination, timetable)
display_journeys(journeys[destination_station])