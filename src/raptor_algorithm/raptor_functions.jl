
labels(bag::Bag) = [option.label for option in bag.options]

create_stop_to_empty_bags(from_stops) = Dict(stop => Bag() for stop in from_stops)

"""Initialize empty bags for every stop at every round."""
function initialize_bag_round_stop(
        maximum_rounds::Int,
        stops::Base.ValueIterator{Dict{String, Stop}},
        result_previous_run::Union{Dict{Stop, Bag}, Nothing}
)
    bag_round_stop = [create_stop_to_empty_bags(stops) for _ in 1:maximum_rounds]
    if !isnothing(result_previous_run)
        bag_round_stop[1] = result_previous_run
    end
    return bag_round_stop
end

function initialize_round1!(bag_round_stop::Vector{Dict{Stop, Bag}}, query::McRaptorQuery)
    """Initialize empty bags for every stop at every round.
    More over, initialize bags for each round with the stops at the departure stations
    and labels with arriving time equal to the departure time at those stops
    """
    from_stops = query.origin.stops
    @debug "starting from stops: " * join(display_name.(from_stops), ", ")
    initial_label = Label(query.departure_time, 0, 0)
    for stop in from_stops
        push!(bag_round_stop[1][stop].options, Option(initial_label))
    end
end

function get_routes_to_travers(timetable::TimeTable, marked_stops::Set{Stop})
    """Collect routes to travers that serve one of the marked_stops.
    Returns dict with routes as keys and the corresponding marked stop as value.
    """
    Q = Dict{Route, Stop}()
    for marked_stop in marked_stops
        routes_serving_marked_stop = get(
            timetable.stop_routes_lookup, marked_stop, Dict{Route, Int64}())
        for route in keys(routes_serving_marked_stop)
            stop_in_Q = get(Q, route, missing)
            if marked_stop == first_in_route(timetable, route, stop_in_Q, marked_stop)
                Q[route] = marked_stop
            end
        end
    end
    @debug "found $(length(Q)) routes serving marked stops"
    return Q
end

function is_geq_at_everything(label1::Label, label2::Label)
    """Check if label1 is worse or equal at all criteria then label2"""
    criteria = fieldnames(Label)
    return all(getfield(label1, field) >= getfield(label2, field) for field in criteria)
end

function is_much_slower(label1::Label, label2::Label, threshold::Minute = Minute(60))
    Minute(label1.arrival_time - label2.arrival_time) > threshold
end

function isdominated(label::Label, labels::Vector{Label})
    """Check if there is a label in labels that dominates label."""
    for other_label in labels
        is_different = other_label != label
        is_worse_at_everything = is_geq_at_everything(label, other_label)
        is_very_slow = is_much_slower(label, other_label)
        if is_different
            if is_worse_at_everything || is_very_slow
                return true
            end
        end
    end
    return false
end

function pareto_set_idx(labels::Vector{Label})
    """Calculate pareto set of labels of options.
    That is, remove all labels that are dominated by an other.
    Note that duplicates are not removed."""
    to_keep = trues(size(labels))
    for (i, label) in enumerate(labels)
        to_keep[i] = !isdominated(label, labels[to_keep])
    end
    return to_keep
end

function pareto_set(options::Vector{Option})
    labels = [o.label for o in options]
    to_keep = pareto_set_idx(labels)
    return options[to_keep] |> unique
end

function merge_bags(bag1::Bag, bag2::Bag)
    """Merge bag1 and bag2.
    That is, return bag with pareto set of combined labels."""
    combined_options = [bag1.options; bag2.options]
    pareto_options = pareto_set(combined_options)
    return Bag(pareto_options)
end

merge_bags(bags::Vector{Bag}) = reduce(merge_bags, bags)

different_options(b1::Bag, b2::Bag) = b1.options != b2.options

function traverse_routes!(
        bag_round_stop::Vector{Dict{Stop, Bag}},
        k::Int,
        timetable::TimeTable,
        marked_stops::Set{Stop}
)
    routes_to_travers = get_routes_to_travers(timetable, marked_stops)
    @debug "$(length(routes_to_travers)) routes to travers"

    new_marked_stops = Set{Stop}()
    for (marked_route, marked_stop) in routes_to_travers
        marked_stops_in_route = traverse_route!(
            bag_round_stop, k, timetable, marked_route, marked_stop)
        union!(new_marked_stops, marked_stops_in_route)
    end
    return new_marked_stops
end

