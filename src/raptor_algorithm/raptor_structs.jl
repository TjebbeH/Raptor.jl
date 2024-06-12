using Dates

struct Label
    arrival_time::DateTime
    fare::Number
    number_of_trips::Int
end

struct Option
    label::Label
    trip::Union{Trip,Nothing} # trip to take to obtain travel_time and fare
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
end

"""Constructor where it trys to interpret the origin and destination string as a station"""
function McRaptorQuery(origin::String, destination::String, departure_time::DateTime, timetable::TimeTable)
    origin_station = try_to_get_station(origin,timetable)
    destination_station = try_to_get_station(destination,timetable)
    return McRaptorQuery(origin_station, destination_station, departure_time)
end
