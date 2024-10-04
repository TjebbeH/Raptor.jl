using Revise
using Raptor

using Dates
import Raptor: run_mc_raptor_and_construct_journeys2, journey_dataframe

# gtfs_dir = joinpath([@__DIR__, "..", "data", "gtfs", "gtfs_nl_2024_07_01"])
# date = Date(2024, 7, 1)
# timetable = create_raptor_timetable(gtfs_dir, date);
# save_timetable(timetable)

date = Date(2024, 7, 1)
timetable = load_timetable();

origin = "VS"
departure_time_min = date + Time(9)
departure_time_max = date + Time(15)

range_query = RangeMcRaptorQuery(origin, departure_time_min, departure_time_max, timetable);
using BenchmarkTools
journeys = @btime run_mc_raptor_and_construct_journeys(timetable, range_query);
journeys2 = @btime run_mc_raptor_and_construct_journeys2(timetable, range_query);


df = @btime journey_leg_dataframe(journeys2);
df2 = journey_dataframe(journeys2);
first(df,10)
df2

# destination = "AKM"
# destination_station = try_to_get_station(destination, timetable);
# println(journeys[destination_station])

destination = "GN"
destination_station = try_to_get_station(destination, timetable);
# println(journeys[destination_station])

using BenchmarkTools

journey_leg_dataframe(journeys[destination_station])