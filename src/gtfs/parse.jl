using Logging
using Dates
using DataFrames, CSV

struct GtfsData
    path::String
    date::Date
end

struct GtfsTimeTable
    # route_id, trip_id, trip_short_name, trip_long_name, date
    trips::DataFrame

    # trip_id, stop_id, arrival_time, departure_time
    stop_times::DataFrame

    # stop_id, stop_name, stop_code, platform_code
    stops::DataFrame
end

function read_gtfs_csv(gtfs_data::GtfsData, filename::String)
    path_to_file = joinpath([gtfs_data.path, filename])
    return CSV.read(path_to_file, DataFrame, types = String)
end

function parse_gtfs_agencies(gtfs_data::GtfsData, agencies_in_scope::Vector)
    agencies = read_gtfs_csv(gtfs_data, "agency.txt")
    filter!(:agency_name => in(agencies_in_scope), agencies)
    return agencies
end

function parse_gtfs_routes(gtfs_data::GtfsData, agency_ids_in_scope::Vector)
    routes = read_gtfs_csv(gtfs_data, "routes.txt")
    filter!(:agency_id => in(agency_ids_in_scope), routes)
    return routes
end

function parse_gtfs_trips(gtfs_data::GtfsData, route_ids_in_scope::Vector)
    trips = read_gtfs_csv(gtfs_data, "trips.txt")
    filter!(:route_id => in(route_ids_in_scope), trips)

    # Add date to trips and filter on the selected day
    calendar_dates = read_gtfs_csv(gtfs_data, "calendar_dates.txt")
    trips = leftjoin(trips, calendar_dates; on = :service_id)
    trips.date = Date.(string.(trips.date), dateformat"yyyymmdd")
    filter!(:date => ==(gtfs_data.date), trips)

    select!(trips, :route_id, :trip_id, :trip_short_name, :trip_long_name, :date)
    return trips
end

function parse_gtfs_stop_times(gtfs_data::GtfsData, trips::DataFrame)
    stop_times = read_gtfs_csv(gtfs_data, "stop_times.txt")
    select!(stop_times, :trip_id, :stop_id, :arrival_time, :departure_time)

    # add date to stop_times and convert times to datetimes
    stop_times = innerjoin(stop_times, select(trips, :trip_id, :date), on = :trip_id)
    function combine(date::Date, time::String)
        @assert length(time) == 8
        hours, minutes, seconds = split(time, ":")
        return DateTime(date) + Hour(hours) + Minute(minutes) + Second(seconds)
    end
    stop_times.arrival_time = combine.(stop_times.date, stop_times.arrival_time)
    stop_times.departure_time = combine.(stop_times.date, stop_times.departure_time)

    select!(stop_times, :trip_id, :stop_id, :arrival_time, :departure_time)
    return stop_times
end

function parse_gtfs_stops(gtfs_data::GtfsData, stop_ids_in_scope::Vector)
    stops_full = read_gtfs_csv(gtfs_data, "stops.txt")
    stops = filter(:stop_id => in(stop_ids_in_scope), stops_full)

    # add station codes
    parent_stations = unique(stops.parent_station)
    stations = filter(:stop_id => in(parent_stations), stops_full)
    stations.stop_code = uppercase.(stations.stop_code)
    select!(stations, :stop_id, :stop_code)
    select!(stops, :stop_id, :stop_name, :parent_station, :platform_code)
    stops = leftjoin(stops, stations, on = :parent_station => :stop_id)

    dropmissing(stops, :parent_station)
    select!(stops, :stop_id, :stop_name, :stop_code, :platform_code)
    stops.platform_code = coalesce.(stops.platform_code, "?")

    return stops
end


function parse_gtfs(path::String, date::Date, agencies_in_scope::Vector = ["NS"])
    @info "create gtfs timetable"

    gtfs_data = GtfsData(path, date)

    @info " parse agencies"
    agencies = parse_gtfs_agencies(gtfs_data, agencies_in_scope)
    agency_ids_in_scope = unique(agencies.agency_id)

    @info " parse routes"
    routes = parse_gtfs_routes(gtfs_data, agency_ids_in_scope)
    route_ids_in_scope = unique(routes.route_id)

    @info " parse trips"
    trips = parse_gtfs_trips(gtfs_data, route_ids_in_scope)

    @info " parse stop_times"
    stop_times = parse_gtfs_stop_times(gtfs_data, trips)
    stop_ids_in_scope = string.(unique(stop_times.stop_id))

    @info " parse stops"
    stops = parse_gtfs_stops(gtfs_data, stop_ids_in_scope)

    disallowmissing!(trips)
    disallowmissing!(stop_times)
    disallowmissing!(stops)

    return GtfsTimeTable(trips, stop_times, stops)
end
