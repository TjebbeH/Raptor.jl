module RaptorTimeTable

export TimeTable, Stop, Station, Trip, TripStopTime, Route, FootPath
export StationAbbreviation

export create_raptor_timetable, save_timetable, load_timetable
export get_station, get_other_stops_at_station

export get_stop_idx_in_route, first_in_route
export get_stop_time, get_fare, get_earliest_trip

using DataFrames
using Serialization

include("./timetable_structs.jl")
include("./timetable_creation.jl")
include("./timetable_functions.jl")

end
