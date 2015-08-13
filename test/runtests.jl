using IntArrays
using FactCheck

srand(12345)

const Ts = (UInt8, UInt16, UInt32, UInt64)

facts("IntArray") do
    context("conversion") do
        data = [0x00 0x01; 0x02 0x03]
        imat = IntArray{3}(data)
        @fact typeof(imat) --> IntArray{3,UInt8,2}
        @fact eltype(imat) --> UInt8
    end
    context("getindex") do
        data = [0x00, 0x01, 0x02, 0x03, 0x04]
        ivec = IntArray{3}(data)
        @fact_throws BoundsError ivec[0]
        @fact ivec[1] --> 0x00
        @fact ivec[2] --> 0x01
        @fact ivec[3] --> 0x02
        @fact ivec[4] --> 0x03
        @fact ivec[5] --> 0x04
        @fact_throws BoundsError ivec[6]
    end
    context("setindex") do
        data = [0x00 0x00; 0x00 0x00]
        imat = IntArray{2}(data)
        @fact (imat[1,1] = 0x01) --> 0x01
        @fact imat[1,1] --> 0x01
        @fact (imat[1,2] = 2) --> 0x02
        @fact imat[1,2] --> 0x02
        @fact (imat[2,1] = 0x0003) --> 0x03
        @fact imat[2,1] --> 0x03
    end
    context("sizeof") do
        n = 100
        data = rand(0x00:0x03, n)
        @fact sizeof(IntVector{2}(data)) --> less_than(sizeof(data))
        @fact sizeof(IntVector{3}(data)) --> less_than(sizeof(data))
        @fact sizeof(IntVector{4}(data)) --> less_than(sizeof(data))
    end
    context("fill!") do
        n = 100
        data = rand(0x00:0x03, n)
        ivec = IntVector{2}(data)
        for x in 0x00:0x03
            fill!(ivec, x)
            @fact ivec --> ones(UInt8, n) * x
        end
    end
end

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

facts("Mmap backed array") do
    context("small") do
        n = 10
        ivec = IntArray{2,UInt8}(n, true)
        @fact (ivec[2] = 0x02) --> 0x02
        @fact ivec[2] --> 0x02
        fill!(ivec, 0x00)
        for i in 1:n
            @fact ivec[i] --> 0x00
        end
        fill!(ivec, 0x03)
        for i in 1:n
            @fact ivec[i] --> 0x03
        end
    end
    context("large") do
        n = 2^30
        ivec = IntArray{2,UInt8}(n, true)
        @fact (ivec[2] = 0x02) --> 0x02
        @fact ivec[2] --> 0x02
        fill!(ivec, 0x01)
        @fact ivec[1] --> 0x01
        @fact ivec[div(n,2)] --> 0x01
        @fact ivec[end] --> 0x01
    end
    context("vector") do
        n = 10
        ivec = IntVector{2,UInt16}(n, true)
        @fact (ivec[2] = 0x02) --> 0x02
        @fact ivec[2] --> 0x02
    end
    context("matrix") do
        m, n = 3, 10
        imat = IntMatrix{2,UInt16}(m, n, true)
        @fact (imat[1,3] = 0x02) --> 0x02
        @fact imat[1,3] --> 0x02
    end
end
