type Buffer{w}
    data::Vector{UInt64}
    len::Int
    function Buffer(len::Integer)
        new(zeros(UInt64, cld(len * w, W)), len)
    end
end

# word size
const W = 64

function getindex{w}(buf::Buffer{w}, i::Integer)
    data = buf.data
    k, r = divrem((i - 1) * w, W)
    if r + w ≤ W
        chunk = (data[k+1] >> (W - (r + w))) & rmask(w)
    else
        left = (data[k+1] & rmask(W - r)) << ((r + w) - W)
        right = data[k+2] >> (2W - (r + w))
        chunk = left | right
    end
    return chunk
end

function setindex!{w}(buf::Buffer{w}, x::UInt64, i::Integer)
    x &= rmask(w)
    data = buf.data
    k, r = divrem((i - 1) * w, W)
    if r + w ≤ W
        data[k+1] = (data[k+1] & ~mask(r, w)) | (x << (W - (r + w)))
    else
        data[k+1] = (data[k+1] & ~rmask(W - r)) | (x >>> ((r + w) - W))
        data[k+2] = (data[k+2] & ~mask(0, (r + w) - W)) | (x << (2W - (r + w)))
    end
    return x
end

function rmask(w::Int)
    ~UInt64(0) >> (W - w)
end

function mask(r, w)
    rmask(w) << (W - (r + w))
end
