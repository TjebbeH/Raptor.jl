using Raptor
using Dates
using Logging
using Test

timetable = create_test_timetable();
today = Date(2021, 10, 21)

origin = "S2"
departure_time_min = today + Time(8);
departure_time_max = today + Time(20);

range_query = RangeMcRaptorQuery(origin, departure_time_min, departure_time_max, timetable);
journeys = run_mc_raptor_and_construct_journeys(timetable, range_query);

destination = "S4"
destination_station = try_to_get_station(destination, timetable);

@test length(journeys[destination_station]) == 3
