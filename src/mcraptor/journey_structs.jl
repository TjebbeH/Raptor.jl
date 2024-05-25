

struct JourneyLeg
    origin::Stop
    destination::Stop
    departure_time::DateTime
    arrival_time::DateTime
end

struct Journey
    legs::Vector{JourneyLeg}
end



