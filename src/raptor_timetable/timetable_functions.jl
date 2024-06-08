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

get_station(stop::Stop, timetable::TimeTable) = get_station(stop.station_name, timetable)

get_other_stops_at_station(station::Station,stop::Stop) = filter(s -> s != stop, station.stops) 



function get_stop_idx_in_route(timetable :: TimeTable, stop::Stop, route::Route)
    """Look up stop index of stop in route"""
    return timetable.stop_routes_lookup[stop][route]
end

function first_in_route(timetable::TimeTable, route::Route, stop1::Stop, stop2::Stop)
    """Return stop that is first in route (stop1 or stop2)"""
    idx_stop1 = get_stop_idx_in_route(timetable, stop1, route)
    idx_stop2 = get_stop_idx_in_route(timetable, stop2, route)
    return idx_stop1 < idx_stop2 ? stop1 : stop2
end
first_in_route(timetable::TimeTable, route::Route, stop1::Stop, stop2::Missing) = stop1
first_in_route(timetable::TimeTable, route::Route, stop1::Missing, stop2::Stop) = stop2


function get_stop_time(trip::Trip, stop::Stop)
    """Get stop time from a stop in a trip.
    Returns nothing when stop is not in trip"""
    stop_time = filter(stop_time -> stop_time.stop == stop, trip.stop_times)
    if isempty(stop_time)
        return nothing
    end
    return stop_time |> only
end

function get_fare(trip::Trip, departing_stop::Stop)
    """Get fare from departing stop in trip.
    Returns zero when stop is not in trip.
    """
    stop_time = get_stop_time(trip, departing_stop)
    if !isnothing(stop_time)
        return stop_time.fare
    end
    return 0
end


function get_earliest_trip(timetable::TimeTable, route::Route, stop::Stop, departure_time::DateTime)
    """Get earliest trip traveling route departing at stop after departure_time"""
    trips = timetable.route_trip_lookup[route]
    departures_from_stop = Dict(get_stop_time(trip, stop).departure_time => trip for trip in trips)
    departures_in_scope = filter(departure -> departure >= departure_time, keys(departures_from_stop))
    if isempty(departures_in_scope)
        return nothing
    end
    earliest_departure_time = minimum(departures_in_scope)
    earliest_trip = departures_from_stop[earliest_departure_time]
    return earliest_trip
end