import Raptor: first_arrival_time, last_departure_time
import Raptor: get_timeperiod
import Raptor: get_station, try_to_get_station
import Raptor: get_other_stops_at_station
import Raptor: get_stop_idx_in_route, first_in_route
import Raptor: get_stop_time, StopTime
import Raptor: get_fare
import Raptor: get_earliest_trip

using Test
using Dates

include("../create_test_timetable.jl")
tt = create_test_timetable();
today = Date(2021,10,21)

@test first_arrival_time(tt.trips["t101"]) == today + Time(13)
@test first_arrival_time(tt.trips) == today + Time(13)
@test last_departure_time(tt.trips["t101"]) == today + Time(16,1)
@test last_departure_time(tt.trips) == today + Time(17,1)
@test get_timeperiod(tt.trips) == tt.period

@test get_station("Station 1", tt) == tt.stations["S1"]
@test get_station(tt.stops["s11"], tt) == tt.stations["S1"]
@test try_to_get_station("Station 1", tt) == tt.stations["S1"]
@test try_to_get_station("S1", tt) == tt.stations["S1"]
@test ismissing(try_to_get_station("Non existent station", tt))

@test get_other_stops_at_station(tt.stations["S2"], tt.stops["s21"]) == [tt.stops["s2$s"] for s in 2:3]

@test get_stop_idx_in_route(tt, tt.stops["s22"],tt.routes["r1"]) == 2 

@test first_in_route(tt, tt.routes["r3"], tt.stops["s23"], tt.stops["s72"]) == tt.stops["s23"]
@test first_in_route(tt, tt.routes["r3"], tt.stops["s23"], missing) == tt.stops["s23"]
@test first_in_route(tt, tt.routes["r3"], missing, tt.stops["s72"]) == tt.stops["s72"]

expected_stop_time = StopTime(tt.stops["s31"], today + Time(15), today + Time(15,1),0.0)
@test get_stop_time(tt.trips["t101"], tt.stops["s31"]) == expected_stop_time
@test isnothing(get_stop_time(tt.trips["t101"], tt.stops["s71"]))

@test get_fare(tt.trips["t101"], tt.stops["s42"]) == 0
@test get_fare(tt.trips["t401"], tt.stops["s81"]) == 7

actual_earliest_trip1 = get_earliest_trip(tt, tt.routes["r3"], tt.stops["s23"], today + Time(0))
expected_trip1 = tt.trips["t301"]
@test actual_earliest_trip1 == expected_trip1
actual_earliest_trip2 = get_earliest_trip(tt, tt.routes["r3"], tt.stops["s23"], today + Time(15))
expected_trip2 = tt.trips["t303"]
@test actual_earliest_trip2 == expected_trip2
