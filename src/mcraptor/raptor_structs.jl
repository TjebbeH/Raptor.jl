using Dates

struct Label
    arrival_time::DateTime
    fare::Rational
    number_of_trips::Int
end

struct Bag
    labels::Vector{Label}
end
Bag() = Bag([])
# struct RouteBag
#     labels::Vector{Label}
# end
