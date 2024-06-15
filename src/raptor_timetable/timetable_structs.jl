
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
    fare::Number
end

struct Station <: Comparable
    abbreviation::StationAbbreviation
    name::String
    stops::Vector{Stop}
end
function Station(abbreviation::String, name::String, stops::Vector{Stop})
    Station(StationAbbreviation(abbreviation), name, stops)
end

struct Route <: Comparable
    id::String
    # name::String # treinserie
    stops::Vector{Stop}
end
function Route(stops::Vector{Stop})
    route_id = join([s.id for s in stops], "-")
    return Route(route_id, stops)
end

struct Trip <: Comparable
    id::String
    name::String # trainnumber
    formula::String # eg. sprinter
    route::Route
    stop_times::Vector{StopTime}
end

struct FootPath
    from_stop::Stop
    to_stop::Stop
    duration::Second
end

struct TimeTable
    period::@NamedTuple{first_arrival::DateTime, last_departure::DateTime}
    stations::Dict{String, Station}
    stops::Dict{String, Stop}
    trips::Dict{String, Trip}
    routes::Dict{String, Route}
    footpaths::Dict{Tuple{String, String}, FootPath}
    stop_routes_lookup::Dict{Stop, Dict{Route, Int64}}
    route_trip_lookup::Dict{Route, Vector{Trip}}
end
