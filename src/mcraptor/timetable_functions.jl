

function first_arrival_time(trip::Trip)
    return minimum([stoptime.arrival_time for stoptime in trip.stop_times])
end

function first_arrival_time(trips::Dict{String,Trip})
    return minimum([first_arrival_time(trip) for trip in values(trips)])
end

function last_departure_time(trip::Trip)
    return maximum([stoptime.departure_time for stoptime in trip.stop_times])
end

function last_departure_time(trips::Dict{String,Trip})
    return maximum([last_departure_time(trip) for trip in values(trips)])
end

get_timeperiod(trips::Dict{String,Trip}) = (first_arrival=first_arrival_time(trips), last_departure=last_departure_time(trips))

get_routes(trips::Dict{String,Trip}) = Dict(trip.route.id => trip.route for trip in values(trips))




function get_station(name::String, timetable::TimeTable)
    return filter(station -> station.name == name, collect(values(timetable.stations))) |> only
end

function get_station(abbreviation::StationAbbreviation, timetable::TimeTable)
    return filter(station -> station.abbreviation == abbreviation, collect(values(timetable.stations))) |> only
end

display_name(stop::Stop) = stop.station_name * "-" * string(stop.platform_code)


