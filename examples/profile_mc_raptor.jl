using Raptor

using Dates

# import Raptor: create_raptor_timetable
# import Raptor: save_timetable
# gtfs_dir = joinpath([@__DIR__, "..", "src","gtfs","data","gtfs_nl_2024_05_20"])
# date = Date(2024,5,20)

# # gtfs_dir = joinpath([@__DIR__, "..", "src","gtfs","data","gtfs_nl_2024_06_19"])
# # date = Date(2024,6,19)

# timetable = create_raptor_timetable(gtfs_dir,date);
# save_timetable(timetable)

import Raptor: load_timetable
date = Date(2024, 5, 20)
# date = Date(2024, 6, 19)
timetable = load_timetable();

origin = "VS"
destination = "AKM"
departure_time = date + Time(9);

using BenchmarkTools
query = McRaptorQuery(origin, departure_time, timetable);

@btime bag_round_stop, last_round = run_mc_raptor(timetable, query);

using Profile, PProf
Profile.clear()
@profile run_mc_raptor(timetable, query);
pprof()

Profile.Allocs.clear()
Profile.Allocs.@profile run_mc_raptor(timetable, query);
PProf.Allocs.pprof()
