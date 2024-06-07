module RaptorTimeTable

export TimeTable, Stop, Station, Trip, TripStopTime, Route, FootPath
export StationAbbreviation

export create_raptor_timetable, save_timetable, load_timetable
export get_station

export get_stop_idx_in_route, first_in_route
export get_stop_time, get_fare, get_earliest_trip

using DataFrames
using Serialization

include("./timetable_structs.jl")
include("../gtfs/parse.jl")
include("./timetable_functions.jl")

using .ParseGTFS

function create_stops(gtfs_stops::DataFrame)
    """Create dict of stops from gtfs stops dataframe"""
    stops = Stop.(
        String.(gtfs_stops.stop_id),
        gtfs_stops.stop_name,
        String.(gtfs_stops.platform_code)
    )
    return Dict(stop.id => stop for stop in stops)
end

function stops_with_stopname(stop_name::String, gtfs_stops::DataFrame)
    """Get gtfs stops with a certain name"""
    return filter(:stop_name => ==(stop_name), gtfs_stops)
end

function create_station(stationrow::DataFrameRow, gtfs_stops::DataFrame)
    """Create station from a row in the gtfs dataframe and gtfs stops"""
    name = stationrow.stop_name
    abbreviation = stationrow.stop_code

    stops_at_station = stops_with_stopname(name, gtfs_stops)

    stops = Stop.(
        stops_at_station.stop_id,
        name,
        stops_at_station.platform_code,
    )
    return Station(abbreviation, name, stops)
end

function create_stations(gtfs_stops::DataFrame)
    """Create dict of stations from gtfs stops"""
    gtfs_stations = select(gtfs_stops, [:stop_name, :stop_code]) |> unique
    return Dict(
        stationrow.stop_code => create_station(stationrow, gtfs_stops)
        for stationrow in eachrow(gtfs_stations)
    )
end

function stop_times_with_trip_id(trip_id::String, gtfs_stop_times::DataFrame)
    """Get stoptimes with a certain trip_id in gtfs stoptimes dataframe"""
    return filter(:trip_id => ==(trip_id), gtfs_stop_times)
end

function create_trip(triprow::DataFrameRow, gtfs_stop_times::DataFrame, stops::Dict{String,Stop})
    """Create a trip from a gtfs dataframes and a dict of stops"""
    trip_id = triprow.trip_id
    trip_name = triprow.trip_short_name
    trip_formula = triprow.trip_long_name
    route_id = triprow.route_id

    stops_in_trip_df = stop_times_with_trip_id(trip_id, gtfs_stop_times)
    sort!(stops_in_trip_df, :stop_sequence)
    stops_in_trip = [stops[id] for id in stops_in_trip_df.stop_id]

    stop_times = StopTime.(
        stops_in_trip,
        stops_in_trip_df.arrival_time,
        stops_in_trip_df.departure_time,
        0
    )

    route = Route(route_id, stops_in_trip)

    return Trip(string(trip_id), trip_name, trip_formula, route, stop_times)
end


function create_trips(gtfs_trips::DataFrame, gtfs_stop_times::DataFrame, stops::Dict{String,Stop})
    """Create trips from gtfs trips, stoptimes and a dict of already parsed stops"""
    return Dict(
        triprow.trip_id => create_trip(triprow, gtfs_stop_times, stops)
        for triprow in eachrow(gtfs_trips)
    )
end

function create_footpaths(stations::Dict{String,Station}, duration_sec::Number)
    """Create a dict with footpaths for every combination of stops in a station"""
    footpaths = Dict()
    for station in values(stations)
        stops = station.stops
        merge!(
            footpaths, Dict(
                (stop1.id,stop2.id) => FootPath(stop1, stop2, Second(duration_sec))
                for (stop1,stop2) in Iterators.product(stops, stops)
            )
        )
    end
    return footpaths
end

period(trips::Dict{String,Trip}) = (first_arrival=first_arrival_time(trips), last_departure=last_departure_time(trips))


function get_route_idx_serving_stop(stop::Stop, routes::Vector{Route})
    """Get all indices of a vector of routes that serve stop"""
    return findall(route -> stop in route.stops, routes)
