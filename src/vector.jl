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

function resize!(vector::IntVector, len::Integer)
    resize!(vector.buffer, len)
    vector.size = (len,)
    return vector
end

function push!(vector::IntVector, x::Integer)
    resize!(vector, length(vector) + 1)
    vector[end] = x
    return vector
end

function pop!(vector::IntVector)
    x = vector[end]
    resize!(vector, length(vector) - 1)
    return x
end
