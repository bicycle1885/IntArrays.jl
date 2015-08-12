type IntArray{w,T<:Unsigned,n} <: AbstractArray{T,n}
    buffer::Buffer{w}
    size::NTuple{n,Int}
end

function convert{w,T,n}(::Type{IntArray{w,T,n}}, array::AbstractArray{T,n})
    len = length(array)
    buf = Buffer{w}(len)
    for i in 1:len
        buf[i] = array[i] % UInt64
    end
    return IntArray{w,T,n}(buf, size(array))
end

function convert{w,T,n}(::Type{IntArray{w}}, array::AbstractArray{T,n})
    return convert(IntArray{w,T,n}, array)
end

size(array::IntArray) = array.size
length(array::IntArray) = prod(array.size)

function getindex{w,T}(array::IntArray{w,T}, i::Integer)
    return array.buffer[i] % T
end

# when I removed type parameters, array[i] fell into an infinite recursive call...
function getindex{w,T}(array::IntArray{w,T}, i::Integer, j::Integer...)
    return array[sub2ind(array.size, i, j...)]
end

function setindex!(array::IntArray, x::Unsigned, i::Integer)
    return array.buffer[i] = x % UInt64
end

function setindex!(array::IntArray, x::Unsigned, i::Integer, j::Integer...)
    return array[sub2ind(array.size, i, j...)] = x
end
