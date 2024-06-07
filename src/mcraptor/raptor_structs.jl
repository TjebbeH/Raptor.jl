using Dates

struct Label
    arrival_time::DateTime
    fare::Number
    number_of_trips::Int
end

struct Option
    label::Label 
    trip::Union{Trip,Nothing} # trip to take to obtain travel_time and fare
    from_stop::Union{Stop,Nothing} # stop to hop-on the trip
end
Option(label::Label) = Option(label, nothing, nothing)

struct Bag
    options::Vector{Option}
end
Bag() = Bag([])
Bag(labels::Vector{Label}) = Bag([Option(label) for label in labels])


labels(bag::Bag) = [option.label for option in bag.options]