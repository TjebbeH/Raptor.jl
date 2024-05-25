include("./raptor_timetable.jl")
using .RaptorTimeTable
using Dates

include("./timetable_functions.jl") # tmp
include("./raptor_functions.jl") # tmp
include("./logger.jl"); #tmp

# gtfs_dir = "gtfs_nl_2024_05_20"
# date = Date(2024,5,20)
# timetable = create_raptor_timetable(gtfs_dir,date);
# save_timetable(timetable)

date = Date(2024,5,20)
timetable = load_timetable();


include("./journey_structs.jl")
include("./raptor_structs.jl")



struct McRaptorQuery
    origin::Station
    destination::Station
    departure_time::DateTime
end

origin = get_station(StationAbbreviation("ASN"), timetable);
destination = get_station(StationAbbreviation("UT"), timetable);
departure_time = DateTime(2024,5,20,12,0,0);

query = McRaptorQuery(origin, destination, departure_time);

maximum_rounds = 2

# function run_mc_raptor(query::McRaptorQuery, maximum_rounds::Int)
bag_round_stop = initialize_bags(maximum_rounds, query)

marked_stops = query.origin.stops

round_counter = 0
for k in 1:maximum_rounds
    @info "analyzing possibilities round $k"
    @debug("number of stops to evaluate: $(length(marked_stops))")

    # Copy bag from previous round
    bag_round_stop[k] = copy(bag_round_stop[k - 1])
    if length(marked_stops) == 0
        break
    end
    round_counter = k

    # Accumulate routes serving marked stops from previous round


end
routes = collect(values(timetable.routes))
route_idx = findall(route -> marked_stops[2] in route.stops, routes)
routes[route_idx]


