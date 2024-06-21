![Project Status: WIP - Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)
[![SciML Code Style](https://img.shields.io/static/v1?label=code%20style&message=SciML&color=9558b2&labelColor=389826)](https://github.com/SciML/SciMLStyle)


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
- [ ] Type stability tests
- [ ] Make config with threshold, fare, default footpaths
- [ ] Parametrize structs with abstract types
- [ ] Improve parallelization
- [ ] clean up/refactor?
- [ ] docstrings above functions
- [ ] Readme
- [ ] Documentation(.jl)



