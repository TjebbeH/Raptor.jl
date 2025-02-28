using Raptor
using BenchmarkTools

using Dates

# gtfs_dir = joinpath([@__DIR__, "..", "data", "gtfs", "gtfs_nl_2024_07_01"])
# date = Date(2024, 7, 1)
# timetable = create_raptor_timetable(gtfs_dir, date);
# save_timetable(timetable)
function main()
    date = Date(2024, 7, 1)
    timetable = load_timetable();

    origin = "Vlissingen"
    departure_time = date + Time(9);

    query = McRaptorQuery(origin, departure_time, timetable);


    bag_round_stop, last_round = @btime run_mc_raptor($timetable, $query);
    journeys = reconstruct_journeys_to_all_destinations(
        query.origin, timetable, bag_round_stop, last_round
    );

    destination = "GN"
    println(journeys[destination])
end
main()
