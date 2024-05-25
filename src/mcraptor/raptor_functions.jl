
create_empty_bags(from_stops) = Dict(stop => Bag() for stop in from_stops)

function initialize_bags(maximum_rounds::Int, query::McRaptorQuery)
    from_stops = query.origin.stops
    bag_round_stop = [create_empty_bags(from_stops) for _ in 1:maximum_rounds]

    @debug "starting from stops: " * join(display_name.(from_stops), ", ")
    initial_label = Label(query.departure_time, 0, 0)
    for stop in from_stops
        push!(bag_round_stop[1][stop].labels, initial_label)
    end
    return bag_round_stop
end

function pair_routes_with_stops(stops::Vector{Stops}, timetable::RaptorTimeTable)
    routes_serving_stops = {}
    routes = collect(values(timetable.routes))
    for stop in stops
        routes_serving_stop = find_routes_serving_stop(stop, routes)
        if length(routes_serving_stop) > 0
            
        end
    end
end

function find_routes_serving_stop(stop::Stop, routes::Vector{Route})
    route_idx = findall(route -> stop in route.stops, routes)
    return routes[route_idx]
end