typealias IntVector{w,T} IntArray{w,T,1}

function call{w,T}(::Type{IntVector{w,T}}, len::Integer, mmap::Bool=false)
    return IntArray{w,T}((len,), mmap)
end

function call{w,T}(::Type{IntVector{w,T}}, mmap::Bool=false)
    return IntArray{w,T}((0,), mmap)
end

function convert{w,T}(::Type{IntVector{w}}, vector::AbstractVector{T})
    return convert(IntArray{w,T,1}, vector)
end
