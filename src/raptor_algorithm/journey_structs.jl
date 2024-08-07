struct JourneyLeg
    from_stop::Stop
    to_stop::Stop
    departure_time::DateTime
    arrival_time::DateTime
    fare::Number
    trip::Trip
    to_label::Label # criteria for arriving at to_stop
end

"""Construct journey leg from option and to_stop"""
function JourneyLeg(option::Option, to_stop::Stop)
    return JourneyLeg(
        option.from_stop,
        to_stop,
        option.from_departure_time,
        option.label.arrival_time,
        option.label.fare,
        option.trip_to_station,
        option.label,
    )
end
function JourneyLegs(options::Vector{Option}, to_stop::Stop)
    return [JourneyLeg(option, to_stop) for option in options]
end

struct Journey <: Comparable
    legs::Vector{JourneyLeg}
end
# hash journey legs to make unique work
Base.hash(journey::Journey) = hash(getfield(journey, :legs))

function Journeys(options::Vector{Option}, to_stop::Stop)
    return [Journey([leg]) for leg in JourneyLegs(options, to_stop)]
end
