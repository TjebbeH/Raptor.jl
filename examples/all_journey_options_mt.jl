using Raptor
using Dates
using CSV

Threads.nthreads()

# gtfs_dir = joinpath([@__DIR__, "..", "data", "gtfs", "gtfs_nl_2024_07_01"])
# date = Date(2024, 7, 1)
# timetable = create_raptor_timetable(gtfs_dir, date);
# save_timetable(timetable)

function main(date::Date)
    # date = Date(2025, 1, 21)
    # date = Date(2025, 2, 1)
    version = "visum_$(year(date))_$(lpad(month(date), 2, '0'))_$(lpad(day(date), 2, '0'))"

    timetable = load_timetable("raptor_timetable_$(version)")

    maximum_transfers = 5

    journeys = @time calculate_all_journeys_mt(timetable, date, maximum_transfers)
    df = journeys_to_dataframe(journeys)
    df.algoritme_naam .= "raptor.jl"

    @info "splitting df in three parts and saving them"
    write_in_four_parts(df, date, "journeys_$(version)")
    return df
end
dfs = Dict()
for d in [Date(2025, 1, 21), Date(2025, 2, 1)]
    dfs[d] = main(d)
end
df = dfs[Date(2025, 2, 1)];


df_ZL_VH = filter(:bestemming => ==("VH"), df)
sort!(df_ZL_VH, [:treinnummers, :vertrekmoment])
unique(df_ZL_VH)

first(df,10)
# # Check the journey options from Eindhoven to Groningen
# origin = "EHV";   
# destination = "GN";
# println(journeys[origin][destination])
