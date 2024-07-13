using Raptor

using Dates

# import Raptor: create_raptor_timetable
# import Raptor: save_timetable
# gtfs_dir = joinpath([@__DIR__, "..", "src", "gtfs", "data", "gtfs_nl_2024_05_20"])
# date = Date(2024, 5, 20)
# timetable = create_raptor_timetable(gtfs_dir, date);
# save_timetable(timetable)

import Raptor: load_timetable
date = Date(2024, 5, 20)
timetable = load_timetable();

origin = "VS"
departure_time_min = date + Time(8)
departure_time_max = date + Time(10, 59)

using BenchmarkTools

range_query = RangeMcRaptorQuery(origin, departure_time_min, departure_time_max, timetable);
journeys = @time run_mc_raptor_and_construct_journeys(timetable, range_query);

destination = "AKM"
destination_station = try_to_get_station(destination, timetable);
println(journeys[destination_station])

destination = "GN"
destination_station = try_to_get_station(destination, timetable);
println(journeys[destination_station])
