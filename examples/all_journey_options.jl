using Raptor

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

# using Logging
# global_logger(ConsoleLogger(Error))
function calculate_all_journeys(timetable)
    stations = sort(collect(values(timetable.stations)), by = station -> station.name);

    for origin in stations
        departure_time_min = date + Time(0)
        departure_time_max = date + Time(23, 59)

        range_query = RangeMcRaptorQuery(origin, departure_time_min, departure_time_max, 5)
        journeys = run_mc_raptor_and_construct_journeys(timetable, range_query)
    end
end
@time calculate_all_journeys(timetable)