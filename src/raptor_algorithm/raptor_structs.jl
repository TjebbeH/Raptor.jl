struct Label
    arrival_time::DateTime
    fare::Float64
    number_of_trips::Int
end

struct Option
    label::Label
    trip_to_station::Union{Trip,Nothing} # trip to take to obtain criteria
    from_stop::Union{Stop,Nothing} # stop to hop-on the trip
    from_departure_time::Union{DateTime,Nothing} # moment to hop-on the trip
end
Option(label::Label) = Option(label, nothing, nothing, nothing)

struct Bag <: Comparable
    options::Vector{Option}
end
Bag() = Bag(Option[])
Bag(labels::Vector{Label}) = Bag([Option(label) for label in labels])

struct McRaptorQuery
    origin::Station
    departure_time::DateTime
    maximum_number_of_rounds::Int
end

struct RangeMcRaptorQuery
    origin::Station
    departure_time_min::DateTime
    departure_time_max::DateTime
    maximum_number_of_rounds::Int
end

"""Constructor where it trys to interpret the origin and destination string as a station"""
function McRaptorQuery(
    origin::String,
    departure_time::DateTime,
    timetable::TimeTable,
    maximum_number_of_rounds::Integer,
)
    origin_station = try_to_get_station(origin, timetable)
    return McRaptorQuery(origin_station, departure_time, maximum_number_of_rounds)
end
"""Constructor where it trys to interpret the origin and destination string as a station and default 10 round"""
function McRaptorQuery(origin::String, departure_time::DateTime, timetable::TimeTable)
    maximum_number_of_rounds = 10
    return McRaptorQuery(origin, departure_time, timetable, maximum_number_of_rounds)
end

function RangeMcRaptorQuery(
    origin::String,
    departure_time_min::DateTime,
    departure_time_max::DateTime,
    timetable::TimeTable,
    maximum_number_of_rounds::Integer,
)
    origin_station = try_to_get_station(origin, timetable)
    return RangeMcRaptorQuery(
        origin_station, departure_time_min, departure_time_max, maximum_number_of_rounds
    )
end

function RangeMcRaptorQuery(
    origin::String,
    departure_time_min::DateTime,
    departure_time_max::DateTime,
    timetable::TimeTable,
)
    maximum_number_of_rounds = 10
    return RangeMcRaptorQuery(
        origin, departure_time_min, departure_time_max, timetable, maximum_number_of_rounds
    )
end