function traverse_route!(
        bag_round_stop::Vector{Dict{Stop, Bag}},
        k::Int,
        timetable::TimeTable,
        route::Route,
        stop::Stop
)
    """Traverse in round k, through a route from a (marked) stop.
    It updates (inplace) bag_round_stop and returns newly marked stops"""
    @debug "traverse route= $(route)"
    @debug "from stop: $stop"

    # Get all stops after stop within the current route
    stop_index = get_stop_idx_in_route(timetable, stop, route)
    remaining_stops_in_route = route.stops[stop_index:end]

    route_bag = Bag()
    new_marked_stops = Set{Stop}()
    for (stop_idx, current_stop) in enumerate(remaining_stops_in_route)
        @debug "stop_idx = $stop_idx, current_stop = $current_stop"

        # Step 1: update earliest arrival times and criteria for each label L in route-bag
        updated_options = Option[]
        for option in route_bag.options
            trip_stop_time = get_stop_time(option.trip_to_station, current_stop)

            # Take fare of previous stop in trip as fare is defined on start
            previous_stop = remaining_stops_in_route[stop_idx - 1]
            from_fare = get_fare(option.trip_to_station, previous_stop)

            new_arrival_time = trip_stop_time.arrival_time
            option = update_option(option, new_arrival_time, from_fare)
            push!(updated_options, option)
        end

        route_bag = Bag(updated_options)

        # Step 2: merge bag_route into bag_round_stop and remove dominated labels
        # The label contains the trip with which one arrives at current stop with k legs
        # and we boarded the trip at from_stop.
        new_bag = merge_bags(bag_round_stop[k][current_stop], route_bag)
        bag_updated = different_options(bag_round_stop[k][current_stop], new_bag)
        bag_round_stop[k][current_stop] = new_bag

        # Mark stop if bag is updated
        if bag_updated
            push!(new_marked_stops, current_stop)
        end

        # Step 3: merge B_{k-1}(p) into B_r
        route_bag = merge_bags(route_bag, bag_round_stop[k - 1][current_stop])

        # Assign trips to all newly added labels in route_bag
        # This is the trip on which we board
        updated_options = Option[]
        for option in route_bag.options
            label = option.label
            @debug "get earliest trip from $(current_stop) after $(label.arrival_time)"
            earliest_trip, departure_time = get_earliest_trip(
                timetable, route, current_stop, label.arrival_time)
            if !isnothing(earliest_trip)
                @debug "earliest trip is $(earliest_trip.name) with stop_times = $(earliest_trip.stop_times)"
                # Update label with earliest trip in route leaving from this station
                # If trip is different we board the trip at current_stop
                option = update_option(option, current_stop, earliest_trip, departure_time)
                push!(updated_options, option)
            else
                @debug "no earliest trip found"
            end
        end

        route_bag = Bag(updated_options)
    end
    @debug "$(length(new_marked_stops)) stops marked"

    return new_marked_stops
end

function add_to_arrival_time(label, time::Second)
    Label(label.arrival_time + time, label.fare, label.number_of_trips)
end

function update_option_label(option::Option, label::Label)
    Option(label, option.trip_to_station, option.from_stop, option.from_departure_time)
end

function update_option(
        option::Option,
        from_stop::Stop,
        trip::Trip,
        departure_time::DateTime
)
    """Update option if trip is different from the trip in option"""
    if option.trip_to_station != trip
        old_label = option.label
        new_label = Label(
            old_label.arrival_time, old_label.fare, old_label.number_of_trips + 1)
        return Option(new_label, trip, from_stop, departure_time)
    end
    return option
end

function update_option(option::Option, arrival_time::DateTime, fare_addition::Number)
    """Update option with new arrival time and fare addition"""
    old_label = option.label
    new_label = Label(
        arrival_time, old_label.fare + fare_addition, old_label.number_of_trips)
    return update_option_label(option, new_label)
end

function get_walking_time(timetable::TimeTable, stop1::Stop, stop2::Stop)
    timetable.footpaths[(stop1.id, stop2.id)].duration
end

