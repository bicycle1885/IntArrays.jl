typealias IntVector{w,T} IntArray{w,T,1}

call{w,T}(::Type{IntVector{w,T}}, len::Integer) = IntArray{w,T,1}(Buffer{w}(len), (len,))

function convert{w,T}(::Type{IntVector{w}}, array::AbstractVector{T})
    return convert(IntArray{w,T,1}, array)
end

function convert{w,T}(::Type{IntVector{w,T}})
    return IntArray{w,T,1}(Buffer{w}(0), (0,))
end
