import Logging: Info, Debug, Warn, ConsoleLogger, global_logger

log_level = Debug
# log_level = Info
# log_level = Warn

logger = ConsoleLogger(stderr, log_level);
global_logger(logger);

# @debug "Verbose debugging information.  Invisible by default"
# @info  "An informational message"
# # @warn  "Something was odd.  You should pay attention"
# @error "A non fatal error occurred"