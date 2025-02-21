using Distributed
addprocs(8)
@show nworkers()


# using Raptor
# gtfs_dir = joinpath([@__DIR__, "..", "data", "gtfs", "gtfs_nl_2024_07_01"])
# date = Date(2024, 7, 1)
# timetable = create_raptor_timetable(gtfs_dir, date);
# save_timetable(timetable)

@everywhere begin
    using Raptor
    using Dates
    using Parquet2
    using DataFrames
    
    date = Date(2024, 7, 1)
    timetable = load_timetable();
    maximum_transfers = 3;
    
    # using Logging
    # warn_logger = ConsoleLogger(stderr, Logging.Warn)
    # global_logger(warn_logger)
end

# using BenchmarkTools
journeys = @time calculate_all_journeys(timetable, date, maximum_transfers);

Parquet2.writefile("output/journey_legs.parquet", journeys)
