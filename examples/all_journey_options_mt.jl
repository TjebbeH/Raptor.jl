using Raptor
using Dates
using CSV

Threads.nthreads()

# gtfs_dir = joinpath([@__DIR__, "..", "data", "gtfs", "gtfs_nl_2024_07_01"])
# date = Date(2024, 7, 1)
# timetable = create_raptor_timetable(gtfs_dir, date);
# save_timetable(timetable)

function write_in_three_parts(df, name)
    @info "    part 1"
    
    df1 = filter(:vertrekmoment => x -> x <= DateTime(2025, 1, 21,10,0,0), df)
    CSV.write(
        "output/$(name)_part1.csv", df1;
        delim=';',
        dateformat="yyyy-mm-ddTHH:MM:SS",
        quotechar=''' 
        )
    @info "    part 2"
    df2 = filter(:vertrekmoment => x -> DateTime(2025, 1, 21,10,0,0) < x <= DateTime(2025, 1, 21,15,0,0), df)
    CSV.write(
            "output/$(name)_part2.csv", df2; 
            delim=';',
            dateformat="yyyy-mm-ddTHH:MM:SS",
            quotechar=''' 
        )
    @info "    part 3"
    df3 = filter(:vertrekmoment => x -> DateTime(2025, 1, 21,15,0,0) < x, df)
    CSV.write(
            "output/$(name)_part3.csv", df3; 
            delim=';',
            dateformat="yyyy-mm-ddTHH:MM:SS",
            quotechar=''' 
        )
    return nothing
end

function main()
    date = Date(2025, 1, 21)
    # date = Date(2025, 2, 1)
    version = "visum_$(year(date))_$(lpad(month(date), 2, '0'))_$(lpad(day(date), 2, '0'))"

    timetable = load_timetable("raptor_timetable_$(version)")

    maximum_transfers = 5

    journeys = @time calculate_all_journeys_mt(timetable, date, maximum_transfers)
    df = journeys_to_dataframe(journeys)
    df.algoritme_naam .= "raptor.jl"

    @info "splitting df in three parts and saving them"
    write_in_three_parts(df, "journeys_$(version)")
    return df
end
df = main()


# # Check the journey options from Eindhoven to Groningen
# origin = "EHV";   
# destination = "GN";
# println(journeys[origin][destination])
