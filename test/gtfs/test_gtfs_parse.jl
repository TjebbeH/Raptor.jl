
import Raptor: GtfsData, GtfsTimeTable
import Raptor: read_gtfs_csv
import Raptor: parse_gtfs_agencies, parse_gtfs_routes, parse_gtfs_trips
import Raptor: parse_gtfs_stop_times, parse_gtfs_stops
import Raptor: parse_gtfs

using Test
using Dates
using DataFrames

date = Date(2021, 10, 21)
path = joinpath([@__DIR__, "testdata", "gtfs_test"])
gtfs_data = GtfsData(path, date)

# Test if read_gtfs_csv returns something
@test !isempty(read_gtfs_csv(gtfs_data, "agency.txt"))

# Test if correct agency_id is found
expected_agencies_ids = ["IFF:NS"]
agencies = parse_gtfs_agencies(gtfs_data, ["NS"])
@test agencies.agency_id == expected_agencies_ids

# Test if correct route_id is found
expected_route_ids = ["67394"]
routes = parse_gtfs_routes(gtfs_data, expected_agencies_ids)
@test routes.route_id == expected_route_ids

# Test if trips are correctly parsed
trips = parse_gtfs_trips(gtfs_data, expected_route_ids)
@test trips.route_id == ["67394", "67394"]
@test trips.trip_id == ["191659463", "191659464"]
@test trips.trip_short_name == ["525", "527"]
@test trips.trip_long_name == ["Intercity", "Intercity"]
@test trips.date == [date, date]

#Test if stoptimes are correctly parsed
stop_times = parse_gtfs_stop_times(gtfs_data, trips)
expected_arrival_times = [
    DateTime(2021, 10, 21, 11, 58, 0),
    DateTime(2021, 10, 21, 14, 0, 0),
    DateTime(2021, 10, 21, 23, 50, 0),
    DateTime(2021, 10, 22, 0, 30, 0),
]
expected_departure_times = [
    DateTime(2021, 10, 21, 12, 0, 0),
    DateTime(2021, 10, 21, 14, 0, 0),
    DateTime(2021, 10, 21, 23, 51, 0),
    DateTime(2021, 10, 22, 0, 32, 0),
]
@test stop_times.trip_id == repeat(["191659463", "191659464"], inner = 2)
@test stop_times.stop_id == repeat(["2473089", "2473090"], outer = 2)
@test stop_times.arrival_time == expected_arrival_times
@test stop_times.departure_time == expected_departure_times
stop_ids_in_scope = string.(unique(stop_times.stop_id))
@test stop_ids_in_scope == ["2473089", "2473090"]

# Test if stops are correctly parsed
stops = parse_gtfs_stops(gtfs_data, stop_ids_in_scope)
@test stops.stop_id == ["2473089", "2473090"]
@test stops.stop_name == ["Station A", "Station B"]
@test stops.stop_code == ["STA", "STB"]
@test stops.platform_code == ["2", "?"]

# Test if total parse function also runs without an error
# and results in dataframes with exptected number of rows
gtfs_timetable = parse_gtfs(path, date)
@test nrow(gtfs_timetable.trips) == 2
@test nrow(gtfs_timetable.stop_times) == 4
@test nrow(gtfs_timetable.stops) == 2
