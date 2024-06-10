import Raptor: parse_gtfs
import Raptor: create_stops, Stop
import Raptor: create_stations, stops_with_stopname, Station
import Raptor: create_trips, Trip, StopTime, Route
import Raptor: create_footpaths, FootPath

using Dates
using DataFrames

date = Date(2021,10,21)
path = joinpath([@__DIR__,"..","gtfs","testdata","gtfs_test"])
gtfs_timetable = parse_gtfs(path, date);

# Test if correct stops are created
stops = create_stops(gtfs_timetable.stops)
expected_stops = Dict(
    "2473089" => Stop("2473089", "Station A", "2"),
    "2473090" => Stop("2473090", "Station B", "?"),
)
@test stops == expected_stops

# Test if stops_with_stopname selects correct rows from dataframe
stops_at_station_A = stops_with_stopname("Station A", gtfs_timetable.stops)
expected_stops_at_station_A = DataFrame(
    stop_id=["2473089"],
    stop_name = ["Station A"], 
    stop_code=["STA"],
    platform_code=["2"]
)
@test stops_at_station_A == expected_stops_at_station_A

# Test if correct stations are created
stations = create_stations(gtfs_timetable.stops)
expected_stations = Dict(
    "STA" => Station("STA", "Station A", [Stop("2473089", "Station A", "2")]),
    "STB" => Station("STB", "Station B", [Stop("2473090", "Station B", "?")]),
)
@test stations == expected_stations

# Test if correct trips are created
trips = create_trips(gtfs_timetable.trips, gtfs_timetable.stop_times, stops)
expected_route = Route(
    "67394",
    [Stop("2473089", "Station A", "2"), Stop("2473090", "Station B", "?")]
)
expected_stop_times_1 = [
    StopTime(
        Stop("2473089", "Station A", "2"),
        DateTime(2021,10,21,11,58,0),
        DateTime(2021,10,21,12,0,0),
        0,
    ),
    StopTime(
        Stop("2473090", "Station B", "?"),
        DateTime(2021,10,21,14,0,0),
        DateTime(2021,10,21,14,0,0),
        0,
    ),
]
expected_stop_times_2 = [
    StopTime(
        Stop("2473089", "Station A", "2"),
        DateTime(2021,10,21,23,50,0),
        DateTime(2021,10,21,23,51,0),
        0,
    ),
    StopTime(
        Stop("2473090", "Station B", "?"),
        DateTime(2021,10,22,0,30,0),
        DateTime(2021,10,22,0,32,0),
        0,
    ),
]
expected_trips = Dict(
    "191659463" => Trip("191659463", "525", "Intercity", expected_route, expected_stop_times_1),
    "191659464" => Trip("191659464", "527", "Intercity", expected_route, expected_stop_times_2)
)
@test trips == expected_trips

# Test if foothpaths are correctly created
# input stations (added one platform at station A wrt gtfs stations)
stop_STA_platform2 = Stop("2473089", "Station A", "2")
stop_STA_platform3 = Stop("2473088", "Station A", "3")
walktime = 5.0*60
input_stations = Dict(
    "STA" => Station("STA", "Station A", [stop_STA_platform2,stop_STA_platform3]),
    "STB" => Station("STB", "Station B", [Stop("2473090", "Station B", "?")]),
)
foothpaths = create_footpaths(input_stations, walktime)
expected_footpaths = Dict(
    (stop_STA_platform2.id, stop_STA_platform3.id) =>
    FootPath(stop_STA_platform2, stop_STA_platform3, Second(walktime)),
    (stop_STA_platform3.id, stop_STA_platform2.id) =>
    FootPath(stop_STA_platform3, stop_STA_platform2, Second(walktime))
)
@test foothpaths == expected_footpaths