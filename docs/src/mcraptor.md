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
Let us plan a journey from Utrecht Overvecht to Zwolle at 13h on 2024-07-01. We first create a query as below.

```julia
date = Date(2024,7,1)
origin = "UTO" # Utrecht Overvecht
destination = "ZL" # Zwolle
departure_time = date + Time(13);

# Create query for algorithm
query = McRaptorQuery(origin, departure_time, timetable);
```
Note that the destination is not an argument of the constructor `McRaptorQuery`. 
The reason is that Raptor calculates journeys to all destinations at onces. 
So, later we will select the journeys arriving at Groningen.

### Run McRaptor and reconstruct the journeys
To calculate the journey options we run the following code.

```julia
# Run algorithm
bag_round_stop, last_round = run_mc_raptor(timetable, query);

# Reonstruct journeys from bags resulting from mc raptor
origin_station = timetable.stations[origin]
destination_station = timetable.stations[destination]
journeys = reconstruct_journeys(origin_station, destination_station, bag_round_stop, last_round);

# Convert vector of journeys to dataframe
df = journey_leg_dataframe(journeys);

# Print dataframe
println(df)
```
The first line runs the round based algorithm and returns the resulting so called round bags.
The second line reconstructs journeys to the specified destination from these round bags.
The resulting object `journeys` is a vector of `Journey`s. 
This is converted to a dataframe and printed.

## Journey options for a range of departure times
Let us now calculate all journey options from Vlissingen between 9h and 15h on 2024-07-01 and print those to Groningen (abbreviation 'GN').
This works almost the same as above, only now we create a `RangeMcRaptorQuery`. 

```julia
timetable = load_timetable();

# Create range query
date = Date(2024,7,1)
origin = "VS" # Vlissingen
departure_time_min = date + Time(9)
departure_time_max = date + Time(15)

range_query = RangeMcRaptorQuery(origin, departure_time_min, departure_time_max, timetable);

# Run mcraptor
journeys = run_mc_raptor_and_construct_journeys(timetable, range_query);

# Convert result to dataframes
df_legs = journey_leg_dataframe(journeys);
df_journeys = journey_dataframe(journeys);

# Filter journeys to specific destination
destination ="GN"; # Groningen
df_journeys_to_dest = filter(:destination => ==(destination), df_journeys);

# Check legs of first journey
journey_hash = first(df_journeys_to_dest.journey_hash);
legs_of_first_journey = filter(:journey_hash => ==(journey_hash), df_legs);

# print Journeys and the legs of the first journey option
println(df_journeys_to_dest)
println(legs_of_first_journey)
```

## Calculate all journey options at a given date.
Let us calculate all (non dominated) journey options between any two stations on 2024-07-01.
We can fix the maximum number of transfers passengers take. 
This sets a bound on the number of rounds the algorithm.
Below we assume passengers do not take journeys with more than 5 transfers.
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

# Save output
Parquet2.writefile("journey_legs.parquet", journeys)
```

