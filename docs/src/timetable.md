# Timetable

## Download GTFS data.
The algorithm needs a `TimeTable`. 
To create such a timetable first download gtfs data of a specific date. 
For the dutch public transport this can be done at the [ovapi](https://gtfs.ovapi.nl/nl/).
After unzipping the resulting data should contain at least the following files: 

```
├── agency.txt
├── calendar_dates.txt
├── routes.txt
├── stop_times.txt
├── stops.txt
└── trips.txt
```

## Create `TimeTable`
Once the gtfs data is saved it is possible to parse it directly into a `TimeTable` that Raptor can use:

```julia
using Raptor
using Dates

gtfs_dir = joinpath([@__DIR__, "..", "data", "gtfs", "gtfs_nl_2024_07_01"])
date = Date(2024,7,1)
timetable = create_raptor_timetable(gtfs_dir, date);
save_timetable(timetable)
```
Here `gtfs_dir` is the path where the gtfs data as structured above can be found. 
The function `create_raptor_timetable` first parses the files into a `GtfsTimeTable` and subsequently constructs the `TimeTable` Raptor can use. 
The parsing of the stop-times might take a while.
After creation it is saved (i.e., serialized at `src/raptor_timetable/data/raptor_timetable`).

We are now ready to calculate journeys.