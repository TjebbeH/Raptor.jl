using Raptor
using Revise

using Dates
using BenchmarkTools
using Profile, PProf

gtfs_dir = joinpath([@__DIR__, "..", "data", "gtfs", "gtfs_nl_2024_07_01"])
date = Date(2024, 7, 1)
timetable = create_raptor_timetable(gtfs_dir, date);
save_timetable(timetable)

# date = Date(2024, 7, 1)
# timetable = load_timetable();

origin = "VS"
departure_time = date + Time(9);

query = McRaptorQuery(origin, departure_time, timetable);
bag_round_stop, last_round = @btime run_mc_raptor(timetable, query);

Profile.clear()
@profile run_mc_raptor(timetable, query);
pprof()

Profile.Allocs.clear()
Profile.Allocs.@profile run_mc_raptor(timetable, query);
PProf.Allocs.pprof()
