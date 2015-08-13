typealias IntVector{w,T} IntArray{w,T,1}

function call{w,T}(::Type{IntVector{w,T}}, len::Integer, mmap::Bool=false)
    IntArray{w,T,1}(Buffer{w}(len, mmap), (len,))
end

function convert{w,T}(::Type{IntVector{w}}, array::AbstractVector{T})
    return convert(IntArray{w,T,1}, array)
end

function convert{w,T}(::Type{IntVector{w,T}})
    return IntArray{w,T,1}(Buffer{w}(0), (0,))
end
