
using Dates

struct StationAbbreviation
    abbreviation::String
end


struct Stop
    id::String
    station_name::String
    platform_code::String
end

struct StopTime
    stop::Stop
    arrival_time::DateTime
    departure_time::DateTime
    fare::Float64
end

struct Station
    abbreviation::StationAbbreviation
    name::String
    stops::Vector{Stop}
end
Station(abbreviation::String, name::String, stops::Vector{Stop}) = Station(StationAbbreviation(abbreviation), name, stops)

struct Route
    id::String
    stops::Vector{Stop}
    # name::String # treinserie
end

struct Trip
    id::String
    stop_times::Vector{StopTime}
    name::String # trainnumber
    formula::String # eg. sprinter
    route::Route
end

struct FootPath
    from_stop::Stop
    to_stop::Stop
    duration::Float64
end

struct TimeTable
    period::@NamedTuple{first_arrival::DateTime, last_departure::DateTime}
    stations::Dict{String,Station}
    stops::Dict{String,Stop} 
    trips::Dict{String,Trip} 
    routes::Dict{String,Route} 
    footpaths::Dict{Tuple{String,String},FootPath}
    stop_routes_lookup::Dict{Stop, Dict{Route, Int64}}
end