function add_walking!(
        bag_round_stop::Vector{Dict{Stop, Bag}},
        k::Int,
        timetable::TimeTable,
        stops::Set{Stop}
)
    """Adds walking times in round k, from stops to other stops at the same station.
    It updates (inplace) bag_round_stop and returns newly marked stops"""
    new_marked_stops = Set{Stop}()
    for stop in stops
        station = get_station(stop, timetable)
        other_stops = get_other_stops_at_station(station, stop)

        options = bag_round_stop[k][stop].options
        for other_stop in other_stops
            temp_bag = Bag()
            footh_path = timetable.footpaths[(stop.id, other_stop.id)]
            walking_time = footh_path.duration
            for option in options
                new_label = add_to_arrival_time(option.label, walking_time)
                departure_time = option.label.arrival_time
                new_option = Option(new_label, option.trip_to_station, stop, departure_time)
                push!(temp_bag.options, new_option)

                #TODO: make function (repeated fron traverse_route)
                # Merge temp bag into B_k(p_j)
                new_bag = merge_bags(bag_round_stop[k][other_stop], temp_bag)
                bag_updated = different_options(bag_round_stop[k][other_stop], new_bag)
                bag_round_stop[k][other_stop] = new_bag

                # Mark stop if bag is updated
                if bag_updated
                    push!(new_marked_stops, other_stop)
                end
            end
        end
    end
    @debug "marked $(length(new_marked_stops)) stops by walking"
    return new_marked_stops
end

function run_mc_raptor(timetable::TimeTable, query::McRaptorQuery,
        result_previous_run::Union{Dict{Stop, Bag}, Nothing})
    maximum_rounds = query.maximum_number_of_rounds
    @debug "round 1: initialization"
    bag_round_stop = initialize_bag_round_stop(
        maximum_rounds, values(timetable.stops), result_previous_run)
    initialize_round1!(bag_round_stop, query)

    marked_stops = Set{Stop}(query.origin.stops)

    last_round = 1
    for k in 2:maximum_rounds
        @debug "round $k: analyzing possibilities from $(length(marked_stops)) stops"

        # Copy bag from previous round
        bag_round_stop[k] = copy(bag_round_stop[k - 1])
        if length(marked_stops) == 0
            @debug "no marked stops"
            break
        end
        last_round = k

        # Traverse routes serving marked stops from previous round
        marked_stops_by_train = traverse_routes!(bag_round_stop, k, timetable, marked_stops)

        # Walk to other stops at stations of marked_stops
        marked_stops_by_walking = add_walking!(
            bag_round_stop, k, timetable, marked_stops_by_train)

        # Combine marked stops
        marked_stops = union(marked_stops_by_train, marked_stops_by_walking)
    end
    @debug "finished raptor algorithm to create bag with best options"
    return bag_round_stop, last_round
end
function run_mc_raptor(timetable::TimeTable, query::McRaptorQuery)
    run_mc_raptor(timetable, query, nothing)
end

"""Run McRaptor for range query"""
function run_mc_raptor_and_construct_journeys(
        timetable::TimeTable, range_query::RangeMcRaptorQuery)
    origin = range_query.origin
    departure_time_min = range_query.departure_time_min
    departure_time_max = range_query.departure_time_max
    maximum_number_of_rounds = range_query.maximum_number_of_rounds

    journeys = Dict{Station, Vector{Journey}}()
    departure_times_from_origin = departure_times(
        timetable, origin, departure_time_min, departure_time_max)
    @info "calculating journey options for $(length(departure_times_from_origin)) departures from $(origin.name)"

    last_round_bag = nothing
    for departure in departure_times_from_origin
        query = McRaptorQuery(origin, departure, maximum_number_of_rounds)
        if isnothing(last_round_bag)
            bag_round_stop, last_round = run_mc_raptor(timetable, query)
        else
            bag_round_stop, last_round = run_mc_raptor(timetable, query, last_round_bag)
        end
        last_round_bag = copy(bag_round_stop[last_round])
        reconstruct_journeys_to_all_destinations!(
            journeys, query.origin, timetable, bag_round_stop, last_round)
    end
    remove_duplicate_journeys!(journeys)
    sort_journeys!(journeys)
    return journeys
end

"""Run McRaptor and construct all journeys on a date"""
function calculate_all_journeys(
        timetable::TimeTable, date::Date, maximum_number_of_transfers::Integer = 5)
    stations = sort(collect(values(timetable.stations)), by = station -> station.name)

    maximum_number_of_rounds = maximum_number_of_transfers + 1
    all_journeys = @sync @distributed (merge!) for origin in stations
        departure_time_min = date + Time(0)
        departure_time_max = date + Time(23, 59)

        range_query = RangeMcRaptorQuery(
            origin, departure_time_min, departure_time_max, maximum_number_of_rounds)
        Dict(origin => run_mc_raptor_and_construct_journeys(timetable, range_query))
    end
    return all_journeys
end
