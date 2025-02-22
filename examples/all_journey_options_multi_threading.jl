using Raptor
import Raptor:calculate_all_journeys_mt
using Dates

Threads.nthreads()

# gtfs_dir = joinpath([@__DIR__, "..", "data", "gtfs", "gtfs_nl_2024_07_01"])
# date = Date(2024, 7, 1)
# timetable = create_raptor_timetable(gtfs_dir, date);
# save_timetable(timetable)

# Broadcast package and timetable to all workers
timetable = load_timetable();

date = Date(2024, 7, 1);
maximum_transfers = 2;
df_journeys = @time calculate_all_journeys_mt(timetable, date, maximum_transfers);

first(df_journeys,10)

using Parquet2
Parquet2.writefile("output/journey_legs.parquet", df_journeys)
