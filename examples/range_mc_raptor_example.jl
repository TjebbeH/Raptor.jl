using Raptor

using Dates

# gtfs_dir = joinpath([@__DIR__, "..", "data", "gtfs", "gtfs_nl_2024_07_01"])
# date = Date(2024, 7, 1)
# timetable = create_raptor_timetable(gtfs_dir, date);
# save_timetable(timetable)

function main()
    date = Date(2025, 2, 1)
    version = "visum_$(year(date))_$(lpad(month(date), 2, '0'))_$(lpad(day(date), 2, '0'))"

    timetable = load_timetable("raptor_timetable_$(version)")

    # origin = "LW" # Vlissingen
    departure_time_min = date + Time(20,50)
    departure_time_max = date + Time(22,51)
    journeys = Dict()
    for origin in ["BD"]
        range_query = RangeMcRaptorQuery(
            origin, departure_time_min, departure_time_max, timetable, 5
        )
        journeys[origin] = @time run_mc_raptor_and_construct_journeys(timetable, range_query)
    end
    df = journeys_to_dataframe(journeys)
    df.algoritme_naam .= "raptor.jl"
    return df, journeys
    # return journeys
end

using DataFrames
df, journeys = main();
for j in journeys["BD"]["AC"]
    println(j)
end

df = journeys_to_dataframe(journeys)

df_ODB = filter(:bestemming => ==("AC"), df)
df_ZL_ODB = filter(:herkomst => ==("ZL"), df_ODB)

df_VH = filter(:bestemming => ==("VH"), df)
df_ZL_VH = filter(:herkomst => ==("ZL"), df_VH)
nrow(df_ZL_VH)
nrow(unique(df_ZL_VH))
length(journeys["ZL"]["VH"])
sort!(df_ZL_VH, [:treinnummers, :vertrekmoment])

filter(:treinnummers => ==(["880", "2680", "4891", "6395"]), df_ZL_VH)
filter(:treinnummers => ==(["880", "880", "2680","2680", "4891", "4891", "6395"]), df_ZL_VH)


journeys_2216 = [journeys["ZL"]["VH"][1], journeys["GN"]["VH"][2]]

import Raptor: journeys_to_df

pif = journeys_to_df(journeys_2216)


df_overstaps = filter!(:aantal_overstappen => >=(1), df_VH)

df_VH[(df_VH.aantal_overstappen .== length(df_VH.overstapstations)), :]
filter(df_overstaps.aantal_overstappen .== length.(df_overstaps.overstapstations))

df_overstaps

df_overstaps.pif .= length.(df_overstaps.overstapstations)
df_overstaps

df_overstaps[df_overstaps.aantal_overstappen .!= df_overstaps.pif,:]

using CSV
using DataFrames

df = CSV.read("output/journeys_visum_2025_01_21_part1.csv", DataFrame) |> DataFrame
df_VH = filter(:bestemming => ==("VH"), df)
df_ZL_VH = filter(:herkomst => ==("ZL"), df_VH)
sort!(df_ZL_VH, [:treinnummers, :vertrekmoment])
unique(df_ZL_VH)

import Raptor:calculate_chuncks
date = Date(2025, 1, 21)
timetable = load_timetable("raptor_timetable_visum_2025_01_21");
chuncks = calculate_chuncks(timetable, date + Time(0), date + Time(23, 59), 20)