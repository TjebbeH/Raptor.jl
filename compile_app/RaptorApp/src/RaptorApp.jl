module RaptorApp

include("../../../src/Raptor.jl")
using .Raptor
using Dates

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
    gtfs_dir = ARGS[1]
    date = Date(2024,7,1)

    @info "creating timetable from gtfs data at: $(gtfs_dir)"
    timetable = create_raptor_timetable(gtfs_dir, date)

    @info "timetable loaded with period = $(timetable.period)"

    journeys = @time calculate_all_journeys_mt(timetable, date)
    @info "calculated all journeys! but your not getting them."
    
    return journeys 
end

end # module