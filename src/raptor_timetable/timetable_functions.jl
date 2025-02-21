function first_arrival_time(trip::Trip)
    return minimum([stoptime.arrival_time for stoptime in values(trip.stop_times)])
end

function first_arrival_time(trips::Dict{String,Trip})
    return minimum([first_arrival_time(trip) for trip in values(trips)])
end

function last_departure_time(trip::Trip)
    return maximum([stoptime.departure_time for stoptime in values(trip.stop_times)])
end

function last_departure_time(trips::Dict{String,Trip})
    return maximum([last_departure_time(trip) for trip in values(trips)])
end

function get_timeperiod(trips::Dict{String,Trip})
    return (
        first_arrival=first_arrival_time(trips), last_departure=last_departure_time(trips)
    )
end

function get_routes(trips::Dict{String,Trip})
    return Dict(trip.route.id => trip.route for trip in values(trips))
end

"""Try to get a station from timetable by name or abbreviation"""
function try_to_get_station(name::String, timetable::TimeTable)
    local station
    try
        station = get_station(name, timetable)
    catch ArgumentError
        try
            abbreviation = StationAbbreviation(name)
            station = get_station(abbreviation, timetable)
        catch ArgumentError
            @warn "Station '$name' not found in timetable"
            return missing
        end
    end
    return station
end

function get_station(name::String, timetable::TimeTable)
    return first(
        Iterators.filter(station -> station.name == name, values(timetable.stations))
    )
end

function get_station(abbreviation::StationAbbreviation, timetable::TimeTable)
    return first(
        Iterators.filter(
            station -> station.abbreviation == abbreviation, values(timetable.stations)
        ),
    )
end

display_name(stop::Stop) = stop.station_name * "-" * string(stop.platform_code)

get_station(stop::Stop, timetable::TimeTable) = get_station(stop.station_name, timetable)

function get_other_stops_at_station(station::Station, stop::Stop)
    return filter(s -> s != stop, station.stops)
end

"""Look up stop index of stop in route"""
function get_stop_idx_in_route(timetable::TimeTable, stop::Stop, route::Route)
    return timetable.stop_routes_lookup[stop][route]
end

"""Return stop that is first in route (stop1 or stop2)"""
function first_in_route(timetable::TimeTable, route::Route, stop1::Stop, stop2::Stop)
    idx_stop1 = get_stop_idx_in_route(timetable, stop1, route)
    idx_stop2 = get_stop_idx_in_route(timetable, stop2, route)
    return idx_stop1 < idx_stop2 ? stop1 : stop2
end
first_in_route(timetable::TimeTable, route::Route, stop1::Stop, stop2::Missing) = stop1
first_in_route(timetable::TimeTable, route::Route, stop1::Missing, stop2::Stop) = stop2

"""
Get stop time from a stop in a trip.
Returns nothing when stop is not in trip
"""
get_stop_time(trip::Trip, stop::Stop) = get(trip.stop_times, stop.id, nothing)

"""Get fare from departing stop in trip.
Returns zero when stop is not in trip.
"""
function get_fare(trip::Trip, departing_stop::Stop)
    stop_time = get_stop_time(trip, departing_stop)
    if !isnothing(stop_time)
        return stop_time.fare
    end
    return 0.0
end

"""Get earliest trip traveling route departing at stop after departure_time"""
function get_earliest_trip(
    timetable::TimeTable, route::Route, stop::Stop, departure_time::DateTime
)
    trips_orded_by_departure_time = timetable.route_trip_lookup[route]

    # Retrive first trip that departures at stop after departure_time
    for trip in trips_orded_by_departure_time
        stop_time = get_stop_time(trip, stop)
        if !isnothing(stop_time) && (stop_time.departure_time >= departure_time)
            return trip, stop_time.departure_time
        end
    end
    return nothing, nothing
end


"""Collect all departure moments between t0 and t1 (inclusive) and sort in descending order"""
function descending_departure_times(
    timetable::TimeTable, station::Station, t0::DateTime, t1::DateTime
)
    departures = timetable.station_departures_lookup[station.abbreviation.abbreviation]
    filter!(t -> t0 <= t <= t1, departures)
    sort!(departures; rev=true)
    return departures
end
