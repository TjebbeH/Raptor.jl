using Dates

struct Label
    arrival_time::DateTime
    fare::Number
    number_of_trips::Int
end

struct Option
    label::Label
    means::Union{FootPath,Trip,Nothing} # trip to take to obtain travel_time and fare
    from_stop::Union{Stop,Nothing} # stop to hop-on the trip
end
Option(label::Label) = Option(label, nothing, nothing)

struct Bag <: Comparable
    options::Vector{Option}
end
Bag() = Bag([])
Bag(labels::Vector{Label}) = Bag([Option(label) for label in labels])

struct McRaptorQuery
    origin::Station
    destination::Station
    departure_time::DateTime
    maximum_number_of_rounds::Integer
end

"""Constructor where it trys to interpret the origin and destination string as a station"""
function McRaptorQuery(
    origin::String,
    destination::String,
    departure_time::DateTime,
    timetable::TimeTable,
    maximum_number_of_rounds::Integer
    )
    origin_station = try_to_get_station(origin,timetable)
    destination_station = try_to_get_station(destination,timetable)
    return McRaptorQuery(origin_station, destination_station, departure_time, maximum_number_of_rounds)
    end
"""Constructor where it trys to interpret the origin and destination string as a station and default 10 round"""
function McRaptorQuery(
    origin::String,
    destination::String,
    departure_time::DateTime,
    timetable::TimeTable,
    )
    maximum_number_of_rounds = 10
    return McRaptorQuery(origin, destination, departure_time, timetable, maximum_number_of_rounds)
end
