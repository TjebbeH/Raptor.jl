#!/usr/bin/bash

juliaup add 1.10 # consistent with the version in the Project.toml
juliaup default 1.10
julia -e 'using Pkg; Pkg.activate("."); Pkg.instantiate()'
