type IntArray{w,T<:Unsigned,n} <: AbstractArray{T,n}
    buffer::Buffer{w}
    size::NTuple{n,Int}
    function IntArray(buffer::Buffer{w}, size::NTuple{n,Int})
        new(buffer, size)
    end
end

function call{w,T}(::Type{IntArray{w,T}}, len::Integer, mmap::Bool=false)
    return IntArray{w,T,1}(Buffer{w}(len, mmap), (len,))
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
# TODO: need to add the size of pointers?
sizeof(array::IntArray) = sizeof(array.buffer.data) + sizeof(array.size)

@inline function getindex{w,T}(array::IntArray{w,T}, i::Integer)
    if i ≤ 0 || i > endof(array)
        throw(BoundsError())
    end
    return array.buffer[i] % T
end

# when I removed type parameters, array[i] fell into an infinite recursive call...
function getindex{w,T}(array::IntArray{w,T}, i::Integer, j::Integer...)
    return array[sub2ind(array.size, i, j...)]
end

@inline function setindex!(array::IntArray, x::Unsigned, i::Integer)
    if i ≤ 0 || i > endof(array)
        throw(BoundsError())
    end
    return unsafe_setindex!(array, x, i)
end

@inline function unsafe_setindex!(array::IntArray, x::Unsigned, i::Integer)
    return array.buffer[i] = x % UInt64
end

function setindex!(array::IntArray, x::Integer, i::Integer, j::Integer...)
    return array[sub2ind(array.size, i, j...)] = convert(UInt64, x)
end


function fill!{w}(array::IntArray{w}, x::Integer)
    if x == 0
        fill0!(array.buffer)
    elseif x == (1 << w) - 1
        fill1!(array.buffer)
    else
        x′ = convert(UInt64, x & rmask(w))
        fill!(array.buffer, x′, 1, length(array))
    end
    return array
end
