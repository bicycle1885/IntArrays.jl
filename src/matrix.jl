typealias IntMatrix{w,T} IntArray{w,T,2}

function call{w,T}(::Type{IntMatrix{w,T}}, m::Integer, n::Integer, mmap::Bool=false)
    return IntArray{w,T}((m, n), mmap)
end

function call{w,T}(::Type{IntMatrix{w,T}}, mmap::Bool=false)
    return IntArray{w,T}((0, 0), mmap)
end

function convert{w,T}(::Type{IntMatrix{w}}, matrix::AbstractMatrix{T})
    return convert(IntArray{w,T,2}, matrix)
end
