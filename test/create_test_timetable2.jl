import Raptor: TimeTable, Stop, Trip, StopTime, Route, Station
import Raptor: create_footpaths
import Raptor: create_stop_routes_lookup, create_route_trip_lookup

using Dates

"""Create timetable for testing"""
function create_test_timetable2()
    list_of_stops = [
        Stop("HT_1", "HT", "1"),
        
        Stop("UT_1", "UT", "1"),
        Stop("UT_2", "UT", "2"),
        
        Stop("ASA_1", "ASA", "1"),
        Stop("ASA_2", "ASA", "2"),
        
        Stop("ASB_1", "ASB", "1"),
        Stop("ASB_2", "ASB", "2"),

        Stop("AC_1", "AC", "1")
    ]
    stops = Dict(s.id => s for s in list_of_stops)

    list_of_stations = [
        Station("HT", "Den Bosch", [Stop("HT_1", "HT", "1")]),
        Station("UT", "Utrecht", [Stop("UT_1", "UT", "1"), Stop("UT_2", "UT", "2")]),
        Station("ASA", "Amsterdam Sloterdijk", [Stop("ASA_1", "ASA", "1"), Stop("ASA_2", "ASA", "2")]),
        Station("ASB", "Amsterdam Bijlmer Arena", [Stop("ASB_1", "ASB", "1"), Stop("ASB_2", "ASB", "2")]),
        Station("AC", "Amsterdam Centraal", [Stop("AC_1", "AC", "1")])
    ]
    stations = Dict(s.abbreviation => s for s in list_of_stations)

    list_of_routes = [
        Route("r1", [stops[id] for id in ["HT_1", "UT_1", "ASA_1"]]),
        Route("r2", [stops[id] for id in ["ASA_2", "ASB_1", "AC_1"]]),
        Route("r3", [stops[id] for id in ["UT_2", "ASB_2"]]),
    ]
    routes = Dict(r.id => r for r in list_of_routes)

    today = Date(2021, 10, 21)
    trip101 = Trip(
        "t101",
        "101",
        "IC",
        routes["r1"],
        Dict(
            "HT_1" => StopTime(stops["HT_1"], today + Time(9), today + Time(9, 1), 0.0),
            "UT_1" => StopTime(stops["UT_1"], today + Time(10), today + Time(10, 1), 0.0),
            "ASA_1" => StopTime(stops["ASA_1"], today + Time(11), today + Time(11, 1), 0.0),
        ),
    )
    trip201 = Trip(
        "t201",
        "201",
        "IC",
        routes["r2"],
        Dict(
            "ASA_2" =>
                StopTime(stops["ASA_2"], today + Time(11, 15), today + Time(11, 16), 0.0),
            "ASB_1" =>
                StopTime(stops["ASB_1"], today + Time(12), today + Time(12,1), 0.0),
            "AC_1" =>
                StopTime(stops["AC_1"], today + Time(13), today + Time(13,1), 0.0),
        ),
    )
    trip301 = Trip(
        "t301",
        "301",
        "Sprinter",
        routes["r3"],
        Dict(
            "UT_2" => StopTime(stops["UT_2"], today + Time(10), today + Time(10,5), 0.0),
            "ASB_2" => StopTime(stops["ASB_2"], today + Time(11), today + Time(11, 1), 0.0),
        ),
    )
    list_of_trips = [trip101, trip201, trip301]
    trips = Dict(t.id => t for t in list_of_trips)

    # create_footpaths is tested so we use it here assuming it works
    footpaths = create_footpaths(stations, 2.0 * 60)

    stop_routes_lookup = create_stop_routes_lookup(list_of_stops, list_of_routes)
    route_trip_lookup = create_route_trip_lookup(list_of_trips, list_of_routes)

    station_departures_lookup = Dict(
        "HT" => [today + Time(9,1)],
        "UT" => [today + Time(10, 1), today + Time(10, 5)],
        "ASA" => [today + Time(11, 1), today + Time(11, 16)],
        "ASB" => [today + Time(11, 1), today + Time(12, 1)],
        "AC" => [today + Time(13, 1)],
    )

    period = (first_arrival=today + Time(9,1), last_departure=today + Time(13, 1))

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
