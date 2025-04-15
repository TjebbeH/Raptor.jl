using PackageCompiler

# create_app("src/raptor_algorithm", "PifAppCompiled")

using PackageCompiler

create_app("src/raptor_algorithm/main.jl/PifApp", "PifAppCompiled", force = true)

create_app("src/raptor_timetable/PifApp", "PifAppCompiled", force = true,filter_stdlibs=true)


# create_app(
#     "src/raptor_algorithm",
#     "build/raptor_algorithm_bin";
#     precompile_execution_file="src/raptor_algorithm/main.jl",
#     app_name="raptor_algorithm"
# )
#
# create_app(
#     "src/raptor_timetable",
#     "build/raptor_timetable_bin";
#     precompile_execution_file="src/raptor_timetable/main.jl",
#     app_name="raptor_timetable"
# )