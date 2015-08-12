module IntArrays

export IntArray, IntVector, IntMatrix

import Base:
    convert,
    call,
    getindex,
    setindex!,
    size,
    length

include("buffer.jl")
include("array.jl")
include("vector.jl")
include("matrix.jl")

end # module