end

function get_stop_idx(stop::Stop, stops::Vector{Stop})
    """Get the stop index in a vector of stops"""
    return findall(s -> s == stop, stops) |> only
end

function get_routes_and_stop_idx(stop::Stop, routes::Vector{Route})
    """Get dict of route indices and the stop index of the stop on the route"""
    route_idx = get_route_idx_serving_stop(stop, routes)
    return Dict(routes[idx] => get_stop_idx(stop, routes[idx].stops) for idx in route_idx)
end

function create_stop_routes_lookup(stops::Vector{Stop}, routes::Vector{Route})
    """Create lookup dict to search routes that serve a given stop"""
    return Dict(stop => get_routes_and_stop_idx(stop, routes) for stop in stops)
end

function get_trips_of_route(trips::Vector{Trip}, route::Route)
    """Get all trips that travel along a route"""
    return filter(t -> t.route == route, trips)
end

function create_route_trip_lookup(trips::Vector{Trip}, routes::Vector{Route})
    """Create a lookup dict to search all routes that travel along a route"""
    return Dict(route => get_trips_of_route(trips, route) for route in routes)
end


function create_raptor_timetable(gtfs_timetable::GtfsTimeTable)
    @info "convert gtfs timetable to raptor timetable"

    stops = create_stops(gtfs_timetable.stops)
    stations = create_stations(gtfs_timetable.stops)
    trips = create_trips(gtfs_timetable.trips, gtfs_timetable.stop_times, stops)
    routes = get_routes(trips)
    footpaths = create_footpaths(stations, 2.0*60) # hardcode 2 min layovertime
    timeperiod = get_timeperiod(trips)

    collected_routes = collect(values(routes))
    collected_stops = collect(values(stops))
    collected_trips = collect(values(trips))

    stop_routes_lookup = create_stop_routes_lookup(collected_stops, collected_routes)
    route_trip_lookup = create_route_trip_lookup(collected_trips, collected_routes)

    return TimeTable(
        timeperiod,
        stations,
        stops,
        trips,
        routes,
        footpaths,
        stop_routes_lookup,
        route_trip_lookup
    )
end

function create_raptor_timetable(directory::String, date::Date, agencies_in_scope::Vector = ["NS"])
    gtfs_timetable = parse_gtfs(directory, date, agencies_in_scope)
    return create_raptor_timetable(gtfs_timetable)
end

function save_timetable(timetable::TimeTable)
    path = joinpath(@__DIR__,"data", "raptor_timetable")
    serialize(path, timetable)
end

function save_timetable(timetable::TimeTable, appendix::String)
    path = joinpath([@__DIR__, "data", "raptor_timetable_" * appendix])
    serialize(path, timetable)
end

function load_timetable(filename::String)
    path = joinpath([@__DIR__, "data", filename])
    return deserialize(path)
end

function load_timetable()
    path = joinpath([@__DIR__, "data", "raptor_timetable"])
    return deserialize(path)
end

function get_stop_idx_in_route(timetable :: TimeTable, stop::Stop, route::Route)
    """Look up stop index of stop in route"""
    return timetable.stop_routes_lookup[stop][route]
end

function first_in_route(timetable::TimeTable, route::Route, stop1::Stop, stop2::Stop)
    """Return stop that is first in route (stop1 or stop2)"""
    idx_stop1 = get_stop_idx_in_route(timetable, stop1, route)
    idx_stop2 = get_stop_idx_in_route(timetable, stop2, route)
    if idx_stop1 < idx_stop2
        return stop1
    else
        return stop2
    end
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

end # module


# # To try comment out module start and end
# using Dates
# using Serialization

# # dir = "gtfs_nl_2024_05_20";
# # date = Date(2024,5,20);
# # gtfs_timetable = parse_gtfs(dir, date);
# # serialize("tmp_gtfs", gtfs_timetable)

# gtfs_timetable = deserialize("tmp_gtfs");

# raptor_timetable = create_raptor_timetable(gtfs_timetable);