import Raptor: TimeTable, Stop, Trip, StopTime, Route, Station
import Raptor: create_footpaths
import Raptor: create_stop_routes_lookup, create_route_trip_lookup

using Dates

"""Create timetable for testing"""
function create_test_timetable()
    list_of_stops = [
        Stop("s11", "Station 1", "1"),
        Stop("s21", "Station 2", "1"),
        Stop("s22", "Station 2", "2"),
        Stop("s23", "Station 2", "3"),
        Stop("s31", "Station 3", "1"),
        Stop("s41", "Station 4", "1"),
        Stop("s42", "Station 4", "2"),
        Stop("s43", "Station 4", "3"),
        Stop("s51", "Station 5", "1"),
        Stop("s61", "Station 6", "1"),
        Stop("s71", "Station 7", "1"),
        Stop("s72", "Station 7", "2"),
        Stop("s81", "Station 8", "1"),
    ]
    stops = Dict(s.id => s for s in list_of_stops)

    list_of_stations = [
        Station("S1", "Station 1", [Stop("s11", "Station 1", "1")]),
        Station("S2", "Station 2", [Stop("s2$i", "Station 2", "$i") for i in 1:3]),
        Station("S3", "Station 3", [Stop("s31", "Station 3", "1")]),
        Station("S4", "Station 4", [Stop("s4$i", "Station 4", "$i") for i in 1:3]),
        Station("S5", "Station 5", [Stop("s51", "Station 5", "1")]),
        Station("S6", "Station 6", [Stop("s61", "Station 6", "1")]),
        Station("S7", "Station 7", [Stop("s7$i", "Station 7", "$i") for i in 1:2]),
        Station("S8", "Station 8", [Stop("s81", "Station 8", "1")]),
    ]
    stations = Dict(s.abbreviation.abbreviation => s for s in list_of_stations)

    list_of_routes = [
        Route("r1", [stops[id] for id in ["s11", "s22", "s31", "s43", "s51"]]),
        Route("r2", [stops[id] for id in ["s71", "s42", "s61"]]),
        Route("r3", [stops[id] for id in ["s22", "s72"]]),
        Route("r4", [stops[id] for id in ["s21", "s81", "s41"]]),
    ]
    routes = Dict(r.id => r for r in list_of_routes)

    today = Date(2021, 10, 21)
    trip101 = Trip(
        "t101",
        "101",
        "Sprinter",
        routes["r1"],
        Dict(
            "s11" => StopTime(stops["s11"], today + Time(13), today + Time(13, 1), 0.0),
            "s22" => StopTime(stops["s22"], today + Time(14), today + Time(14, 1), 0.0),
            "s31" => StopTime(stops["s31"], today + Time(15), today + Time(15, 1), 0.0),
            "s43" => StopTime(stops["s43"], today + Time(16), today + Time(16, 1), 0.0),
            "s51" => StopTime(stops["s51"], today + Time(17), today + Time(17, 1), 0.0),
        ),
    )
    trip201 = Trip(
        "t201",
        "201",
        "Sprinter",
        routes["r2"],
        Dict(
            "s71" =>
                StopTime(stops["s71"], today + Time(15, 15), today + Time(15, 16), 0.0),
            "s42" =>
                StopTime(stops["s42"], today + Time(15, 45), today + Time(15, 46), 0.0),
            "s61" =>
                StopTime(stops["s61"], today + Time(16, 15), today + Time(16, 16), 0.0),
        ),
    )
    trip301 = Trip(
        "t301",
        "301",
        "Sprinter",
        routes["r3"],
        Dict(
            "s22" => StopTime(stops["s22"], today + Time(14), today + Time(14, 1), 0.0),
            "s72" => StopTime(stops["s72"], today + Time(15), today + Time(15, 1), 0.0),
        ),
    )
    trip303 = Trip(
        "t303",
        "303",
        "Sprinter",
        routes["r3"],
        Dict(
            "s22" => StopTime(stops["s22"], today + Time(16), today + Time(16, 1), 0.0),
            "s72" => StopTime(stops["s72"], today + Time(17), today + Time(17, 1), 0.0),
        ),
    )
    trip401 = Trip(
        "t401",
        "401",
        "ICD",
        routes["r4"],
        Dict(
            "s21" => StopTime(stops["s21"], today + Time(14), today + Time(14, 1), 0.0),
            "s81" =>
                StopTime(stops["s81"], today + Time(14, 30), today + Time(14, 31), 7.0),
            "s41" => StopTime(stops["s41"], today + Time(15), today + Time(15, 1), 0.0),
        ),
    )
    list_of_trips = [trip101, trip201, trip301, trip303, trip401]
    trips = Dict(t.id => t for t in list_of_trips)

    # create_footpaths is tested so we use it here assuming it works
    footpaths = create_footpaths(stations, 2.0 * 60)

    stop_routes_lookup = create_stop_routes_lookup(list_of_stops, list_of_routes)
    route_trip_lookup = create_route_trip_lookup(list_of_trips, list_of_routes)

    station_departures_lookup = Dict(
        "S1" => [today + Time(13, 1)],
        "S2" => [today + Time(14, 1), today + Time(16, 1)],
        "S3" => [today + Time(15, 1)],
        "S4" => [today + Time(15, 1), today + Time(16, 1), today + Time(15, 46)],
        "S5" => [today + Time(17, 1)],
        "S6" => [today + Time(16, 16)],
        "S7" => [today + Time(15, 16), today + Time(15, 1), today + Time(17, 1)],
        "S8" => [today + Time(14, 31)],
    )

    period = (first_arrival=today + Time(13), last_departure=today + Time(17, 1))

    return TimeTable(
        period,
        stations,
        stops,
        trips,
        routes,
        footpaths,
        stop_routes_lookup,
        route_trip_lookup,
        station_departures_lookup,
    )
end
