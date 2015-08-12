module IntArrays

export IntVector

import Base:
    convert,
    getindex,
    setindex!,
    length

include("buffer.jl")
include("intvectors.jl")

end # module
