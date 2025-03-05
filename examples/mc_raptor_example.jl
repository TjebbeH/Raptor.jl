using Raptor

using Dates

# gtfs_dir = joinpath([@__DIR__, "..", "data", "gtfs", "gtfs_nl_2024_07_01"])
# date = Date(2024, 7, 1)
# timetable = create_raptor_timetable(gtfs_dir, date);
# save_timetable(timetable)

gtfs_dir = joinpath([@__DIR__, "..", "data", "gtfs", "visum_2025_01_21"])
date = Date(2025, 1, 21)
timetable = create_raptor_timetable(gtfs_dir, date, ["NS-Reizigers"]);
save_timetable(timetable,"raptor_timetable_visum_2025_01_21")

function main()
    date = Date(2025, 1, 21)
    timetable = load_timetable("raptor_timetable_visum_2025_01_21")

    origin = "LW" # Groningen
    departure_time = date + Time(13)

    query = McRaptorQuery(origin, departure_time, timetable)

    bag_round_stop, last_round = run_mc_raptor(timetable, query)
    journeys = reconstruct_journeys_to_all_destinations(
        query.origin, timetable, bag_round_stop, last_round
    )
    return journeys
end

journeys = @time main();

println(journeys["GN"]) # Groningen
