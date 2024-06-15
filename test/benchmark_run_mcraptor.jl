using Raptor
using Dates
using BenchmarkTools

include("./create_test_timetable.jl")
timetable = create_test_timetable();
today = Date(2021, 10, 21)


origin = "S2"
destination = "S4"
departure_time = today + Time(13, 15);

query = McRaptorQuery(origin, destination, departure_time, timetable);

maximum_rounds = 5
@benchmark bag_round_stop, last_round = run_mc_raptor(timetable, query, maximum_rounds)
