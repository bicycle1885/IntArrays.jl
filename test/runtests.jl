using IntArrays
using FactCheck

srand(12345)

const Ts = (UInt8, UInt16, UInt32, UInt64)

facts("IntVector") do
    context("conversion") do
        data = [0x00, 0x01]
        ivec = IntVector{1}(data)
        @fact typeof(ivec) --> IntArray{1,UInt8,1}
        @fact convert(IntVector{1}, data) --> ivec
    end

    context("allocation") do
        for T in Ts
            ivec = IntVector{3,T}(10)
            @fact length(ivec) --> 10
            @fact size(ivec) --> (10,)
            @fact typeof(ivec) --> IntArray{3,T,1}
        end
    end

    context("several bit widths") do
        n = 123
        for T in Ts, w in 1:sizeof(T)*8
            data = rand(T(0):T(2)^w-T(1), n)
            ivec = IntVector{w,T}(data)
            for i in 1:n
                @fact ivec[i] --> data[i]
            end
        end
    end

    context("unsigned integers") do
        n = 1000
        for T in Ts
            data = rand(T(0):T(100), n)
            ivec = IntVector{10,T}(data)
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
            @fact_throws BoundsError ivec[n+1]
        end
    end

    context("empty") do
        for T in Ts
            ivec = IntVector{3,T}()
            @fact size(ivec) --> (0,)
            @fact length(ivec) --> 0
            @fact_throws BoundsError ivec[1]
            @fact_throws BoundsError ivec[1] = 0x00
        end
    end
end

facts("IntMatrix") do
    context("conversion") do
        data = [0x00 0x01; 0x02 0x03]
        imat = IntMatrix{2}(data)
        @fact typeof(imat) --> IntArray{2,UInt8,2}
        @fact convert(IntMatrix{2}, data) --> imat
    end

    context("allocation") do
        for T in Ts
            imat = IntMatrix{3,T}(4, 5)
            @fact length(imat) --> 20
            @fact size(imat) --> (4, 5)
            @fact typeof(imat) --> IntArray{3,T,2}
        end
    end

    context("unsigned integers") do
        m = 41
        n = 17
        for T in Ts
            data = rand(T(0):T(100), m, n)
            imat = IntMatrix{10,T}(data)
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
            @fact_throws BoundsError imat[m+1,n]
            @fact_throws BoundsError imat[m,n+1]
            @fact_throws BoundsError imat[m+1,n+1]
        end
    end

    context("empty") do
        for T in Ts
            imat = IntMatrix{3,T}()
            @fact size(imat) --> (0, 0)
            @fact length(imat) --> 0
            @fact_throws BoundsError imat[1,1]
            @fact_throws BoundsError imat[1,1] = 0x00
        end
    end
end
