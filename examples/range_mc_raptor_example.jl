using Raptor

using Dates

# gtfs_dir = joinpath([@__DIR__, "..", "data", "gtfs", "gtfs_nl_2024_07_01"])
# date = Date(2024, 7, 1)
# timetable = create_raptor_timetable(gtfs_dir, date);
# save_timetable(timetable)
function main()
    date = Date(2025, 1, 21)
    timetable = load_timetable("raptor_timetable_visum_2025_01_21")

    origin = "LW" # Vlissingen
    departure_time_min = date + Time(0)
    departure_time_max = date + Time(23, 59)

    range_query = RangeMcRaptorQuery(
        origin, departure_time_min, departure_time_max, timetable
    )
    journeys = @time run_mc_raptor_and_construct_journeys(timetable, range_query)
    return journeys
end

journeys = main();

println(journeys["AKM"]) # Akkrum
println(journeys["GN"]) # Groningen
