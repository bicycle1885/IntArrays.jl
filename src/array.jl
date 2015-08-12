type IntArray{T<:Unsigned,n,w} <: AbstractArray{T,n}
    buffer::Buffer{w}
    size::NTuple{n,Int}
end

function convert{T,n,w}(::Type{IntArray{T,n,w}}, array::AbstractArray{T,n})
    len = length(array)
    buf = Buffer{w}(len)
    for i in 1:len
        buf[i] = array[i] % UInt64
    end
    return IntArray{T,n,w}(buf, size(array))
end

size(array::IntArray) = array.size
length(array::IntArray) = prod(array.size)

function getindex{T}(array::IntArray{T}, i::Integer)
    return array.buffer[i] % T
end

function getindex{T}(array::IntArray{T}, i::Integer, j::Integer...)
    return array[sub2ind(array.size, i, j...)]
end

function setindex!{T}(array::IntArray{T}, x::Unsigned, i::Integer)
    return array.buffer[i] = x % UInt64
end

function setindex!{T}(array::IntArray{T}, x::Unsigned, i::Integer, j::Integer...)
    return array[sub2ind(array.size, i, j...)] = x
end
