using Raptor

using Dates
using  Logging

import Raptor:Journey
import Raptor:descending_departure_times

import Raptor:remove_duplicate_journeys!

# gtfs_dir = joinpath([@__DIR__, "..", "data", "gtfs", "visum_2025_02_01"])
# date = Date(2025, 2, 1)
# timetable = create_raptor_timetable(gtfs_dir, date);
# save_timetable(timetable, "raptor_timetable_visum_2025_02_01")


date = Date(2025, 2, 1)
timetable = load_timetable("raptor_timetable_visum_2025_02_01")

origin = "BD"
departure_time_min = date + Time(21, 50)
departure_time_max = date + Time(22, 00)

range_query = RangeMcRaptorQuery(
    origin, departure_time_min, departure_time_max, timetable
)
journeys_range = run_mc_raptor_and_construct_journeys(timetable, range_query)
print(journeys_range["AC"])


println(journeys_range["AC"]) 
for (i, option) in enumerate(journeys_range["AC"])
    println("Option $i")
    for leg in option.legs
        print(leg, " ", leg.to_label, "\n")
    end
    println()
end

println()


function reconstruct_journeys_to_all_destinations2!(
    journeys_to_destination::Dict{String,Vector{Journey}},
    origin,
    timetable,
    bag_round_stop,
    last_round,
)
    destination_stations = Iterators.filter(!isequal(origin), values(timetable.stations))
    for destination in destination_stations
        new_journeys = reconstruct_journeys(
            origin, destination, bag_round_stop, last_round
        )
        if destination.abbreviation=="AC"
            println("New journeys to AC:")
            println(new_journeys)
        end
        if destination.abbreviation in keys(journeys_to_destination)
            append!(
                journeys_to_destination[destination.abbreviation],
                new_journeys,
            )
        else
            journeys_to_destination[destination.abbreviation] = new_journeys
        end
    end
end



function run_mc_raptor_and_construct_journeys2(
    timetable, range_query, log_info=true
)
    origin = range_query.origin
    departure_time_min = range_query.departure_time_min
    departure_time_max = range_query.departure_time_max
    maximum_transfers = range_query.maximum_transfers

    journeys = Dict{String,Vector{Journey}}()
    departure_times_from_origin = descending_departure_times(
        timetable, origin, departure_time_min, departure_time_max
    )

    if log_info
        @info "calculating journey options for $(length(departure_times_from_origin)) departures from $(origin.name) ($(origin.abbreviation))"
    end

    last_round_bag = nothing
    for departure in departure_times_from_origin
        println("Query ",departure)
        query = McRaptorQuery(origin, departure, maximum_transfers)
        bag_round_stop, last_round = run_mc_raptor(timetable, query, last_round_bag)
        last_round_bag = deepcopy(bag_round_stop[last_round])
        
        println("Last round bag for AC:")
        for stop in timetable.stations["AC"].stops
            for option in last_round_bag[stop].options
                println("Option for stop ", stop.station_abbreviation, stop.platform_code,": ", 
                            option.label, " ", option.trip_to_station.name, 
                            " from ", option.from_stop.station_abbreviation,  option.from_stop.platform_code)
            end
        end
        
        reconstruct_journeys_to_all_destinations2!(
            journeys, query.origin, timetable, bag_round_stop, last_round
        )
        
        # println("Current options (before removing duplicates):")
        # print(journeys["AC"])
    end
    
    remove_duplicate_journeys!(journeys)
    # println("Final unique options:")
    # print(journeys["AC"])
    return journeys
end

journeys_range2 = run_mc_raptor_and_construct_journeys2(timetable, range_query);
print(journeys_range2["AC"])



# Comparison: what if we don't use the last_round_bag as initialization in run_raptor
departure_times_from_origin = descending_departure_times(
        timetable, timetable.stations[origin], departure_time_min, departure_time_max
    )

last_round_bag = nothing
journeys = Dict{String,Vector{Journey}}()
for departure_time in departure_times_from_origin
    println("Query ",departure_time)
    direct_query = McRaptorQuery(range_query.origin, departure_time, range_query.maximum_transfers)#, timetable)
    bag_round_stop, last_round = run_mc_raptor(timetable, direct_query)
    last_round_bag = deepcopy(bag_round_stop[last_round])
    reconstruct_journeys_to_all_destinations2!(
        journeys,       direct_query.origin, timetable, bag_round_stop, last_round
    )
    println("Last round bag for AC:")
    for stop in timetable.stations["AC"].stops
        for option in last_round_bag[stop].options
            println("Option for stop ", stop.station_abbreviation, stop.platform_code,": ", 
                        option.label, " ", option.trip_to_station.name, 
                        " from ", option.from_stop.station_abbreviation,  option.from_stop.platform_code)
        end
    end
    println("Current options (before removing duplicates):")
    print(journeys["AC"])

end

remove_duplicate_journeys!(journeys)
println("Current unique options:")
print(journeys["AC"])



# In de directe query zit hij wel
departure_time = date + Time(21, 50)
direct_query = McRaptorQuery(range_query.origin, departure_time, range_query.maximum_transfers)# timetable, 2)
bag_round_stop, last_round = run_mc_raptor(timetable, direct_query);
journeys = reconstruct_journeys_to_all_destinations(
    direct_query.origin, timetable, bag_round_stop, last_round
)
print(journeys["AC"])
for option in journeys["AC"]
    for leg in option.legs
        print(leg, " ", leg.to_label, "\n")
    end
    println()
end