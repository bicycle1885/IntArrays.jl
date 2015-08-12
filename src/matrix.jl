typealias IntMatrix{w,T} IntArray{w,T,2}

call{w,T}(::Type{IntMatrix{w,T}}, m::Integer, n::Integer) = IntArray{w,T,2}(Buffer{w}(m * n), (m, n))

function convert{w,T}(::Type{IntMatrix{w}}, array::AbstractMatrix{T})
    return convert(IntArray{w,T,2}, array)
end

function convert{w,T}(::Type{IntMatrix{w,T}})
    return IntArray{w,T,2}(Buffer{w}(0), (0,0))
end
