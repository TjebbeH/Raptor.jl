using Raptor

using Dates

# gtfs_dir = joinpath([@__DIR__, "..", "data", "gtfs", "gtfs_nl_2024_07_01"])
# date = Date(2024, 7, 1)
# timetable = create_raptor_timetable(gtfs_dir, date);
# save_timetable(timetable)

function main()
    date = Date(2024, 7, 1)
    timetable = load_timetable()

    origin = "VS" # Vlissingen
    departure_time_min = date + Time(0)
    departure_time_max = date + Time(23, 59)

    range_query = RangeMcRaptorQuery(
        origin, departure_time_min, departure_time_max, timetable
    )
    journeys = run_mc_raptor_and_construct_journeys(timetable, range_query)
    return journeys
end

journeys = @time main();

println(journeys["AKM"]) # Akkrum
println(journeys["GN"]) # Groningen
