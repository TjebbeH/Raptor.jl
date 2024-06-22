using Distributed
addprocs(4)
@show nworkers()

@everywhere using Raptor

using Dates

import Raptor: create_raptor_timetable
import Raptor: save_timetable
gtfs_dir = joinpath([@__DIR__, "..", "src","gtfs","data","gtfs_nl_2024_05_20"])
date = Date(2024,5,20)
timetable = create_raptor_timetable(gtfs_dir,date);
save_timetable(timetable)

import Raptor: load_timetable
date = Date(2024,5,20)
# date = Date(2024, 6, 19)
timetable = load_timetable();
maximum_number_of_transfers = 5

@time calculate_all_journeys(timetable, date, maximum_number_of_transfers);
