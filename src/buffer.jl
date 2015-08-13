# internal data for packed integers
type Buffer{w}
    data::Vector{UInt64}
    function Buffer(len::Integer, mmap::Bool=false)
        buflen = cld(len * w, W)
        data = mmap ? Mmap.mmap(Vector{UInt64}, buflen) : Vector{UInt64}(buflen)
        return new(data)
    end
end

# word size
const W = 64

@inline function rmask(w)
    ~UInt64(0) >> (W - w)
end

@inline function mask(r, w)
    rmask(w) << (W - (r + w))
end

@inline function divrem64(n::Integer)
    return (n >> 6, n & 0b111111)
end

@inline function getindex{w}(buf::Buffer{w}, i::Integer)
    data = buf.data
    k, r = divrem64((i - 1) * w)
    if r + w ≤ W
        @inbounds chunk = (data[k+1] >> (W - (r + w))) & rmask(w)
    else
        @inbounds left = (data[k+1] & rmask(W - r)) << ((r + w) - W)
        @inbounds right = data[k+2] >> (2W - (r + w))
        chunk = left | right
    end
    return chunk
end

for w in [1, 2, 4, 8, 16, 32]
    @eval begin
        @inline function getindex(buf::Buffer{$w}, i::Integer)
            k, r = divrem64((i - 1) * $w)
            @inbounds chunk = (buf.data[k+1] >> ($(W - w) - r)) & $(rmask(w))
            return chunk
        end
    end
end

@inline function getindex(buf::Buffer{64}, i::Integer)
    @inbounds return buf.data[i]
end

@inline function setindex!{w}(buf::Buffer{w}, x::UInt64, i::Integer)
    data = buf.data
    k, r = divrem64((i - 1) * w)
    if r + w ≤ W
        @inbounds data[k+1] = (data[k+1] & ~mask(r, w)) | (x << (W - (r + w)))
    else
        @inbounds data[k+1] = (data[k+1] & ~rmask(W - r)) | (x >>> ((r + w) - W))
        @inbounds data[k+2] = (data[k+2] & ~mask(0, (r + w) - W)) | (x << (2W - (r + w)))
    end
    return x
end

# these width values don't cross a boundary, therefore branching can be safely removed
for w in [1, 2, 4, 8, 16, 32]
    @eval begin
        @inline function setindex!(buf::Buffer{$w}, x::UInt64, i::Integer)
            k, r = divrem64((i - 1) * $w)
            k += 1
            @inbounds a = buf.data[k]
            b = x << ($(W - w) - r)
            mask = $(rmask(w)) << ($(W - w) - r)
            # see: https://graphics.stanford.edu/~seander/bithacks.html#MaskedMerge
            @inbounds buf.data[k] = a $ ((a $ b) & mask)
            return x
        end
    end
end

@inline function setindex!(buf::Buffer{64}, x::UInt64, i::Integer)
    @inbounds return buf.data[i] = x
end
