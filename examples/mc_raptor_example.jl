using Pkg
Pkg.activate(".")
Pkg.instantiate()

using Raptor

using Revise
using Dates

import Raptor: create_raptor_timetable
import Raptor: save_timetable

# gtfs_dir = joinpath([@__DIR__, "..", "src","gtfs","data","gtfs_nl_2024_05_20"])
# date = Date(2024,5,20)

# gtfs_dir = joinpath([@__DIR__, "..", "src","gtfs","data","gtfs_nl_2024_06_19"])
# date = Date(2024,6,19)
# timetable = create_raptor_timetable(gtfs_dir,date);
# save_timetable(timetable)

import Raptor: load_timetable
# date = Date(2024, 5, 20)
date = Date(2024,6,19)
timetable = load_timetable();

origin = "VS"
destination = "AKM"
departure_time = date + Time(9);

# using BenchmarkTools
# using Logging
query = McRaptorQuery(origin, departure_time, timetable);
@time bag_round_stop, last_round = run_mc_raptor(timetable, query);
@time journeys = reconstruct_journeys_to_all_destinations(query.origin, timetable, bag_round_stop, last_round);
destination_station = try_to_get_station(destination, timetable)
display_journeys(journeys[destination_station])