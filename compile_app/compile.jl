using Pkg
Pkg.activate("RaptorApp")

using PackageCompiler

create_app("RaptorApp", "RaptorAppCompiled", filter_stdlibs=true, force=true)