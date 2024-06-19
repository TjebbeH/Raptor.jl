# Define type comparible to make structs with
# mutable fields (e.g., vectors) equal when the 
# content in those fields are the same
abstract type Comparable end
import Base.==
function ==(a::T, b::T) where {T <: Comparable}
    return getfield.(Ref(a), fieldnames(T)) == getfield.(Ref(b), fieldnames(T))
end