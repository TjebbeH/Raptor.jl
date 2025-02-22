using Raptor
using Dates

gtfs_dir = joinpath([@__DIR__, "..", "data", "gtfs", "gtfs_nl_2024_07_01"])
date = Date(2024, 7, 1)
timetable = create_raptor_timetable(gtfs_dir, date);
save_timetable(timetable)

# date = Date(2024, 7, 1)
# timetable = load_timetable();

# Create range query
origin = "VS"
departure_time_min = date + Time(9)
departure_time_max = date + Time(15)

range_query = RangeMcRaptorQuery(origin, departure_time_min, departure_time_max, timetable);

# Run mcraptor
journeys = run_mc_raptor_and_construct_journeys(timetable, range_query);

# Convert result to dataframes
df_legs = journey_leg_dataframe(journeys);
df_journeys = journey_dataframe(journeys);

# Filter journeys to specific destination
destination ="AKM";
df_journeys_to_dest = filter(:destination => ==(destination), df_journeys);

# Check legs of first journey
journey_hash = first(df_journeys_to_dest.journey_hash);
legs_of_first_journey = filter(:journey_hash => ==(journey_hash), df_legs);

# print Journeys and the legs of the first journey option
println(df_journeys_to_dest)
println(legs_of_first_journey)