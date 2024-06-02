include("./raptor_timetable.jl")
using .RaptorTimeTable
using Dates



# gtfs_dir = "gtfs_nl_2024_05_20"
# date = Date(2024,5,20)
# timetable = create_raptor_timetable(gtfs_dir,date);
# save_timetable(timetable)

date = Date(2024,5,20)
timetable = load_timetable();


include("./journey_structs.jl")
include("./raptor_structs.jl")

include("./timetable_functions.jl") # tmp
include("./raptor_functions.jl") # tmp
include("./logger.jl"); #tmp



origin = get_station(StationAbbreviation("ASN"), timetable);
destination = get_station(StationAbbreviation("UT"), timetable);
departure_time = DateTime(2024,5,20,12,0,0);

query = McRaptorQuery(origin, destination, departure_time);

maximum_rounds = 2

# function run_mc_raptor(query::McRaptorQuery, maximum_rounds::Int)
bag_round_stop = initialize_bags(maximum_rounds, query)

marked_stops = query.origin.stops

# round_counter = 0
# for k in 2:maximum_rounds
#     @info "analyzing possibilities round $k"
#     @debug("number of stops to evaluate: $(length(marked_stops))")

#     # Copy bag from previous round
#     bag_round_stop[k] = copy(bag_round_stop[k - 1])
#     if length(marked_stops) == 0
#         break
#     end
#     round_counter = k

#     # Accumulate routes serving marked stops from previous round
#     routes_to_travers = get_routes_to_travers(marked_stops)

    

# end

routes_to_travers = get_routes_to_travers(marked_stops)


new_marked_stops = Set()


marked_route, marked_stop = first(routes_to_travers)

# Traversing through route from marked stop
route_bag = Bag()

# Get all stops after current stop within the current route
marked_stop_index = get_stop_idx_in_route(timetable, marked_stop, marked_route)
remaining_stops_in_route = marked_route.stops[marked_stop_index:end]



for stop_idx, current_stop in enumerate(remaining_stops_in_route):

    # Step 1: update earliest arrival times and criteria for each label L in route-bag
    # update_labels = []
    # for label in route_bag.labels:
    #     trip_stop_time = label.trip.get_stop(current_stop)

    #     # Take fare of previous stop in trip as fare is defined on start
    #     previous_stop = remaining_stops_in_route[stop_idx - 1]
    #     from_fare = label.trip.get_fare(previous_stop)

    #     label = label.update(
    #         earliest_arrival_time=trip_stop_time.dts_arr,
    #         fare_addition=from_fare,
    #     )

    #     update_labels.append(label)
    # route_bag = Bag(labels=update_labels)


