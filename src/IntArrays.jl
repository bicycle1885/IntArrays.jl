isdefined(Base, :__precompile__) && __precompile__()

module IntArrays

export IntArray, IntVector, IntMatrix,
    radixsort,
    radixsort!

import Base:
    convert,
    call,
    linearindexing,
    getindex,
    setindex!,
    size,
    length,
    sizeof,
    similar,
    fill!,
    copy!,
    resize!,
    push!,
    pop!,
    append!,
    reverse!

include("buffer.jl")
include("array.jl")
include("vector.jl")
include("matrix.jl")

end # module
