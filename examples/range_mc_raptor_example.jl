using Raptor
using BenchmarkTools
using Dates

# gtfs_dir = joinpath([@__DIR__, "..", "data", "gtfs", "gtfs_nl_2024_07_01"])
# date = Date(2024, 7, 1)
# timetable = create_raptor_timetable(gtfs_dir, date);
# save_timetable(timetable)

date = Date(2024, 7, 1)
timetable = load_timetable();

origin = "VS"
departure_time_min = date + Time(0)
departure_time_max = date + Time(23,59)

range_query = RangeMcRaptorQuery(origin, departure_time_min, departure_time_max, timetable);

# journeys = @btime run_mc_raptor_and_construct_journeys(timetable, range_query);
journeys2 = @btime run_mc_raptor_and_construct_journeys2(timetable, range_query);

df = journey_leg_dataframe(journeys2);
df2 = journey_dataframe(journeys2);
first(df,10)
first(df2,10)

destination = "AKM"
destination_station = get_station(destination, timetable);
println(journeys[destination_station])

destination = "GN"
destination_station = to_get_station(destination, timetable);
println(journeys[destination_station])
