using Raptor
using Dates
using Logging
using Test
using JET

# include("../create_test_timetable.jl")
timetable = create_test_timetable();
today = Date(2021, 10, 21)

journeys = calculate_all_journeys_mt(timetable, today);

@test length(journeys["S2"]["S4"]) == 3
@test length(journeys["S2"]["S7"]) == 2

@testset "type-stabilities (JET)" begin
    @test_opt target_modules = (@__MODULE__,) calculate_all_journeys_mt(timetable, today)
end
@testset "code calls (JET)" begin
    @test_call target_modules = (@__MODULE__,) calculate_all_journeys_mt(timetable, today)
end
