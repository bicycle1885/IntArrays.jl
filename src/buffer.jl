# internal data for packed integers
type Buffer{w,T<:Unsigned}
    data::Vector{T}
    function Buffer(len::Integer, mmap::Bool=false)
        @assert w ≤ bitsof(T)
        buflen = cld(len * w, bitsof(T))
        data = mmap ? Mmap.mmap(Vector{T}, buflen) : Vector{T}(buflen)
        return new(data)
    end
end

bitsof{T}(::Type{T}) = sizeof(T) * 8
wordsize{w,T}(::Buffer{w,T}) = bitsof(T)

function resize!{w}(buffer::Buffer{w}, len::Integer)
    buflen = cld(len * w, wordsize(buffer))
    resize!(buffer.data, buflen)
    return buffer
end

@inline function mask{T}(::Type{T}, w)
    ~T(0) >> (bitsof(T) - w)
end

@inline function get_chunk_id{w}(::Buffer{w,UInt8}, i::Integer)
    j = Int(i - 1) * w
    return (j >> 3) + 1, j & 0b000111
end

@inline function get_chunk_id{w}(::Buffer{w,UInt16}, i::Integer)
    j = Int(i - 1) * w
    return (j >> 4) + 1, j & 0b001111
end

@inline function get_chunk_id{w}(::Buffer{w,UInt32}, i::Integer)
    j = Int(i - 1) * w
    return (j >> 5) + 1, j & 0b011111
end

@inline function get_chunk_id{w}(::Buffer{w,UInt64}, i::Integer)
    j = Int(i - 1) * w
    return (j >> 6) + 1, j & 0b111111
end


@inline function getindex{w,T}(buf::Buffer{w,T}, i::Integer)
    k, r = get_chunk_id(buf, i)
    W = bitsof(T)
    @inbounds begin
        a = buf.data[k] >> r
        if r + w ≤ W
            return a & mask(T, w)
        else
            b = buf.data[k+1] & mask(T, (w + r) - W)
            return a | (b << (W - r))
        end
    end
end

# these width values don't cross a boundary, therefore branching can be safely removed
for w in [1, 2, 4, 8, 16, 32]
    @eval begin
        @inline function getindex{T}(buf::Buffer{$w,T}, i::Integer)
            k, r = get_chunk_id(buf, i)
            @inbounds return (buf.data[k] >> r) & mask(T, $w)
        end
    end
end

@inline function getindex(buf::Buffer{64,UInt64}, i::Integer)
    @inbounds return buf.data[i]
end

# https://graphics.stanford.edu/~seander/bithacks.html#MaskedMerge
@inline mergebits(a, b, mask) = a $ ((a $ b) & mask)

@inline function setindex!{w,T}(buf::Buffer{w,T}, x::T, i::Integer)
    k, r = get_chunk_id(buf, i)
    W = bitsof(T)
    @inbounds begin
        a = buf.data[k]
        b = x << r
        buf.data[k] = mergebits(a, b, mask(T, w) << r)
        if r + w > W
            a = buf.data[k+1]
            b = x >> (W - r)
            buf.data[k+1] = mergebits(a, b, mask(T, (w + r) - W))
        end
    end
    return x & mask(T, w)
end

for w in [1, 2, 4, 8, 16, 32]
    @eval begin
        @inline function setindex!{T}(buf::Buffer{$w,T}, x::T, i::Integer)
            k, r = get_chunk_id(buf, i)
            @inbounds begin
                a = buf.data[k]
                b = x << r
                buf.data[k] = mergebits(a, b, mask(T, $w) << r)
            end
            return x & mask(T, $w)
        end
    end
end

@inline function setindex!(buf::Buffer{64,UInt64}, x::UInt64, i::Integer)
    @inbounds return buf.data[i] = x
end


function fill!{w,T}(buf::Buffer{w,T}, x::T, lo::Int, hi::Int)
    for i in lo:hi
        setindex!(buf, x, i)
    end
    return buf
end

for w in [1, 2, 4, 8, 16, 32, 64]
    @eval begin
        function fill!{T}(buf::Buffer{$w,T}, x::T, ::Int, ::Int)
            chunk = T(0)
            W = wordsize(buf)
            x &= mask(T, $w)
            for _ in 1:div(W, $w)
                chunk = chunk << $w | x
            end
            fill!(buf.data, chunk)
            return buf
        end
    end
end

function fill0!{w,T}(buf::Buffer{w,T})
    fill!(buf.data, T(0))
    return buf
end

function fill1!{w,T}(buf::Buffer{w,T})
    fill!(buf.data, ~T(0))
    return buf
end
