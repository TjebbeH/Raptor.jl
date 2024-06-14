module Raptor

export parse_gtfs, GtfsData, GtfsTimeTable

export McRaptorQuery
export run_mc_raptor
export reconstruct_journeys, display_journeys

include("utils.jl")

# Gtfs timetable
include("gtfs/parse.jl")

# Raptor timetable
include("raptor_timetable/timetable_structs.jl")
include("raptor_timetable/timetable_creation.jl")
include("raptor_timetable/timetable_functions.jl")

# Algorithm
include("raptor_algorithm/raptor_structs.jl")
include("raptor_algorithm/raptor_functions.jl")

# Reconstruction of journeys
include("raptor_algorithm/journey_structs.jl")
include("raptor_algorithm/construct_journeys.jl")

end
