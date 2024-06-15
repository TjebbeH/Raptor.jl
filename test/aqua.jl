using Aqua
using Raptor

# Quality checks
# Ignore compat checks for packages in Base because I dont know their versions
Aqua.test_all(
    Raptor,
    ambiguities = false,
    # ambiguities = (recursive = false, broken = true),
    stale_deps = (ignore = [:Revise],),
    deps_compat = (check_extras = false, ignore = [:Revise, :Dates, :Logging, :Serialization]) 
)
Aqua.test_ambiguities([Raptor], recursive=false)


