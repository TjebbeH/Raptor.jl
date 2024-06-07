using Dates
include("../utils.jl")

struct JourneyLeg
    origin::Stop
    destination::Stop
    departure_time::DateTime
    arrival_time::DateTime
end

struct Journey<:Comparable
    legs::Vector{JourneyLeg}
end



