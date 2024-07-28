# Toy example

Toy example from tests.
We wish to travel from station S2 to S4 at 13:15 on 2024-10-21.

```@example

# Load function to create the test timetable
using Raptor
using Dates

# Create timetable for toy example
include("../../test/create_test_timetable.jl")
timetable = create_test_timetable();
today = Date(2021, 10, 21)

# Create the query
origin = "S2"
departure_time = today + Time(13, 15)
query = McRaptorQuery(origin, departure_time, timetable)

# Calculate all journey options departing from S2 at 13:15
bag_round_stop, last_round = run_mc_raptor(timetable, query);
journeys = reconstruct_journeys_to_all_destinations(
    query.origin, timetable, bag_round_stop, last_round
);

# Print the journey options to S4
destination = timetable.stations["S4"];
print(journeys[destination])
```

We see there are three non dominated options.
- Option 1: A direct very fast one that costs extra.
- Option 2: A direct one and free of extra charge but slow.
- Option 3: A moderately fast one, free of extra charge, but with a transfer.
