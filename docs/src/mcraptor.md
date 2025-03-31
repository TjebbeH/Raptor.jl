# McRaptor

McRaptor is the multi-criteria version of Raptor.
Below it is shown how to calculate
1. A journey from an origin station to a destination station at a given departure time.
2. All journeys from an origin station to a destination station in a range of departure times.
3. All journeys from every origin to every destination on a given date. 

## Load `TimeTable`
Assuming we already saved a timetable load the timetable (otherwise follow the steps in [Timetable](@ref)).

```julia
timetable = load_timetable(); 
```

## Journey options for one specific departure time

### Create McRaptorQuery
Let us plan a journey from Vlissingen to Groningen at 13h on 2024-07-01. We first create a query as below.

```julia
date = Date(2024,7,1)
origin = "Vlissingen"
destination = "Groningen"
departure_time = date + Time(13);

query = McRaptorQuery(origin, departure_time, timetable);
```
Note that the destination is not an argument of the constructor `McRaptorQuery`. 
The reason is that Raptor calculates journeys to all destinations at onces. 
So, later we will select the journeys arriving at Groningen.

### Run McRaptor and reconstruct the journeys
To calculate the journey options we run the following code.

```julia
bag_round_stop, last_round = run_mc_raptor(timetable, query);
journeys = reconstruct_journeys_to_all_destinations(
    query, timetable, bag_round_stop, last_round
);

# Search for station with name Groningen
destination_station = get_station(destination, timetable)
destination_abbreviation = destination_station.abbreviation # GN
println(journeys[destination_abbreviation])
```
The first line is runs the round based algorithm and returns the resulting so called round bags.
The second line reconstructs journeys from these round bags.
The resulting object `journeys` is a dictionary with destination Station abbreviations as keys and a vector of `Journey`s as values. 
The second to last lines looks for a station with the name 'Groningen' in the timetable. 
The last line prints the journeys to the destination station Groningen.

## Journey options for a range of departure times
Let us now calculate all journey options from Vlissingen between 9h and 15h on 2024-07-01 and print those to Groningen (abbreviation 'GN').
This works almost the same as above, only now we create a `RangeMcRaptorQuery`. 

```julia
timetable = load_timetable();

date = Date(2024,7,1)
origin = "Vlissingen"
departure_time_min = date + Time(9);
departure_time_max = date + Time(15);

range_query = RangeMcRaptorQuery(origin, departure_time_min, departure_time_max, timetable);
journeys = run_mc_raptor_and_construct_journeys(timetable, range_query);

# Print journeys to Groningen
println(journeys["GN"])
```

## Calculate all journey options at a given date.
Let us calculate all (non dominated) journey options between any two stations on 2024-07-01.
We can fix the maximum number of transfers passengers take. 
This sets a bound on the number of rounds the algorithm.
Below we assume passengers do not take journeys with more than 3 transfers.

The first option is to do this multi-threaded.
See https://docs.julialang.org/en/v1/manual/multi-threading/ for more information on how to use multiple threads.

```julia
using Raptor
using Dates

# Check number of treads
Threads.nthreads()

timetable = load_timetable();

date = Date(2024, 7, 1);
maximum_transfers = 3;
journeys = calculate_all_journeys_mt(timetable, date, maximum_transfers);

# Check the journey options from Eindhoven to Groningen
origin = "EHV";
destination = "GN";
println(journeys[origin][destination])
```

The other option is to calculate this distributedly.
We use 4 parallel processes for the calculation.

```julia
using Distributed
addprocs(4)

# Broadcast the package and timetable to all workers
@everywhere begin
    using Raptor

    timetable = load_timetable();
end

using Dates
date = Date(2024, 7, 1);
maximum_transfers = 5;
journeys = calculate_all_journeys(timetable, date, maximum_transfers);

# Print the journey options from Eindhoven to Groningen
origin = "EHV";
destination = "GN";
println(journeys[origin][destination]) 
```

