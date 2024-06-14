function one_step_journey_reconstruction(journeys::Vector{Journey}, origin_stops::Vector{Stop}, bag_last_round)
    """One step in the journey reconstruction"""
    new_journeys = Journey[]
    for journey in journeys
        first_leg = journey.legs[1]
        if first_leg.from_stop in origin_stops
            # We dont need more legs
            push!(new_journeys, journey)
        else
            # Where did we come from?
            new_to_stop = first_leg.from_stop
            # collect options to get to new_to_stop
            options_to_new_to_stop = bag_last_round[new_to_stop].options
            new_legs = JourneyLegs(options_to_new_to_stop, new_to_stop)
            append!(new_journeys, [Journey([new_leg; journey.legs]) for new_leg in new_legs])           
        end 
    end
    return new_journeys
end

function reconstruct_journeys(query, bag_round_stop, last_round)
    """Reconstruct journeys"""
    bag_last_round = bag_round_stop[last_round]

    to_stops = query.destination.stops
    station_bag = merge_bags([bag_last_round[s] for s in to_stops])
    #TODO: make nicer
    #TODO: make test which tests this
    journeys = Journey[]
    for option in station_bag.options
        for s in to_stops
            if option in bag_last_round[s].options
                leg = JourneyLeg(option,s)
                push!(journeys, Journey([leg]))
            end
        end
    end

    if isempty(journeys)
        @warn "destination $(query.destination.name) unreachable"
    end
    one_step(journeys::Vector{Journey}) = one_step_journey_reconstruction(journeys, query.origin.stops, bag_last_round)
    for _ in 1:last_round
        journeys = one_step(journeys)
    end
    return journeys
end

is_transfer(leg::JourneyLeg) = leg.from_stop.station_name == leg.to_stop.station_name

function display_journey(journey::Journey)
    for leg in journey.legs
        println(display_leg(leg))
    end
end

function display_leg(leg::JourneyLeg)
    station_string_length = 30
    from = "$(leg.from_stop.station_name) sp.$(leg.from_stop.platform_code)"
    to = "$(leg.to_stop.station_name) sp.$(leg.to_stop.platform_code)"
    from = rpad(from, station_string_length, " ")
    to = rpad(to, station_string_length, " ")

    mode = is_transfer(leg) ? "by foot" : "with $(leg.trip.name)" 
    arrival_time = "$(Dates.format(leg.arrival_time, dateformat"HH:MM"))"
    # departure_time = "$(Dates.format(leg.departure_time, dateformat"HH:MM"))"
    return "$from ()  to  $to ($arrival_time)  $mode"
end

function display_journeys(journeys::Vector{Journey})
    for (i, journey) in enumerate(journeys)
        printstyled("Option $i:\n", bold=true, color=:blue)
        display_journey(journey)
    end
end