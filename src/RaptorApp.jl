module RaptorApp

using Raptor
import Raptor: write_in_four_parts

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
    year, month, day = parse.(Int,split(ARGS[1],'_'))
    date = Date(year, month, day)
    version = "visum_$(year(date))_$(lpad(month(date), 2, '0'))_$(lpad(day(date), 2, '0'))"
    gtfs_dir = joinpath([@__DIR__, "..", "data", "gtfs", version])

    timetable = create_raptor_timetable(gtfs_dir, date)

    maximum_transfers = 1
    journeys = @time calculate_all_journeys_mt(timetable, date, maximum_transfers)
    df = journeys_to_dataframe(journeys)
    df.algoritme_naam .= "raptor.jl"

    @info "splitting df in four parts and saving them"
    write_in_four_parts(df, date, "journeys_$(version)")
    return nothing  
end # module