using Revise

using Raptor
using Dates


# import Raptor: create_raptor_timetable
# import Raptor: save_timetable
# gtfs_dir = joinpath([@__DIR__, "..", "src","gtfs","data","gtfs_nl_2024_05_20"])
# date = Date(2024,5,20)
# timetable = create_raptor_timetable(gtfs_dir,date);
# save_timetable(timetable)

import Raptor: load_timetable
date = Date(2024, 5, 20)
timetable = load_timetable();

origin = "Vlissingen"
destination = "Akkrum"
departure_time = DateTime(2024, 5, 20, 8, 30, 0);

query = McRaptorQuery(origin, destination, departure_time, timetable);
maximum_rounds = 6;
# using Logging
# global_logger(ConsoleLogger(Warn))
bag_round_stop, last_round = run_mc_raptor(timetable, query, maximum_rounds);

journeys = reconstruct_journeys(query, bag_round_stop, last_round);
display_journeys(journeys)
