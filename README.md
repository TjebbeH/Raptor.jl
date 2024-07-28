![Project Status: WIP - Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaStats.github.io/Distributions.jl/stable/)

# Getting started
Create a file `.devcontainter/variables.env` with your git name and email
```
GIT_NAME="<firstname lastname>"
GIT_EMAIL="<your-email>"
```
Then, open in container.

Download [gtfs data](https://gtfs.ovapi.nl/nl/) (see `test/gtfs/testdata` for expected format).

# McRaptor
Implementation based on [pyraptor](https://github.com/lmeulen/pyraptor).

### References
D. Delling, T. Pajor, R. F. Werneck (2014) Round-Based Public Transit Routing. Transportation Science 49(3):591-604. 
https://doi.org/10.1287/trsc.2014.0534.

# TODO:
- [ ] More functional unittests
- [ ] Make config with threshold, fare, default footpaths
- [ ] Improve parallelization
- [ ] clean up/refactor?
- [ ] Readme
- [ ] Documentation(.jl)



