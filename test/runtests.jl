using IntArrays
using FactCheck

srand(12345)

facts("IntVector") do
    context("UInt64") do
        n = 1000
        data = rand(UInt64(0):UInt(100), n)
        ivec = IntVector{UInt64,10}(data)
        for i in 1:endof(data)
            @fact ivec[i] --> data[i]
            @fact typeof(ivec[i]) --> UInt64
        end
        for _ in 1:100
            i = rand(1:n)
            x::UInt64 = rand(0:100)
            data[i] = x
            ivec[i] = x
            @fact ivec[i] --> data[i]
        end
        for i in 1:endof(data)
            @fact ivec[i] --> data[i]
        end
    end
    context("Int64") do
        n = 1000
        data = rand(-100:100, n)
        ivec = IntVector{Int64,10}(data)
        for i in 1:endof(data)
            @fact ivec[i] --> data[i]
            @fact typeof(ivec[i]) --> Int64
        end
        for _ in 1:100
            i = rand(1:n)
            x = rand(0:100)
            data[i] = x
            ivec[i] = x
            @fact ivec[i] --> data[i]
        end
        for i in 1:endof(data)
            @fact ivec[i] --> data[i]
        end
    end
end
