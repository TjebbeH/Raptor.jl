![Project Status: WIP - Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://tjebbeh.github.io/Raptor.jl/)

# McRaptor
Implementation based on [pyraptor](https://github.com/lmeulen/pyraptor).

### References
D. Delling, T. Pajor, R. F. Werneck (2014) Round-Based Public Transit Routing. Transportation Science 49(3):591-604. 
https://doi.org/10.1287/trsc.2014.0534.


## Getting started in dev container
Create a file `.devcontainter/variables.env` with your git name and email
```
GIT_NAME="<firstname lastname>"
GIT_EMAIL="<your-email>"
```
Then, open in container.

See [Documentation](https://tjebbeh.github.io/Raptor.jl/) for instructions on how to calculate journey options.


## TODO:
- fix reconstruction of journeys without creating many duplicates
- fix bug with number of transfers in label > number of transfers in journey
- Parsing of gtfs does not always work correctly: sometimes there's different names for the same station
- Optimize (memory use)
- More functional tests
- Consider threshold, fares and default footpaths as input
- Improve Documentation (o.a., more doc strings api, general timetable)
- Clean up and register package
