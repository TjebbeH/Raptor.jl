"""
Check if it is ok that leg1 is before leg 2:
- It is possible to go from current leg to other leg concerning arrival and departure time
- Number of trips of leg1 < number of trips of leg2, or <= when leg2 is transfer leg
"""
function is_compatible_before(leg1::JourneyLeg, leg2::JourneyLeg)
    time_compatible = (
        leg1.arrival_time <= leg2.departure_time
    )
    if is_transfer(leg2)
        number_of_trips_compatible = leg1.to_label.number_of_trips <=
                                     leg2.to_label.number_of_trips
    else
        number_of_trips_compatible = leg1.to_label.number_of_trips <
                                     leg2.to_label.number_of_trips
    end
    only_one_is_transfer = !(is_transfer(leg1) & is_transfer(leg2))
    return time_compatible & number_of_trips_compatible & only_one_is_transfer
end

"""One step in the journey reconstruction"""
function one_step_journey_reconstruction(
        journeys::Vector{Journey},
        origin_stops::Vector{Stop},
        bag_last_round
)
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

"""Reconstruct journeys to destionation station"""
function reconstruct_journeys(
        origin::Station, destination::Station, bag_round_stop, last_round)
    bag_last_round = bag_round_stop[last_round]

    to_stops = destination.stops
    station_bag = merge_bags([bag_last_round[s] for s in to_stops])

    #TODO: make nicer
    #TODO: make test which tests this
    journeys = Journey[]
    for option in station_bag.options
        for s in to_stops
            if option in bag_last_round[s].options
                if !isnothing(option.from_stop) && !isnothing(option.from_departure_time) &&
                   !isnothing(option.trip_to_station)
                    leg = JourneyLeg(option, s)
                    push!(journeys, Journey([leg]))
                end
            end
        end
    end

    # if isempty(journeys)
    #     @warn "destination $(destination.name) unreachable"
    # end
    function one_step(journeys::Vector{Journey})
        one_step_journey_reconstruction(journeys, origin.stops, bag_last_round)
    end
    for _ in 1:(last_round * 2) #times two because for every round we have train trips and footpaths
        journeys = one_step(journeys)
    end
    return journeys
end

"""Reconstruct journeys to all destinations"""
function reconstruct_journeys_to_all_destinations(
        origin::Station, timetable::TimeTable, bag_round_stop, last_round)
    destination_stops = Iterators.filter(!isequal(origin), values(timetable.stations))
    return Dict(destination => reconstruct_journeys(
                    origin, destination, bag_round_stop, last_round)
    for destination in destination_stops)
end

"""Reconstruct journeys to all destinations and append to journeys_to_destination dict"""
function reconstruct_journeys_to_all_destinations!(
        journeys_to_destination::Dict{Station, Vector{Journey}},
        origin::Station, timetable::TimeTable, bag_round_stop, last_round)
    destination_stations = Iterators.filter(!isequal(origin), values(timetable.stations))
    for destination in destination_stations
        if destination in keys(journeys_to_destination)
            append!(journeys_to_destination[destination],
                reconstruct_journeys(origin, destination, bag_round_stop, last_round))
        else
            journeys_to_destination[destination] = reconstruct_journeys(
                origin, destination, bag_round_stop, last_round)
        end
    end
end

"""Remove duplicate journeys"""
function remove_duplicate_journeys!(journeys_to_destination::Dict{Station, Vector{Journey}})
    for destination in keys(journeys_to_destination)
        unique!(journeys_to_destination[destination])
    end
end

"""sort duplicate journeys"""
function sort_journeys!(journeys_to_destination::Dict{Station, Vector{Journey}})
    for destination in keys(journeys_to_destination)
        sort!(journeys_to_destination[destination], by = x -> x.legs[1].departure_time)
    end
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
