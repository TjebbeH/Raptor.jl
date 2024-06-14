using Dates

struct JourneyLeg
    from_stop::Stop
    to_stop::Stop
    # departure_time::DateTime
    arrival_time::DateTime
    trip::Trip
    # fare::Number
end

function JourneyLeg(option::Option, to_stop::Stop)
    """Construct journey leg from option and to_stop"""
    from_stop = option.from_stop
    if from_stop.station_name == to_stop.station_name
        
    end
    trip = option.trip
    # to_stop_time = get_stop_time(trip,to_stop)
    # from_stop_time = get_stop_time(trip,from_stop)
    # if isnothing(to_stop_time)
    #     throw(ArgumentError("$to_stop not in $(trip.name) with stops $(trip.stop_times)"))
    # end
    # if isnothing(from_stop_time)
    #     throw(ArgumentError("$from_stop not in $(trip.name) with stops $(trip.stop_times)"))
    # end
    # arrival_time = get_stop_time(trip,from_stop).arrival_time
    # departure_time = get_stop_time(trip,from_stop).departure_time
    return JourneyLeg(
        from_stop,
        to_stop,
        # departure_time,
        option.label.arrival_time,
        trip,
    )
end
JourneyLegs(options::Vector{Option}, to_stop::Stop) = [JourneyLeg(option, to_stop) for option in options]

struct Journey <: Comparable
    legs::Vector{JourneyLeg}
end
Journeys(options::Vector{Option}, to_stop::Stop) = [Journey([leg]) for leg in JourneyLegs(options, to_stop)]
