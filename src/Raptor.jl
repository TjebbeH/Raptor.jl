module Raptor

export parse_gtfs, GtfsData, GtfsTimeTable
export create_raptor_timetable, save_timetable, load_timetable

export McRaptorQuery, RangeMcRaptorQuery
export run_mc_raptor
export get_station
export reconstruct_journeys, reconstruct_journeys_to_all_destinations
export run_mc_raptor_and_construct_journeys
export calculate_all_journeys_distributed, calculate_all_journeys_mt

export journeys_to_dataframe, write_in_four_parts

using Dates
using Logging
using DataFrames, CSV
using Serialization
using Distributed
using DataStructures

include("utils.jl")

# Gtfs timetable
include("gtfs/parse.jl")

# Raptor timetable
include("raptor_timetable/timetable_structs.jl")
include("raptor_timetable/timetable_creation.jl")
include("raptor_timetable/timetable_functions.jl")

# Algorithm
include("raptor_algorithm/raptor_structs.jl")
include("raptor_algorithm/raptor_functions.jl")

# Reconstruction of journeys
include("raptor_algorithm/journey_structs.jl")
include("raptor_algorithm/construct_journeys.jl")

# import Raptor: write_in_four_parts

function julia_main()::Cint
    try
        real_main()
    catch
        Base.invokelatest(Base.display_error, Base.catch_stack())
        return 1
    end
    return 0
end

function real_main()
    @show ARGS
    if length(ARGS) != 1
        msg = "Please provide (only a) date in the format YYYY_MM_DD"
        throw(ArgumentError(msg))
        return nothing
    end
    date = Date(parse.(Int,split(ARGS[1],'_'))...)
    version = "visum_$(year(date))_$(lpad(month(date), 2, '0'))_$(lpad(day(date), 2, '0'))"
    @show gtfs_dir = joinpath([@__DIR__, "..", "..", "data", "gtfs", version])

    timetable = create_raptor_timetable(gtfs_dir, date)

    maximum_transfers = 1
    journeys = @time calculate_all_journeys_mt(timetable, date, maximum_transfers)
    df = journeys_to_dataframe(journeys)
    df.algoritme_naam .= "raptor.jl"

    @info "splitting df in four parts and saving them"
    write_in_four_parts(df, date, "journeys_$(version)")
    return nothing  
end

end
