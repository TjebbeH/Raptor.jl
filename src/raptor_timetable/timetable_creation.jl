include("../gtfs/parse.jl")
using .ParseGTFS

using Serialization
using DataFrames

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