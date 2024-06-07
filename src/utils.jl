# Define type comparible to make structs with
# mutable fields (e.g., vectors) equal when the 
# content in those fields are the same
abstract type Comparable end
import Base.==
==(a::T, b::T) where T <: Comparable =
    getfield.(Ref(a),fieldnames(T)) == getfield.(Ref(b),fieldnames(T))