using IntArrays
using FactCheck

srand(12345)

facts("IntVector") do
    context("unsigned integers") do
        n = 1000
        for T in (UInt8, UInt16, UInt32, UInt64)
            data = rand(T(0):T(100), n)
            ivec = IntVector{T,10}(data)
            for i in 1:endof(data)
                @fact ivec[i] --> data[i]
                @fact typeof(ivec[i]) --> T
            end
            for _ in 1:100
                i = rand(1:n)
                x::T = rand(0:100)
                data[i] = x
                ivec[i] = x
                @fact ivec[i] --> data[i]
            end
            for i in 1:endof(data)
                @fact ivec[i] --> data[i]
            end
        end
    end
end

facts("IntMatrix") do
    context("unsigned integers") do
        m = 41
        n = 17
        for T in (UInt8, UInt16, UInt32, UInt64)
            data = rand(T(0):T(100), m, n)
            imat = IntMatrix{T,10}(data)
            for i in 1:m, j in 1:n
                @fact imat[i,j] --> data[i,j]
                @fact typeof(imat[i,j]) --> T
            end
            for _ in 1:100
                i = rand(1:m)
                j = rand(1:n)
                x::T = rand(0:100)
                data[i,j] = x
                imat[i,j] = x
                @fact imat[i,j] --> data[i,j]
            end
            for i in 1:m, j in 1:n
                @fact imat[i,j] --> data[i,j]
                @fact typeof(imat[i,j]) --> T
            end
        end
    end
end
