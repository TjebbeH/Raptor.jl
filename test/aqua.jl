using Aqua
using Raptor

# Quality checks
# Ignore compat checks for packages in Base because I dont know their versions
Aqua.test_all(
    Raptor,
    ambiguities = false,
    stale_deps = (ignore = [:Revise],),
    deps_compat = (
        check_extras = false, ignore = [:Revise, :Dates, :Logging, :Serialization])
)
# Base and Core have some ambiguities, so dont check them
Aqua.test_ambiguities([Raptor], recursive = false)
