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
date = Date(2024, 5, 20)
# date = Date(2024, 6, 19)
timetable = load_timetable();

origin = "ASD"
destination = "AKM"
departure_time = date + Time(13);

using BenchmarkTools
query = McRaptorQuery(origin, departure_time, timetable);

bag_round_stop, last_round = @btime run_mc_raptor(timetable, query);
journeys = @btime reconstruct_journeys_to_all_destinations(
    query.origin, timetable, bag_round_stop, last_round
);

destination_station = try_to_get_station(destination, timetable)
println(journeys[destination_station])
