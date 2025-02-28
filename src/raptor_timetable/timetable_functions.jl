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

"""
Get a station from timetable by abbreviation
also possible to get by name but is less efficient
"""
function get_station(name::String, timetable::TimeTable)
    # If name is abbreviation
    if name in keys(timetable.stations)
        return timetable.stations[name]
    end
    # If name is full station name
    stations = Iterators.filter(station -> station.name == name, values(timetable.stations))
    if isempty(stations)
        msg = "station '$name' not found in timetable"
        throw(ArgumentError(msg))
    end
    return first(stations)
end

display_name(stop::Stop) = stop.station_abbreviation * "-" * string(stop.platform_code)

function get_station(stop::Stop, timetable::TimeTable)
    return get_station(stop.station_abbreviation, timetable)
end

"""Iterator over all other stops at station"""
function get_other_stops_at_station(station::Station, stop::Stop)
    return Iterators.filter(s -> s != stop, station.stops)
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
    timetable::TimeTable, station::Station, t0::DateTime, t1::DateTime; sort_desc::Bool=true
)
    departures = timetable.station_departures_lookup[station.abbreviation]
    filter!(t -> t0 <= t <= t1, departures)
    if sort_desc
        sort!(departures; rev=true)
    end
    return departures
end

""" Order stations in chuncks such that number of departures is balanced"""
function calculate_chuncks(
    timetable::TimeTable,
    departure_time_min::DateTime,
    departure_time_max::DateTime,
    nchuncks::Int,
)
    stations = values(timetable.stations)

    x = [
        (
            length(
                descending_departure_times(
                    timetable,
                    station,
                    departure_time_min,
                    departure_time_max;
                    sort_desc=false,
                ),
            ),
            station,
        ) for station in stations
    ]

    aim_n_departures = sum(x[1] for x in x) / nchuncks

    chuncks = [Station[] for _ in 1:nchuncks]
    i = 1
    departures_in_chunck = 0
    for (n_deps, station) in x
        # If chunck has enough departures move to next chunck
        if departures_in_chunck > aim_n_departures
            i += 1
            departures_in_chunck = 0
        end
        push!(chuncks[i], station)
        departures_in_chunck += n_deps
    end
    return chuncks
end
