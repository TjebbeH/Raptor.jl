using Raptor
using Dates

Threads.nthreads()

# gtfs_dir = joinpath([@__DIR__, "..", "data", "gtfs", "gtfs_nl_2024_07_01"])
# date = Date(2024, 7, 1)
# timetable = create_raptor_timetable(gtfs_dir, date);
# save_timetable(timetable)

function main()
    timetable = load_timetable()

    date = Date(2024, 7, 1)
    maximum_transfers = 1

    journeys = @time calculate_all_journeys_mt(timetable, date, maximum_transfers)
    return journeys
end
journeys = main();

# Check the journey options from Eindhoven to Groningen
origin = "EHV";
destination = "GN";
println(journeys[origin][destination])
