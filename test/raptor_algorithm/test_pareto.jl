import Raptor: Label, Stop, Option, Bag
import Raptor: is_geq_at_everything, isdominated, pareto_set_idx, pareto_set, merge_bags

using Dates
using Test

l1 = Label(DateTime(2024, 1, 1, 12, 30), 0, 2) # fast but 2 transfers
l2 = Label(DateTime(2024, 1, 1, 13,  0), 0, 2) # slow and two transfers
l3 = Label(DateTime(2024, 1, 1, 13,  0), 0, 1) # slow but only one transfer
l4 = Label(DateTime(2024, 1, 1, 20,  0), 0, 0) # direct but much much slower

ls = [l1, l2, l3, l3, l4]
ls_pareto_expected = [l1, l3]

stop = Stop("id", "UT", "3")
options_input = [Option(l, nothing, stop, nothing) for l in ls]
options_expected = [Option(l, nothing, stop, nothing) for l in ls_pareto_expected]

import Raptor: pareto_set2

@time pareto_set(options_input)
@time pareto_set(options_input)
@time pareto_set2(options_input)
@time pareto_set2(options_input)

using BenchmarkTools

@benchmark pareto_set($options_input)

@benchmark pareto_set2($options_input)
b_all1 = Bag(options_input)
b_all2 = Bag(options_input)

import Raptor: merge_bags, merge_bags2

b_all1 = Bag(options_input)
b_all2 = Bag(options_input)

@benchmark merge_bags(b_all1, b_all2)
@benchmark merge_bags2(b_all1, b_all2)



import Raptor: sa_label
@btime [sa_label(l) for l in ls]


bag_expected = Bag(options_expected)
b12 = Bag([Option(l1), Option(l2)])
b3 = Bag([Option(l3)])
b13 = Bag([Option(l1), Option(l3)])

@test !is_geq_at_everything(l1, l2)
@test is_geq_at_everything(l2, l1)
@test !is_geq_at_everything(l3, l1)
@test is_geq_at_everything(l3, l3)

@test !isdominated(l1, ls)
@test isdominated(l2, ls)
@test !isdominated(l3, ls)

@test pareto_set_idx([1, 2, 3], ls) == [true, false, true, false]
@test pareto_set(options_input) == options_expected

@test merge_bags(b_all1, b_all2) == bag_expected
@test merge_bags(b12, b3) == b13
@test merge_bags([b12, b3, b13]) == b13
