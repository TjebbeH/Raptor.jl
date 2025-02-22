using Raptor

using Dates

gtfs_dir = joinpath([@__DIR__, "..", "data", "gtfs", "gtfs_nl_2024_07_01"])
date = Date(2024, 7, 1)
timetable = create_raptor_timetable(gtfs_dir, date);
save_timetable(timetable)

# date = Date(2024, 7, 1)
# timetable = load_timetable();

origin = "UTO" # Utrecht Overvecht
destination = "ZL" # Zwolle
departure_time = date + Time(13);

# Create query for algorithm
query = McRaptorQuery(origin, departure_time, timetable);

# Run algorithm
bag_round_stop, last_round = run_mc_raptor(timetable, query);

# Reonstruct journeys from bags resulting from mc raptor
origin_station = timetable.stations[origin]
destination_station = timetable.stations[destination]
journeys = reconstruct_journeys(
    origin_station, destination_station, bag_round_stop, last_round
);

# Convert vector of journeys to dataframe
df = journey_leg_dataframe(journeys);

# Print dataframe
println(df)
