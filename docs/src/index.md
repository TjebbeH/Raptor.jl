# Introduction

Raptor is an algorithm that, given a (dynamic) public transport timetable, calculates journey options.
That is, when you wishes to travel by train from one station to an other station at a given departure time, 
the algorithm yields a set of relevant options that you can take. 
Here, relevant means Pareto-optimal journeys for multiple criteria, such as arrival time, number of transfers and costs.
For example, when there is a direct option (i.e., with no transfers) and an option with one transfer which arrives before the direct one, it will yield both options.

The algorithm is a Round-Based Public Transit Routing algorithm described in [Delling et al. (2014)](https://doi.org/10.1287/trsc.2014.0534). 
The implementation is based on [pyraptor](https://github.com/lmeulen/pyraptor).