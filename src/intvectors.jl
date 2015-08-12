type IntVector{T<:Unsigned,w}
    buffer::Buffer{w}
    len::Int
end

const W = 64

function convert{T,w}(::Type{IntVector{T,w}}, v::Vector)
    len = length(v)
    buf = Buffer{w}(len)
    for i in 1:len
        buf[i] = v[i] % UInt64
    end
    return IntVector{T,w}(buf, len)
end

length(v::IntVector) = v.len

function getindex{T<:Unsigned,w}(v::IntVector{T,w}, i::Integer)
    return v.buffer[i] % T
end

function setindex!{T,w}(v::IntVector{T,w}, x::Unsigned, i::Integer)
    return v.buffer[i] = x % UInt64
end
