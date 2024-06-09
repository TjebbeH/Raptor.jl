using Revise  

using Raptor
import Raptor: get_station, StationAbbreviation
using Dates


import Raptor: create_raptor_timetable
import Raptor: save_timetable
gtfs_dir = "gtfs_nl_2024_05_20"
date = Date(2024,5,20)
timetable = create_raptor_timetable(gtfs_dir,date);
save_timetable(timetable)

import Raptor: load_timetable
date = Date(2024, 5, 20)
timetable = load_timetable();

origin = get_station(StationAbbreviation("ASN"), timetable);
destination = get_station(StationAbbreviation("GN"), timetable);
departure_time = DateTime(2024, 5, 20, 12, 0, 0);

query = McRaptorQuery(origin, destination, departure_time);

maximum_rounds = 3

import Logging: Debug, ConsoleLogger, with_logger

with_logger(ConsoleLogger(stderr, Debug)) do
    bag_round_stop, round_counter = run_mc_raptor(timetable, query, maximum_rounds);
end;

bag_round_stop, round_counter = run_mc_raptor(timetable, query, maximum_rounds);
bags_to_destination = [bag_round_stop[end][s] for s in destination.stops]
for bag in bags_to_destination
    for option in bag.options
        @show option.label
        @show option.from_stop
        @show option.trip.name
    end
end
