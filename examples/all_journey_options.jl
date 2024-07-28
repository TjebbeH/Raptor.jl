using Distributed
addprocs(4)
@show nworkers()

@everywhere using Raptor

using Dates

gtfs_dir = joinpath([@__DIR__, "..", "data", "gtfs", "gtfs_nl_2024_07_01"])
date = Date(2024, 7, 1)
timetable = create_raptor_timetable(gtfs_dir, date);
save_timetable(timetable)

# date = Date(2024, 7, 1)
# timetable = load_timetable();

maximum_transfers = 5
journeys = @time calculate_all_journeys(timetable, date, maximum_transfers);
