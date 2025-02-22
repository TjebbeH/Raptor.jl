using Distributed
using Dates

addprocs(4)
@show nworkers()

gtfs_dir = joinpath([@__DIR__, "..", "data", "gtfs", "gtfs_nl_2024_07_01"])
date = Date(2024, 7, 1)
timetable = create_raptor_timetable(gtfs_dir, date);
save_timetable(timetable)

# Broadcast package and timetable to all workers
@everywhere begin
    using Raptor

    timetable = load_timetable()
end

date = Date(2024, 7, 1);
maximum_transfers = 3;

journeys = calculate_all_journeys(timetable, date, maximum_transfers);

Parquet2.writefile("output/journey_legs.parquet", journeys)
