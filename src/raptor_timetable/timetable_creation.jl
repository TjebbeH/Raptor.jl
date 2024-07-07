"""Create dict of stops from gtfs stops dataframe"""
function create_stops(gtfs_stops::DataFrame)
    stops = Stop.(
        String.(gtfs_stops.stop_id),
        gtfs_stops.stop_name,
        String.(gtfs_stops.platform_code)
    )
    return Dict(stop.id => stop for stop in stops)
end

"""Get gtfs stops with a certain name"""
function stops_with_stopname(stop_name::String, gtfs_stops::DataFrame)
    return filter(:stop_name => ==(stop_name), gtfs_stops)
end

"""Create station from a row in the gtfs dataframe and gtfs stops"""
function create_station(stationrow::DataFrameRow, gtfs_stops::DataFrame)
    name = stationrow.stop_name
    abbreviation = stationrow.stop_code

    stops_at_station = stops_with_stopname(name, gtfs_stops)

    stops = Stop.(stops_at_station.stop_id, name, stops_at_station.platform_code)
    return Station(abbreviation, name, stops)
end

"""Create dict of stations from gtfs stops"""
function create_stations(gtfs_stops::DataFrame)
    gtfs_stations = select(gtfs_stops, [:stop_name, :stop_code]) |> unique
    return Dict(
        stationrow.stop_code => create_station(stationrow, gtfs_stops)
    for
    stationrow in eachrow(gtfs_stations)
    )
end

"""Get stoptimes with a certain trip_id in gtfs stoptimes dataframe"""
function stop_times_with_trip_id(trip_id::String, gtfs_stop_times::DataFrame)
    return filter(:trip_id => ==(trip_id), gtfs_stop_times)
end

"""Create a trip from a gtfs dataframes and a dict of stops"""
function create_trip(
        triprow::DataFrameRow,
        gtfs_stop_times::DataFrame,
        stops::Dict{String, Stop}
)
    trip_id = triprow.trip_id
    trip_name = triprow.trip_short_name
    trip_formula = triprow.trip_long_name

    stops_in_trip_df = stop_times_with_trip_id(trip_id, gtfs_stop_times)
    sort!(stops_in_trip_df, [:arrival_time])

    stop_times = OrderedDict{String, StopTime}()
    for row in eachrow(stops_in_trip_df)
        stop = stops[row.stop_id]
        stop_times[stop.id] = StopTime(
            stop, row.arrival_time, row.departure_time, 0.0)
    end
    route = Route([st.stop for st in values(stop_times)])

    return Trip(string(trip_id), trip_name, trip_formula, route, stop_times)
end

"""Create trips from gtfs trips, stoptimes and a dict of already parsed stops"""
function create_trips(
        gtfs_trips::DataFrame,
        gtfs_stop_times::DataFrame,
        stops::Dict{String, Stop}
)
    return Dict(
        triprow.trip_id => create_trip(triprow, gtfs_stop_times, stops)
    for
    triprow in eachrow(gtfs_trips)
    )
end

"""Create a dict with footpaths for every combination of stops in a station"""
function create_footpaths(stations::Dict{String, Station}, duration_sec::Number)
    footpaths = Dict()
    for station in values(stations)
        stops = station.stops
        merge!(
            footpaths,
            Dict(
                (stop1.id, stop2.id) => FootPath(stop1, stop2, Second(duration_sec))
            for
            (stop1, stop2) in Iterators.product(stops, stops) if stop1 != stop2
            )
        )
    end
    return footpaths
end

function period(trips::Dict{String, Trip})
    (first_arrival = first_arrival_time(trips), last_departure = last_departure_time(trips))
end

"""Get all indices of a vector of routes that serve stop"""
function get_route_idx_serving_stop(stop::Stop, routes::Vector{Route})
    return findall(route -> stop in route.stops, routes)
end

"""Get the stop index in a vector of stops"""
function get_stop_idx(stop::Stop, stops::Vector{Stop})
    return findall(s -> s == stop, stops) |> only
end

"""Get dict of route indices and the stop index of the stop on the route"""
function get_routes_and_stop_idx(stop::Stop, routes::Vector{Route})
    route_idx = get_route_idx_serving_stop(stop, routes)
    return Dict(routes[idx] => get_stop_idx(stop, routes[idx].stops) for idx in route_idx)
end

"""Create lookup dict to search routes that serve a given stop"""
function create_stop_routes_lookup(stops::Vector{Stop}, routes::Vector{Route})
    return Dict(stop => get_routes_and_stop_idx(stop, routes) for stop in stops)
end

"""Get all trips that travel along a route"""
function get_trips_of_route(trips::Vector{Trip}, route::Route)
    return filter(t -> t.route == route, trips)
end

"""Create a lookup dict to search all routes that travel along a route"""
function create_route_trip_lookup(trips::Vector{Trip}, routes::Vector{Route})
    return Dict(route => get_trips_of_route(trips, route) for route in routes)
end

"""Collect departure times from stop"""
function departures_from_stop(stop::Stop, gtfs_stop_times::DataFrame)
    departures = filter(:stop_id => ==(stop.id), gtfs_stop_times)
    return departures.departure_time
end
"""Collect departures from station"""
function departures_from_station(station::Station, gtfs_stop_times::DataFrame)
    departures = collect(Iterators.flatten(departures_from_stop.(
        station.stops, Ref(gtfs_stop_times))))
    unique!(departures)
    return departures
end

function create_station_departures_lookup(
        stations::Dict{String, Station}, stop_times::DataFrame)
    return Dict(
        station.abbreviation.abbreviation => departures_from_station(station, stop_times)
    for station in values(stations)
    )
end

function create_raptor_timetable(gtfs_timetable::GtfsTimeTable)
    @info "convert gtfs timetable to raptor timetable"

    stops = create_stops(gtfs_timetable.stops)
    stations = create_stations(gtfs_timetable.stops)
    trips = create_trips(gtfs_timetable.trips, gtfs_timetable.stop_times, stops)
    routes = get_routes(trips)
    footpaths = create_footpaths(stations, 2.0 * 60) # hardcode 2 min layovertime
    timeperiod = get_timeperiod(trips)

    collected_routes = collect(values(routes))
    collected_stops = collect(values(stops))
    collected_trips = collect(values(trips))

    station_departures_lookup = create_station_departures_lookup(
        stations, gtfs_timetable.stop_times)
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
        route_trip_lookup,
        station_departures_lookup
    )
end

function create_raptor_timetable(
        directory::String,
        date::Date,
        agencies_in_scope::Vector = ["NS"]
)
    gtfs_timetable = parse_gtfs(directory, date, agencies_in_scope)
    return create_raptor_timetable(gtfs_timetable)
end

function save_timetable(timetable::TimeTable)
    path = joinpath(@__DIR__, "data", "raptor_timetable")
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
