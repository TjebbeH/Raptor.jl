import Raptor: Label, Stop, Option, Bag
import Raptor:
    is_geq_at_everything, is_much_slower, isdominated, pareto_set_idx, pareto_set_slow!
import Raptor: pareto_2d!, positive_fare
import Raptor: pareto_set!, merge_bags

using Dates
using Test

l1 = Label(DateTime(2024, 1, 1, 12, 30), 0, 2) # fast but two transfers
l2 = Label(DateTime(2024, 1, 1, 13), 0, 2) # slow and two tranfers 
l3 = Label(DateTime(2024, 1, 1, 13), 0, 1) # slow but only one transfer
l4 = Label(DateTime(2024, 1, 1, 20), 0, 0) # (too) much slower but direct 
l5 = Label(DateTime(2024, 1, 1, 12), 10.0, 0) # fast and direct but expensive

ls = [l1, l2, l3, l3, l4, l5]
ls_pareto_expected = [l1, l3, l5]

ls_no_fare = [l1, l2, l3, l3, l4]
ls_no_fare_pareto_expected = [l1, l3]

stop = Stop("id", "UT", "3")
options_input = [Option(l, nothing, stop, nothing) for l in ls]
options_expected = [Option(l, nothing, stop, nothing) for l in ls_pareto_expected]

options_no_fare_input = [Option(l, nothing, stop, nothing) for l in ls_no_fare]
options_no_fare_expected = [
    Option(l, nothing, stop, nothing) for l in ls_no_fare_pareto_expected
]

b_all1 = Bag(options_input)
b_all2 = Bag(options_input)

bag_expected = Bag(options_expected)
b12 = Bag([Option(l1), Option(l2)])
b3 = Bag([Option(l3)])
b13 = Bag([Option(l1), Option(l3)])

@test positive_fare(options_input) == true
@test positive_fare(options_no_fare_input) == false

@test !is_geq_at_everything(l1, l2)
@test is_geq_at_everything(l2, l1)
@test !is_geq_at_everything(l3, l1)
@test is_geq_at_everything(l3, l3)

@test !isdominated(l1, ls)
@test isdominated(l2, ls)
@test !isdominated(l3, ls)
@test isdominated(l4, ls)
@test !isdominated(l5, ls)

@test is_much_slower(l1, l2) == false
@test is_much_slower(l4, l1) == true

@test pareto_set_idx([1, 2, 3, 5, 6], ls) == [true, false, true, false, false, true]

options1 = deepcopy(options_input)
pareto_set!(options1)
@test options1 == options_expected

options2 = deepcopy(options_input)
pareto_set_slow!(options2)
@test options2 == options_expected

options3 = deepcopy(options_no_fare_input)
pareto_2d!(options3)
@test options3 == options_no_fare_expected

@test merge_bags(b_all1, b_all2) == bag_expected
@test merge_bags(b12, b3) == b13
@test merge_bags([b12, b3, b13]) == b13
