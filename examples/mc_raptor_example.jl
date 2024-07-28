using Raptor

using Dates

gtfs_dir = joinpath([@__DIR__, "..", "data","gtfs", "gtfs_nl_2024_07_01"])
date = Date(2024,7,1)
timetable = create_raptor_timetable(gtfs_dir, date);
save_timetable(timetable)

# date = Date(2024, 7, 1)
# timetable = load_timetable();

origin = "VS"
destination = "GN"
departure_time = date + Time(13);

query = McRaptorQuery(origin, departure_time, timetable);

bag_round_stop, last_round = run_mc_raptor(timetable, query);
journeys = reconstruct_journeys_to_all_destinations(
    query.origin, timetable, bag_round_stop, last_round
);

destination_station = try_to_get_station(destination, timetable)
println(journeys[destination_station])
