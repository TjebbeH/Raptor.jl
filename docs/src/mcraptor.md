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
    query.origin, timetable, bag_round_stop, last_round
);

destination_station = try_to_get_station(destination, timetable)
println(journeys[destination_station])
```
The first line is runs the round based algorithm and returns the resulting so called round bags.
The second line reconstructs journeys from these round bags.
The resulting object `journeys` is a dictionary with destination `Station`s as keys and the `Journey`s as values. 
The second to last lines looks for a station with the name 'Groningen' in the timetable. 
The last line prints the journeys to the destination station Groningen.

## Journey options for a range of departure times
Let us now calculate all journey options from Vlissingen to Groningen between 9h and 15h on 2024-07-01.
This works almost the same as above, only now we create a `RangeMcRaptorQuery`. 

```julia
timetable = load_timetable();

date = Date(2024,7,1)
origin = "Vlissingen"
destination = "Groningen"
departure_time_min = date + Time(9);
departure_time_max = date + Time(15);

range_query = RangeMcRaptorQuery(origin, departure_time_min, departure_time_max, timetable);
journeys = run_mc_raptor_and_construct_journeys(timetable, range_query);

destination_station = try_to_get_station(destination, timetable)
println(journeys[destination_station])
```

## Calculate all journey options at a given date.
Let us calculate all (non dominated) journey options between any two stations on 2024-07-01.
We can fix the maximum number of transfers passengers take. 
This sets a bound on the number of rounds the algorithm.
Below we assume passengers do not take journeys with more than 5 transfers.
We use 8 parallel processes for the calculation.

```julia
using Distributed
addprocs(8)

date = Date(2024,7,1)
timetable = load_timetable();
maximum_transfers = 5
journeys = calculate_all_journeys(timetable, date, maximum_transfers);
```

