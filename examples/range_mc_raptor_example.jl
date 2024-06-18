using Revise

using Raptor
using Dates

import Raptor: create_raptor_timetable
import Raptor: save_timetable
gtfs_dir = joinpath([@__DIR__, "..", "src","gtfs","data","gtfs_nl_2024_05_20"])
date = Date(2024,5,20)
timetable = create_raptor_timetable(gtfs_dir,date);
save_timetable(timetable)

import Raptor: load_timetable
date = Date(2024, 5, 20)
timetable = load_timetable();

origin = "VS"
destination = "AKM"
departure_time_min = DateTime(2024, 5, 20, 0, 0, 0);
departure_time_max = DateTime(2024, 5, 21, 0, 0, 0);

# using BenchmarkTools
# using Logging
range_query = RangeMcRaptorQuery(origin, departure_time_min, departure_time_max, timetable);
@time bag_round_stop, last_round = run_mc_raptor(timetable, range_query);
@time journeys = reconstruct_journies_to_all_destinations(query.origin, timetable, bag_round_stop, last_round);
destination_station = try_to_get_station(destination, timetable)
display_journeys(journeys[destination_station])



station = range_query.origin
routes = unique(Iterators.flatten([keys(timetable.stop_routes_lookup[s]) for s in station.stops]))
trips = Iterators.flatten([
        timetable.route_trip_lookup[r] 
        for r in routes
])
stoptimes = [t.stop_times

