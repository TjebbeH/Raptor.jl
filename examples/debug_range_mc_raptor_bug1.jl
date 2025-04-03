using Raptor
using Logging
using Dates
import Raptor: is_transfer
import Raptor: Journey
import Raptor: descending_departure_times
import Raptor: reconstruct_journeys_to_all_destinations!
import Raptor.last_legs
import Raptor.one_step_journey_reconstruction
import Raptor.merge_bags
import Raptor.initialize_bag_round_stop

logger = ConsoleLogger(stderr, Debug)

filename = "gtfs_nl_2024_07_01"
# gtfs_dir = joinpath([@__DIR__, "..", "data", "gtfs", filename])
# date = Date(2024, 7, 1)

# gtfs_timetable = parse_gtfs(gtfs_dir, date, ["NS"])

# timetable = create_raptor_timetable(gtfs_dir, date);
# print("number of stations:",length(timetable.stations))
# save_timetable(timetable, filename)

date = Date(2024, 7, 1)
timetable = load_timetable(filename)
journeys = Dict()
for origin in ["BD"]
    departure_time_min = date + Time(21, 50)
    departure_time_max = date + Time(22, 20)

    range_query = RangeMcRaptorQuery(
        origin, departure_time_min, departure_time_max, timetable
    )
    journeys[origin] = @time run_mc_raptor_and_construct_journeys(timetable, range_query)
end

println("Nr of journeys from BD to AC: ", length(journeys["BD"]["AC"]))

function is_wrong_journey(journey)
    if journey.legs[end].to_label.number_of_trips !=
        length(filter(!is_transfer, journey.legs))
        return true
    else
        return false
    end
end

#filter(is_wrong_journey, journeys["VS"]["WP"])

# Where does the number of transfers not correspond to the number of transfer stations?
wrong_journeys = []
for (origin, journeys_from_origin) in journeys
    for (destination, journeys_od) in journeys_from_origin
        for journey in journeys_od
            if journey.legs[end].to_label.number_of_trips !=
                length(filter(!is_transfer, journey.legs))
                push!(wrong_journeys, (origin, destination, journey))
            end
        end
    end
end
wrong_journeys

for example_journey in wrong_journeys
    print(example_journey[1], " ", example_journey[2], "\n")
    for leg in example_journey[3].legs
        print(leg, " ", leg.to_label, "\n")
    end
    print("\n\n")
end

bag_round_stop_list_dict = Dict()
for origin in ["BD"]
    departure_time_min = date + Time(21)
    departure_time_max = date + Time(21, 59)

    range_query = RangeMcRaptorQuery(
        origin, departure_time_min, departure_time_max, timetable
    )
    origin_station = range_query.origin
    departure_time_min = range_query.departure_time_min
    departure_time_max = range_query.departure_time_max
    maximum_transfers = range_query.maximum_transfers

    # debug the reconstruction part, what are the bags that we get?
    journeys = Dict{String,Vector{Journey}}()
    departure_times_from_origin = descending_departure_times(
        timetable, origin_station, departure_time_min, departure_time_max
    )
    bag_round_stop_list_dict[origin] = []
    last_round_bag = nothing
    for departure in departure_times_from_origin
        @info "query for $departure"
        query = McRaptorQuery(origin_station, departure, maximum_transfers)
        bag_round_stop, last_round = run_mc_raptor(timetable, query, last_round_bag)
        push!(bag_round_stop_list_dict[origin], (bag_round_stop, last_round))
        last_round_bag = deepcopy(bag_round_stop[last_round])
        reconstruct_journeys_to_all_destinations!(
            journeys, query, timetable, bag_round_stop, last_round
        )
        println(departure, "\t", last_round)
        println(
            "Nr of wrong options: ", length(filter(is_wrong_journey, journeys["OBD"])), "\n"
        )
    end
end

destinations = [timetable.stations[s] for s in ["BD", "RTD", "AC"]]

for (bag_round_stop, last_round) in bag_round_stop_list_dict["BD"]
    print("Last round: ", last_round, "\n")
    for i in 1:last_round
        println("Round $i")
        bag_last_round = bag_round_stop[i]
        for destination in destinations
            println("Labels for $(destination.name)")
            to_stops = destination.stops
            station_bag = merge_bags([bag_last_round[s] for s in to_stops])

            for option in station_bag.options
                print("\t", option.from_stop, " ", option.label, "\n")
            end
        end
    end
end

journeys_wp = last_legs(bag_last_round)
journeys_wp[4].legs[end].to_label

journeys_test = [journeys_wp[4]]
for i in 1:(last_round * 2) #times two because for every round we have train trips and footpaths
    journeys_test = one_step_journey_reconstruction(
        journeys_test, origin.stops, bag_last_round
    )
    print("Reconstruction round ", i, "\n")
    for j in journeys_test
        for leg in j.legs
            print(leg, " ", leg.to_label.number_of_trips, "\n")
        end
    end
end
