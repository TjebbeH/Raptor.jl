using Raptor

using Dates

# gtfs_dir = joinpath([@__DIR__, "..", "data", "gtfs", "gtfs_nl_2024_07_01"])
# date = Date(2024, 7, 1)
# timetable = create_raptor_timetable(gtfs_dir, date);
# save_timetable(timetable)

function main()
    date = Date(2025, 1, 21)
    timetable = load_timetable("raptor_timetable_visum_2025_01_21")

    # origin = "LW" # Vlissingen
    departure_time_min = date + Time(0)
    departure_time_max = date + Time(23, 59)
    journeys = Dict()
    for origin in ["LW", "MP"]
        range_query = RangeMcRaptorQuery(
            origin, departure_time_min, departure_time_max, timetable, 0
        )
        journeys[origin] = run_mc_raptor_and_construct_journeys(timetable, range_query)
    end
    df = journeys_to_dataframe(journeys)
    df.algoritme_naam .= "raptor.jl"
    return df
end

df = main()


using CSV
CSV.write(
    "output/pif2.csv", df; 
    delim=';',
    dateformat="yyyy-mm-ddTHH:MM:SS",
    quotechar=''',
    quotestrings=true
    )