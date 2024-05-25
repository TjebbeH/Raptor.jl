module RaptorTimeTable

export TimeTable, Stop, Station, Trip, TripStopTime, Route, FootPath
export StationAbbreviation

export create_raptor_timetable, save_timetable, load_timetable
export get_station

using DataFrames
using Serialization

include("./timetable_structs.jl")
include("../gtfs/parse.jl")
include("./timetable_functions.jl")

using .ParseGTFS

function create_stops(gtfs_stops::DataFrame)
    stops = Stop.(
        String.(gtfs_stops.stop_id),
        gtfs_stops.stop_name,
        String.(gtfs_stops.platform_code)
    )
    return Dict(stop.id => stop for stop in stops)
end

function stops_with_stopname(stop_name::String, gtfs_stops::DataFrame)
    return filter(:stop_name => ==(stop_name), gtfs_stops)
end

function create_station(stationrow::DataFrameRow, gtfs_stops::DataFrame)
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
    gtfs_stations = select(gtfs_stops, [:stop_name, :stop_code]) |> unique
    return Dict(
        stationrow.stop_code => create_station(stationrow, gtfs_stops)
        for stationrow in eachrow(gtfs_stations)
    )
end

function create_route(route_id::String, stop_times::Vector{StopTime})
    return Route(route_id, [stop_time.stop for stop_time in stop_times])
end

function stop_times_with_trip_id(trip_id::String, gtfs_stop_times::DataFrame)
    return filter(:trip_id => ==(trip_id), gtfs_stop_times)
end

function create_trip(triprow::DataFrameRow, gtfs_stop_times::DataFrame, stops::Dict{String,Stop})
    trip_id = triprow.trip_id
    trip_name = triprow.trip_short_name
    trip_formula = triprow.trip_long_name
    route_id = triprow.route_id

    stops_in_trip_df = stop_times_with_trip_id(trip_id, gtfs_stop_times)
    sort!(stops_in_trip_df, :stop_sequence)

    stop_times = StopTime.(
        [stops[id] for id in stops_in_trip_df.stop_id],
        stops_in_trip_df.arrival_time,
        stops_in_trip_df.departure_time,
        0
    )

    route = create_route(route_id, stop_times)
    return Trip(string(trip_id), stop_times, trip_name, trip_formula, route)
end


function create_trips(gtfs_trips::DataFrame, gtfs_stop_times::DataFrame, stops::Dict{String,Stop})
    return Dict(
        triprow.trip_id => create_trip(triprow, gtfs_stop_times, stops)
        for triprow in eachrow(gtfs_trips)
    )
end

function create_footpaths(stops::Dict{String,Stop}, duration_sec::Rational)
    return Dict(
        (i,j) => FootPath(stops[i],stops[j], duration_sec)
        for (i,j) in Iterators.product(keys(stops),keys(stops))
    )
end

period(trips::Dict{String,Trip}) = (first_arrival=first_arrival_time(trips), last_departure=last_departure_time(trips))

function create_raptor_timetable(gtfs_timetable::GtfsTimeTable)
    @info "convert to raptor timetable"

    stops = create_stops(gtfs_timetable.stops)
    stations = create_stations(gtfs_timetable.stops)
    trips = create_trips(gtfs_timetable.trips, gtfs_timetable.stop_times, stops)
    routes = get_routes(trips)
    footpaths = create_footpaths(stops, 2*60) # hardcode 2 min layovertime
    timeperiod = get_timeperiod(trips)

    return TimeTable(
        timeperiod,
        stations,
        stops,
        trips,
        routes,
        footpaths
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

end # module


# using Dates
# using Serialization

# dir = "gtfs_nl_2024_05_20";
# date = Date(2024,5,20);
# gtfs_timetable = parse_gtfs(dir, date);
# serialize("tmp_gtfs", gtfs_timetable)

# using .RaptorTimeTable
# gtfs_timetable = deserialize("tmp_gtfs")


# part_gtfs_trips = first(gtfs_timetable.trips, 5)

# stops = create_stops(gtfs_timetable.stops)
# trips = create_trips(part_gtfs_trips, gtfs_timetable.stop_times,stops)

# function first_arrival_time(trip::Trip)
#     return minimum([stoptime.arrival_time for stoptime in trip.stop_times])
# end

# function first_arrival_time(trips::Dict{String,Trip})
#     return minimum([first_arrival_time(trip) for trip in values(trips)])
# end

# function last_departure_time(trip::Trip)
#     return maximum([stoptime.departure_time for stoptime in trip.stop_times])
# end

# function last_departure_time(trips::Dict{String,Trip})
#     return maximum([last_departure_time(trip) for trip in values(trips)])
# end


# get_timeperiod(trips::Dict{String,Trip}) = (first_arrival_time(trips), last_departure_time(trips))
