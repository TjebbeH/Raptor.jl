include("./raptor_timetable.jl")
using .RaptorTimeTable
using Dates


# gtfs_dir = "gtfs_nl_2024_05_20"
# date = Date(2024,5,20)
# timetable = create_raptor_timetable(gtfs_dir,date);
# save_timetable(timetable)

# timetable = create_raptor_timetable("tmp_gtfs");
# save_timetable(timetable)

date = Date(2024,5,20)
timetable = load_timetable();


include("./journey_structs.jl")
include("./raptor_structs.jl")

include("./timetable_functions.jl") # tmp
include("./raptor_functions.jl") # tmp
# include("./logger.jl"); #tmp


origin = get_station(StationAbbreviation("ASN"), timetable);
destination = get_station(StationAbbreviation("GN"), timetable);
departure_time = DateTime(2024,5,20,12,0,0);

query = McRaptorQuery(origin, destination, departure_time);

maximum_rounds = 3

bag_round_stop, round_counter = run_mc_raptor(timetable, query, maximum_rounds);




