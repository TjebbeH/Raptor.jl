using Dates

struct JourneyLeg
    from_stop::Stop
    to_stop::Stop
    departure_time::DateTime
    arrival_time::DateTime
    trip::Trip
end

function JourneyLeg(option::Option, to_stop::Stop)
    """Construct journey leg from option and to_stop"""
    trip = option.trip
    from_stop = option.from_stop
    arrival_time = get_stop_time(trip,to_stop).arrival_time
    departure_time = get_stop_time(trip,from_stop).departure_time
    return JourneyLeg(
        from_stop,
        to_stop,
        departure_time,
        arrival_time,
        trip,
    )
end
JourneyLegs(options::Vector{Option}, to_stop::Stop) = [JourneyLeg(option, to_stop) for option in options]

struct Journey <: Comparable
    legs::Vector{JourneyLeg}
end
