using Revise  

using Raptor
import Raptor: get_station, StationAbbreviation
using Dates


import Raptor: create_raptor_timetable
import Raptor: save_timetable
gtfs_dir = joinpath([@__DIR__, "..", "src","gtfs","data","gtfs_nl_2024_05_20"])
date = Date(2024,5,20)
timetable = create_raptor_timetable(gtfs_dir,date);
save_timetable(timetable)

# import Raptor: load_timetable
# date = Date(2024, 5, 20)
# timetable = load_timetable();

origin = "ASN";
destination = "GN"
departure_time = DateTime(2024, 5, 20, 12, 0, 0);

query = McRaptorQuery(origin, destination, departure_time, timetable);

maximum_rounds = 2

# import Logging: Debug, ConsoleLogger, with_logger
# with_logger(ConsoleLogger(stderr, Debug)) do
#     bag_round_stop, round_counter = run_mc_raptor(timetable, query, maximum_rounds);
# end;

bag_round_stop, last_round = run_mc_raptor(timetable, query, maximum_rounds);
bags_to_destination = [bag_round_stop[last_round][s] for s in destination.stops];
for bag in bags_to_destination
    for option in bag.options
        @show option.label
        @show option.from_stop
        @show option.trip.name
    end
end



import Raptor:merge_bags, Stop, Option, Trip,get_stop_time
bag_last_round = bag_round_stop[last_round]

destination_station = timetable.stations["GN"]
to_stops = destination_station.stops
station_bag = merge_bags([bag_last_round[s] for s in to_stops])
to_stop = keys(filter(x -> x[2] == station_bag, bag_last_round)) |> only 

include("../src/utils.jl")
include("../src/raptor_algorithm/journey_structs.jl")

option = station_bag.options[1]
label = option.label
trip = option.trip


legs = JourneyLegs(station_bag.options, to_stop)
if isempty(legs)
    @info "destination $(destination_station) unreachable"
end

journeys = [Journey([leg]) for leg in legs]

