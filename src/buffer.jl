# internal data for packed integers
type Buffer{w}
    data::Vector{UInt64}
    len::Int
    function Buffer(len::Integer)
        new(zeros(UInt64, cld(len * w, W)), len)
    end
end

# word size
const W = 64

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

@inline function setindex!{w}(buf::Buffer{w}, x::UInt64, i::Integer)
    x &= rmask(w)
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

@inline function rmask(w)
    ~UInt64(0) >> (W - w)
end

@inline function mask(r, w)
    rmask(w) << (W - (r + w))
end

@inline function divrem64(n::Integer)
    return (n >> 6, n & 0b111111)
end
