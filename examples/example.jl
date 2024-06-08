include("../src/mcraptor.jl")
using .McRaptor

import .McRaptor: get_station, StationAbbreviation

using Dates

# import .McRaptor: create_raptor_timetable
# import .McRaptor: save_timetable
# gtfs_dir = "gtfs_nl_2024_05_20"
# date = Date(2024,5,20)
# timetable = create_raptor_timetable(gtfs_dir,date);
# save_timetable(timetable)

import .McRaptor: load_timetable 
date = Date(2024,5,20)
timetable = load_timetable();


origin = get_station(StationAbbreviation("ASN"), timetable);
destination = get_station(StationAbbreviation("GN"), timetable);
departure_time = DateTime(2024,5,20,12,0,0);

query = McRaptorQuery(origin, destination, departure_time);

maximum_rounds = 3

bag_round_stop, round_counter = run_mc_raptor(timetable, query, maximum_rounds);


resulting_bags = [bag_round_stop[end][s] for s in destination.stops]
resulting_labels_first_bag = [o.label for o in resulting_bags[1].options]
resulting_trips_first_bag = [o.trip.name for o in resulting_bags[1].options]
resulting_from_stop_first_bag = ["$(o.from_stop.station_name)-$(o.from_stop.platform_code)" for o in resulting_bags[1].options]
