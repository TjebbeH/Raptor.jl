"""
Check if it is ok that leg1 is before leg 2:
- It is possible to go from current leg to other leg concerning arrival and departure time
- Number of trips of leg1 < number of trips of leg2, or <= when leg2 is transfer leg
"""
function is_compatible_before(leg1::JourneyLeg, leg2::JourneyLeg)
    time_compatible = (leg1.arrival_time <= leg2.departure_time)
    if is_transfer(leg2)
        number_of_trips_compatible =
            leg1.to_label.number_of_trips <= leg2.to_label.number_of_trips
    else
        number_of_trips_compatible =
            leg1.to_label.number_of_trips < leg2.to_label.number_of_trips
    end
    only_one_is_transfer = !(is_transfer(leg1) & is_transfer(leg2))
    return time_compatible & number_of_trips_compatible & only_one_is_transfer
end

"""One step in the journey reconstruction by adding one set of legs"""
function one_step_journey_reconstruction(
    journeys::Vector{Journey}, origin_stops::Vector{Stop}, bag_last_round
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

"""Constructs last legs of journey assuming arriving at any platform of the station is ok"""
function last_legs(destination::Station, bag_last_round)
    to_stops = destination.stops
    station_bag = merge_bags([bag_last_round[s] for s in to_stops])

    journeys = Journey[]
    for option in station_bag.options
        # find the stop of the station at which the option arrives
        to_stop = only(filter(s -> option in bag_last_round[s].options, to_stops))
        clear_how_to_get_there =
            !isnothing(option.from_stop) &&
            !isnothing(option.from_departure_time) &&
            !isnothing(option.trip_to_station)
        if clear_how_to_get_there
            leg = JourneyLeg(option, to_stop)
            push!(journeys, Journey([leg]))
        end
    end
    return journeys
end

"""Reconstruct journeys to destionation station"""
function reconstruct_journeys(
    origin::Station, destination::Station, bag_round_stop, last_round
)
    bag_last_round = bag_round_stop[last_round]

    journeys = last_legs(destination, bag_last_round)

    for _ in 1:(last_round * 2) #times two because for every round we have train trips and footpaths
        journeys = one_step_journey_reconstruction(journeys, origin.stops, bag_last_round)
    end
    return journeys
end

"""Reconstruct journeys to all destinations"""
function reconstruct_journeys_to_all_destinations(
    origin::Station, timetable::TimeTable, bag_round_stop, last_round
)
    destination_stations = Iterators.filter(!isequal(origin), values(timetable.stations))
    return Dict(
        destination.abbreviation =>
            reconstruct_journeys(origin, destination, bag_round_stop, last_round) for
        destination in destination_stations
    )
end

"""Reconstruct journeys to all destinations"""
function journeys_to_all_destinations(
    origin::Station, timetable::TimeTable, bag_round_stop, last_round
)
    destination_stops = Iterators.filter(!isequal(origin), values(timetable.stations))
    journeys = reduce(
        vcat,
        [
            reconstruct_journeys(origin, destination, bag_round_stop, last_round) for
            destination in destination_stops
        ],
    )

    return journeys
end

"""Reconstruct journeys to all destinations and append to journeys_to_destination dict"""
function reconstruct_journeys_to_all_destinations!(
    journeys_to_destination::Dict{String,Vector{Journey}},
    origin::Station,
    timetable::TimeTable,
    bag_round_stop,
    last_round,
)
    destination_stations = Iterators.filter(!isequal(origin), values(timetable.stations))
    for destination in destination_stations
        if destination.abbreviation in keys(journeys_to_destination)
            append!(
                journeys_to_destination[destination.abbreviation],
                reconstruct_journeys(origin, destination, bag_round_stop, last_round),
            )
        else
            journeys_to_destination[destination.abbreviation] = reconstruct_journeys(
                origin, destination, bag_round_stop, last_round
            )
        end
    end
end

"""Remove duplicate journeys"""
function remove_duplicate_journeys!(journeys_to_destination::Dict{String,Vector{Journey}})
    for destination in keys(journeys_to_destination)
        journeys_to_destination[destination] = unique(journeys_to_destination[destination])
    end
end

"""Sort journeys"""
function sort_journeys!(journeys_to_destination::Dict{String,Vector{Journey}})
    for destination in keys(journeys_to_destination)
        sort!(journeys_to_destination[destination]; by=x -> x.legs[1].departure_time)
    end
end

function is_transfer(leg::JourneyLeg)
    return leg.to_stop.station_abbreviation == leg.from_stop.station_abbreviation
end

"""Converts a vector of journeys to a DataFrame"""
function journey_dataframe(journeys::Vector{Journey})
    first_legs = [journey.legs[1] for journey in journeys]
    last_legs = [journey.legs[end] for journey in journeys]
    return DataFrame(
        "origin" => [leg.from_stop.station_abbreviation for leg in first_legs],
        "destination" => [leg.to_stop.station_abbreviation for leg in last_legs],
        "departure_time_ams" => [leg.departure_time for leg in first_legs],
        "arrival_time_ams" => [leg.arrival_time for leg in last_legs],
        "transfers" => [leg.to_label.number_of_trips - 1 for leg in last_legs],
        "fare" => [leg.to_label.fare for leg in last_legs],
        "journey_hash" => [hash(journey) for journey in journeys],
    )
end

"""Converts a vector of journeys into a DataFrame with journey legs"""
function journey_leg_dataframe(journeys::Vector{Journey})
    legs = [
        (hash(journey), leg) for journey in journeys for
        leg in journey.legs if !is_transfer(leg)
    ]

    return DataFrame(
        "journey_hash" => [h for (h, _) in legs],
        "start_station" => [leg.from_stop.station_abbreviation for (_, leg) in legs],
        "end_station" => [leg.to_stop.station_abbreviation for (_, leg) in legs],
        "start_platform" => [leg.from_stop.platform_code for (_, leg) in legs],
        "end_platform" => [leg.to_stop.platform_code for (_, leg) in legs],
        "departure_time_ams" => [leg.departure_time for (_, leg) in legs],
        "arrival_time_ams" => [leg.arrival_time for (_, leg) in legs],
        "fare" => [leg.fare for (_, leg) in legs],
    )
end
