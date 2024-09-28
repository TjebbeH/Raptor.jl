import Raptor: first_arrival_time, last_departure_time
import Raptor: get_timeperiod
import Raptor: get_station, try_to_get_station
import Raptor: get_other_stops_at_station
import Raptor: get_stop_idx_in_route, first_in_route
import Raptor: get_stop_time, StopTime
import Raptor: get_fare
import Raptor: get_earliest_trip
import Raptor: descending_departure_times

using Test
using Dates

# include("../create_test_timetable.jl")
tt = create_test_timetable();
today = Date(2021, 10, 21)

@test first_arrival_time(tt.trips["t101"]) == today + Time(13)
@test first_arrival_time(tt.trips) == today + Time(13)
@test last_departure_time(tt.trips["t101"]) == today + Time(17, 1)
@test last_departure_time(tt.trips) == today + Time(17, 1)
@test get_timeperiod(tt.trips) == tt.period

@test get_station("Station 1", tt) == tt.stations["S1"]
@test get_station(tt.stops["s11"], tt) == tt.stations["S1"]
@test try_to_get_station("Station 1", tt) == tt.stations["S1"]
@test try_to_get_station("S1", tt) == tt.stations["S1"]
@test ismissing(try_to_get_station("Non existent station", tt))

@test get_other_stops_at_station(tt.stations["S2"], tt.stops["s21"]) ==
    [tt.stops["s2$s"] for s in 2:3]
@test get_stop_idx_in_route(tt, tt.stops["s22"], tt.routes["r1"]) == 2

@test first_in_route(tt, tt.routes["r3"], tt.stops["s22"], tt.stops["s72"]) ==
    tt.stops["s22"]
@test first_in_route(tt, tt.routes["r3"], tt.stops["s22"], missing) == tt.stops["s22"]
@test first_in_route(tt, tt.routes["r3"], missing, tt.stops["s72"]) == tt.stops["s72"]

expected_stop_time = StopTime(tt.stops["s31"], today + Time(15), today + Time(15, 1), 0.0)
@test get_stop_time(tt.trips["t101"], tt.stops["s31"]) == expected_stop_time
@test isnothing(get_stop_time(tt.trips["t101"], tt.stops["s71"]))

@test get_fare(tt.trips["t101"], tt.stops["s42"]) == 0
@test get_fare(tt.trips["t401"], tt.stops["s81"]) == 7

actual_earliest_trip1, actual_departure_time1 = get_earliest_trip(
    tt, tt.routes["r3"], tt.stops["s22"], today + Time(0)
)
expected_trip1 = tt.trips["t301"]
expected_departure_time1 = today + Time(14, 1)
@test actual_earliest_trip1 == expected_trip1
@test actual_departure_time1 == expected_departure_time1

actual_earliest_trip2, actual_departure_time2 = get_earliest_trip(
    tt, tt.routes["r3"], tt.stops["s22"], today + Time(15)
)
expected_trip2 = tt.trips["t303"]
expected_departure_time2 = today + Time(16, 1)
@test actual_earliest_trip2 == expected_trip2
@test actual_departure_time2 == expected_departure_time2

t0 = today + Time(14)
t1 = today + Time(18)
expected_departures = [today + Time(16, 1), today + Time(14, 1)]
@test descending_departure_times(tt, tt.stations["S2"], t0, t1) == expected_departures
