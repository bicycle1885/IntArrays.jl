typealias IntMatrix{w,T} IntArray{w,T,2}

function convert{w,T}(::Type{IntMatrix{w}}, array::AbstractMatrix{T})
    return convert(IntArray{w,T,2}, array)
end

function convert{w,T}(::Type{IntMatrix{w,T}})
    return IntArray{w,T,2}(Buffer{w}(0), (0,0))
end
