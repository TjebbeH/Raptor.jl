using Raptor

using Dates
using  Logging

import Raptor:Journey
import Raptor:descending_departure_times

# gtfs_dir = joinpath([@__DIR__, "..", "data", "gtfs", "gtfs_nl_2024_07_01"])
# date = Date(2024, 7, 1)
# timetable = create_raptor_timetable(gtfs_dir, date);
# save_timetable(timetable)

date = Date(2024, 7, 1)
timetable = load_timetable("gtfs_nl_2024_07_01")

origin = "BD"
departure_time_min = date + Time(21, 50)
departure_time_max = date + Time(22, 20)

range_query = RangeMcRaptorQuery(
    origin, departure_time_min, departure_time_max, timetable
)
journeys_range = @time run_mc_raptor_and_construct_journeys(timetable, range_query)


# Check if there are destinations for which the set is not pareto optimal
# Copy paste functions from raptor_functions, but then for journeys. but also look at departure_time
function is_geq_at_everything(journey1::Journey, journey2::Journey)
    if journey1.legs[end].arrival_time < journey2.legs[end].arrival_time
        return false
    end
    if journey1.legs[1].departure_time > journey2.legs[1].departure_time
        return false
    end
    if length(journey1.legs) < length(journey2.legs)
        return false
    end
    if journey1.legs[end].fare < journey2.legs[end].fare
        return false
    end
    return true
end


"""Check if there is a label in labels that dominates label."""
function isdominated(label, labels)
    for other_label in labels
        is_different = other_label != label
        label_is_worse_at_everything = is_geq_at_everything(label, other_label)
        if is_different && label_is_worse_at_everything
            return true
        end
    end
    return false
end

"""
Calculate indexes for pareto set of labels of options.
"""
function pareto_set_idx(unique_label_idx::Vector{Int}, labels::Vector{Journey})
    to_keep = falses(size(labels))
    to_keep[unique_label_idx] .= true
    for i in unique_label_idx
        to_keep[i] = !isdominated(labels[i], labels[to_keep])
    end
    return to_keep
end


function pareto_set_slow(journeys)
    labels = copy(journeys)
    unique_label_idx = unique(i -> labels[i], 1:length(labels))
    to_keep = pareto_set_idx(unique_label_idx, labels)
    return keepat!(labels, to_keep)
end



journeys_range_pareto_optimal = Dict(dest=> pareto_set_slow(options) for (dest, options) in journeys_range)
for (dest, options) in journeys_range
    if length(options) > length(journeys_range_pareto_optimal[dest])
        println(dest, " ", length(options), " ", length(journeys_range_pareto_optimal[dest]))
    end
end

println(journeys_range["UTZL"]) 
for option in journeys_range["UTZL"]
    for leg in option.legs
        print(leg, " ", leg.to_label, "\n")
    end
    println()
end

println()


departure_times_from_origin = descending_departure_times(
        timetable, timetable.stations[origin], departure_time_min, departure_time_max
    )

for departure_time in departure_times_from_origin
    println("Query ",departure_time)
    direct_query = McRaptorQuery(origin, departure_time, timetable)
    bag_round_stop, last_round = run_mc_raptor(timetable, direct_query)
    journeys = reconstruct_journeys_to_all_destinations(
        direct_query, timetable, bag_round_stop, last_round
    )
    for option in journeys["UTZL"]
        for leg in option.legs
            print(leg, " ", leg.to_label, "\n")
        end
        println()
    end
end


departure_time = date + Time(22, 15)
direct_query = McRaptorQuery(origin, departure_time, timetable, 2)
bag_round_stop, last_round = run_mc_raptor(timetable, direct_query);
journeys = reconstruct_journeys_to_all_destinations(
    direct_query, timetable, bag_round_stop, last_round
)
for option in journeys["AC"]
    for leg in option.legs
        print(leg, " ", leg.to_label, "\n")
    end
    println()
end