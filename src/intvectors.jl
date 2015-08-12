type IntVector{T<:Integer,w}
    data::Vector{UInt64}
    len::Int
end

const W = 64

function convert{T,w}(::Type{IntVector{T,w}}, v::Vector{T})
    len = length(v)
    data = zeros(UInt64, cld(len * w, W))
    for i in 1:endof(v)
        j = (i - 1) * w
        k, r = divrem(j, W)
        x = v[i]
        if T <: Signed
            @assert -2^(w-1) ≤ x ≤ 2^(w-1) - 1
        elseif T <: Unsigned
            @assert 0 ≤ x ≤ 2^w - 1
        end
        if r + w ≤ W
            data[k+1] |= ((x % UInt64) & rmask(w)) << (W - (r + w))
        else
            data[k+1] |= ((x % UInt64) & rmask(w)) >> ((r + w) - W)
            data[k+2] |= ((x % UInt64) & rmask(w)) << (2W - (r + w))
        end
    end
    return IntVector{T,w}(data, len)
end

length(v::IntVector) = v.len

function getindex{T<:Unsigned,w}(v::IntVector{T,w}, i::Integer)
    len = length(v)
    data = v.data
    j = (i - 1) * w
    k, r = divrem(j, W)
    if r + w ≤ W
        num = (data[k+1] >> (W - (r + w))) & rmask(w)
    else
        left = (data[k+1] & rmask(W - r)) << ((r + w) - W)
        right = data[k+2] >> (2W - (r + w))
        num = left | right
    end
    return num % T
end

function getindex{T<:Signed,w}(v::IntVector{T,w}, i::Integer)
    len = length(v)
    data = v.data
    j = (i - 1) * w
    k, r = divrem(j, W)
    if r + w ≤ W
        num = (data[k+1] >> (W - (r + w))) & rmask(w)
    else
        left = (data[k+1] & rmask(W - r)) << ((r + w) - W)
        right = data[k+2] >> (2W - (r + w))
        num = left | right
    end
    pad = ifelse(num >> (w - 1) == 1, ~UInt64(0) << w, UInt64(0))
    return (num | pad) % T
end

function setindex!{T,w}(v::IntVector{T,w}, x::UInt64, i::Integer)
    data = v.data
    j = (i - 1) * w
    k, r = divrem(j, W)
    if r + w ≤ W
        data[k+1] = (data[k+1] & ~mask(r, w)) | (x << (W - (r + w)))
    else
        data[k+1] = (data[k+1] & ~rmask(W - r)) | (x >>> ((r + w) - W))
        data[k+2] = (data[k+2] & ~mask(0, (r + w) - W)) | (x << (2W - (r + w)))
    end
    return x
end

setindex!(v::IntVector, x::Int64, i::Integer) = setindex!(v, reinterpret(UInt64, x), i)

function rmask(w::Int)
    ~UInt64(0) >> (W - w)
end

function mask(r, w)
    rmask(w) << (W - (r + w))
end
