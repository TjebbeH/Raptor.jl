"""Script to plot the toy timetable"""

using Plots
using Dates

t101_stations = repeat(["S1", "S2", "S3", "S4", "S6"]; inner=2)
t101_times = [
    13, 13 + 1 / 60, 14, 14 + 1 / 60, 15, 15 + 1 / 60, 16, 16 + 1 / 60, 17, 17 + 1 / 60
]

t201_stations = repeat(["S7", "S4", "S5"]; inner=2)
t201_times = [
    15 + 15 / 60, 15 + 16 / 60, 15 + 45 / 60, 15 + 46 / 60, 16 + 15 / 60, 16 + 16 / 60
]

t301_stations = repeat(["S2", "S7"]; inner=2)
t301_times = [14, 14 + 1 / 60, 15, 15 + 1 / 60]
t303_stations = repeat(["S2", "S7"]; inner=2)
t303_times = [16, 16 + 1 / 60, 17, 17 + 1 / 60]

t401_stations = repeat(["S2", "S8", "S4"]; inner=2)
t401_times = [14, 14 + 1 / 60, 14 + 30 / 60, 14 + 31 / 60, 15, 15 + 1 / 60]

p1 = plot(;
    title="Toy timetable",
    label="trip 101",
    t101_times,
    t101_stations,
    xlabel="",
    linecolor="#4063d8",
);
p2 = plot(; label="trip 201", t201_times, t201_stations, xlabel="", linecolor="#4063d8");
p3 = plot(;
    label=["trip 301" "trip 303"],
    [t301_times, t303_times],
    [t301_stations, t303_stations],
    xlabel="",
    linecolor=["#4063d8" "#389826"],
);
p4 = plot(;
    label="trip 401", t401_times, t401_stations, xlabel="time [h]", linecolor="#4063d8"
);
plot(
    p1,
    p2,
    p3,
    p4;
    layout=(4, 1),
    ylabel="station",
    xlim=[12.8, 18],
    linewidth=3,
    leg=:bottomright,
)
savefig("docs/src/toytimetable.svg")
