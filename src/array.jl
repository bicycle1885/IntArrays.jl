mutable struct IntArray{w,T<:Unsigned,n} <: AbstractArray{T,n}
    buffer::Buffer{w,T}
    size::NTuple{n,Int}
    function IntArray{w,T,n}(buffer::Buffer{w,T}, size::NTuple{n,Int}) where {w,T,n}
        if w > bitsof(T)
            error("w = $w cannot be encoded with $T")
        end
        new(buffer, size)
    end
end

# call this function when creating an array
function (::Type{IntArray{w,T}}){w,T,n}(dims::NTuple{n,Int}, mmap::Bool=false)
    return IntArray{w,T,n}(Buffer{w,T}(prod(dims), mmap), dims)
end

function (::Type{IntArray{w,T}}){w,T}(len::Integer, mmap::Bool=false)
    return IntArray{w,T}((len,), mmap)
end

function (::Type{IntArray{w,T}}){w,T}(I::Integer...)
    return IntArray{w,T}(I)
end

function (::Type{IntArray{w,T,n}}){w,T,n}(dims::NTuple{n,Int}, mmap::Bool=false)
    return IntArray{w,T}(dims, mmap)
end

function convert{w,T,n}(::Type{IntArray{w,T,n}}, array::AbstractArray{T,n})
    iarray = IntArray{w,T}(size(array))
    @inbounds for i in eachindex(array)
        iarray[i] = array[i]
    end
    return iarray
end

function convert{w,T,n}(::Type{IntArray{w}}, array::AbstractArray{T,n})
    return convert(IntArray{w,T,n}, array)
end

Base.IndexStyle(::Type{<:IntArray}) = Base.IndexLinear()

size(array::IntArray) = array.size
length(array::IntArray) = prod(array.size)
sizeof(array::IntArray) = sizeof(array.buffer.data)

@inline function getindex{w,T}(array::IntArray{w,T}, i::Integer)
    checkbounds(array, i)
    return unsafe_getindex(array, i)
end

@inline function unsafe_getindex{w,T}(array::IntArray{w,T}, i::Integer)
    return array.buffer[i] % T
end

# when I removed type parameters, array[i] fell into an infinite recursive call...
function getindex{w,T}(array::IntArray{w,T}, i::Integer, j::Integer...)
    checkbounds(array, i, j...)
    return unsafe_getindex(array, sub2ind(array.size, i, j...))
end

@inline function setindex!(array::IntArray, x::Unsigned, i::Integer)
    checkbounds(array, i)
    return unsafe_setindex!(array, x, i)
end

@inline function unsafe_setindex!{w,T}(array::IntArray{w,T}, x::Integer, i::Integer)
    array.buffer[i] = x % T
    return array
end

function setindex!{w,T}(array::IntArray{w,T}, x::Integer, i::Integer, j::Integer...)
    checkbounds(array, i, j...)
    return unsafe_setindex!(array, x, sub2ind(array.size, i, j...))
end


function similar{w,T<:Unsigned}(array::IntArray{w}, ::Type{T}, dims::Dims)
    n = length(dims)
    IntArray{w,T,n}(dims)
end


function fill!{w,T}(array::IntArray{w,T}, x::Integer)
    if x == 0
        fill0!(array.buffer)
    elseif x == (1 << w) - 1
        fill1!(array.buffer)
    else
        fill!(array.buffer, x % T)
    end
    return array
end


function copy!{w}(a::IntArray{w}, b::IntArray{w})
    len_a = length(a)
    len_b = length(b)
    if len_a < len_b
        throw(BoundsError())
    elseif len_a == len_b
        copy!(a.buffer.data, b.buffer.data)
    else
        for i in 1:len_b
            a[i] = b[i]
        end
    end
    return a
end
