using Distributed
addprocs(16)
@show nworkers()
Threads.nthreads()


# gtfs_dir = joinpath([@__DIR__, "..", "data", "gtfs", "gtfs_nl_2024_07_01"])
# date = Date(2024, 7, 1)
# timetable = create_raptor_timetable(gtfs_dir, date);
# save_timetable(timetable)

# Broadcast package and timetable to all workers
@everywhere begin
    using Raptor
    using Dates
    date = Date(2025, 1, 21)

    version = "visum_$(year(date))_$(lpad(month(date), 2, '0'))_$(lpad(day(date), 2, '0'))"

    timetable = load_timetable("raptor_timetable_$(version)")

end


function main()
    date = Date(2025, 1, 21)

    maximum_transfers = 5
    journeys = @time calculate_all_journeys_distributed(timetable, date, maximum_transfers)

    df = journeys_to_dataframe(journeys)
    df.algoritme_naam .= "raptor.jl"

    @info "splitting df in three parts and saving them"
    write_in_four_parts(df, date, "journeys_distr_$(version)")
    return df, journeys
end

df, j = main();

first(df,10)

# Check the journey options from Eindhoven to Groningen
origin = "EHV";
destination = "GN";
println(journeys[origin][destination])
