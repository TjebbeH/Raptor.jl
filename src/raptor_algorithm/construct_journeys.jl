"""
Check if it is ok that leg1 is before leg 2:
- It is possible to go from current leg to other leg concerning arrival and departure time
- Number of trips of current leg differs by > 1, i.e. a differen trip,
    or >= 0 when the other_leg is a transfer_leg
- The accumulated value of a criteria of current leg is larger or equal to the accumulated value of
    the other leg (current leg is instance of this class)
""" 
function is_compatible_before(leg1::JourneyLeg, leg2::JourneyLeg)
    time_compatible = (
            leg1.arrival_time <= leg2.departure_time
        )
    # different_trip = leg1.trip.name != leg2.trip.name
    only_one_is_transfer = !(is_transfer(leg1) & is_transfer(leg2))
    return time_compatible  & only_one_is_transfer
    # return time_compatible & different_trip & only_one_is_transfer
end


function one_step_journey_reconstruction(
        journeys::Vector{Journey},
        origin_stops::Vector{Stop},
        bag_last_round
)
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
            for new_leg in new_legs
                if is_compatible_before(new_leg, first_leg)
                    push!(new_journeys, Journey([new_leg; journey.legs]))
                end
            end
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
                leg = JourneyLeg(option, s)
                push!(journeys, Journey([leg]))
            end
        end
    end

    if isempty(journeys)
        @warn "destination $(query.destination.name) unreachable"
    end
    function one_step(journeys::Vector{Journey})
        one_step_journey_reconstruction(journeys, query.origin.stops, bag_last_round)
    end
    for _ in 1:last_round*2 #times two because for every round we have train and footpaths
        journeys = one_step(journeys)
    end
    return journeys
end

is_transfer(leg::JourneyLeg) = leg.to_stop.station_name == leg.from_stop.station_name

function display_journey(journey::Journey)
    for leg in journey.legs
        printstyled("| ", bold = true, color = :yellow)
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
    departure_time = "$(Dates.format(leg.departure_time, dateformat"HH:MM"))"
    fare = leg.fare > 0 ? "(additional fare: €$(leg.fare))" : ""
    return "$from ($departure_time)  to  $to ($arrival_time)  $mode $fare"
end

function display_journeys(journeys::Vector{Journey}, ignore_walking::Bool = true)
    for (i, journey) in enumerate(journeys)
        if ignore_walking
            journey = Journey(filter(!is_transfer, journey.legs))
        end
        printstyled("Option $i:\n", bold = true, color = :yellow)
        display_journey(journey)
    end
end
