struct McRaptorQuery
    origin::Station
    destination::Station
    departure_time::DateTime
end


create_empty_bags(from_stops) = Dict(stop => Bag() for stop in from_stops)

function initialize_bags(maximum_rounds::Int, query::McRaptorQuery)
    from_stops = query.origin.stops
    bag_round_stop = [create_empty_bags(from_stops) for _ in 1:maximum_rounds]

    @debug "starting from stops: " * join(display_name.(from_stops), ", ")
    initial_label = Label(query.departure_time, 0, 0)
    for stop in from_stops
        push!(bag_round_stop[1][stop].labels, initial_label)
    end
    return bag_round_stop
end

function get_routes_to_travers(marked_stops::Vector{Stop})
    """Collect routes to check that serve one of the marked_stops"""
    Q = Dict{Route, Stop}()
    for marked_stop in marked_stops
        routes_serving_marked_stop = get(timetable.stop_routes_lookup, marked_stop, Dict{Route, Int64}())
        for route in keys(routes_serving_marked_stop)
            stop_in_Q = get(Q, route, missing)
            if marked_stop == first_in_route(timetable, route, stop_in_Q, marked_stop)
                    Q[route] = marked_stop
            end
        end
    end
    @debug "found $(length(Q)) routes serving marked stops"
    return Q
end

function is_geq_at_everything(label1::Label, label2::Label)
    """Check if label1 is worse or equal at all criteria then label2"""
    criteria = fieldnames(Label)
    return all(getfield(label1, field) >= getfield(label2, field) for field in criteria)
end

function isdominated(label::Label, labels::Vector{Label})
    """Check if there is a label in labels that dominates label."""
    for other_label in labels
        if other_label != label && is_geq_at_everything(label, other_label)
            return true
        end
    end
    return false
end

function pareto_set(labels::Vector{Label})
    """Calculate pareto set of labels.
    That is, remove all labels that are dominated by an other."""
    to_keep = trues(size(labels))
    for (i, label) in enumerate(labels)
        to_keep[i] = !isdominated(label, labels[to_keep])
    end
    return labels[to_keep]
end


function merge(bag1::Bag, bag2::Bag)
    """Merge bag1 and bag2.
    That is, return bag with pareto set of combined labels."""
    combined_labels = [bag1.labels; bag2.labels] 
    pareto_labels = pareto_set(combined_labels)
    return Bag(pareto_labels)
end



l1 = Label(DateTime(2024,4,1,12,0,0), 0, 1)
l2 = Label(DateTime(2024,4,1,12,30,0), 0, 0)
b1 = Bag([l1,l2])

l3 = Label(DateTime(2024,4,1,11,0,0), 0, 1)
l4 = Label(DateTime(2024,4,1,13,0,0), 0, 0)
b2 = Bag([l3,l4, l4, l4,l4,l4,l4,l4,l4,l4,l4,l4,l4,l4,l4,l4])

new_bag = merge(b1,b2)
different_labels(b1::Bag, b2::Bag) = b1.labels != b2.labels
different_labels(b1, new_bag)