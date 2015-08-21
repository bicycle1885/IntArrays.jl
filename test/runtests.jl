using IntArrays
using FactCheck

srand(12345)

const Ts = (UInt8, UInt16, UInt32, UInt64)

facts("conversion") do
    context("IntVector") do
        data = [0x00, 0x01, 0x02]
        ivec = IntArray{2}(data)
        @fact typeof(ivec) --> IntArray{2,UInt8,1}
        @fact typeof(ivec) --> IntVector{2,UInt8}

        ivec = convert(IntVector{2}, data)
        @fact typeof(ivec) --> IntArray{2,UInt8,1}
        @fact typeof(ivec) --> IntVector{2,UInt8}
    end
    context("IntMatrix") do
        data = [0x00 0x01; 0x02 0x03; 0x04 0x05]
        imat = IntArray{3}(data)
        @fact typeof(imat) --> IntArray{3,UInt8,2}
        @fact typeof(imat) --> IntMatrix{3,UInt8}

        imat = convert(IntMatrix{3}, data)
        @fact typeof(imat) --> IntArray{3,UInt8,2}
        @fact typeof(imat) --> IntMatrix{3,UInt8}
    end
    context("three-dimensional array") do
        data = rand(0x00:0x03, 2, 3, 4)
        iarr = IntArray{2}(data)
        @fact typeof(iarr) --> IntArray{2,UInt8,3}
    end
end

facts("construction") do
    context("IntVector") do
        ivec = IntArray{9,UInt16}(10)
        @fact typeof(ivec) --> IntArray{9,UInt16,1}
        @fact size(ivec) --> (10,)
        @fact length(ivec) --> 10
    end
    context("IntMatrix") do
        imat = IntMatrix{3,UInt8}(2, 3)
        @fact typeof(imat) --> IntArray{3,UInt8,2}
        @fact size(imat) --> (2, 3)
    end
    context("invalid width") do
        @fact_throws Exception IntArray{9,UInt8,1}(4)
        @fact_throws Exception IntArray{20,UInt16,1}(4)
        @fact_throws Exception IntArray{50,UInt32,1}(4)
    end
    context("mmap") do
        @fact typeof(IntArray{2,UInt8}(10, true)) --> IntArray{2,UInt8,1}
    end
end

facts("similar") do
    context("IntVector") do
        data = rand(0x00:0x02, 10)
        ivec = IntVector{2}(data)
        @fact similar(ivec) === ivec --> false
        @fact size(similar(ivec)) --> (10,)
        @fact typeof(similar(ivec)) --> IntVector{2,UInt8}
        @fact size(similar(ivec, UInt16)) --> (10,)
        @fact typeof(similar(ivec, UInt16)) --> IntVector{2,UInt16}
        @fact size(similar(ivec, UInt16, (20,))) --> (20,)
        @fact typeof(similar(ivec, UInt16, (20,))) --> IntVector{2,UInt16}
    end
end

facts("getindex") do
    context("IntVector") do
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
    context("IntMatrix") do
        # 2x3
        data = [0x00 0x01 0x02; 0x03 0x04 0x05]
        imat = IntArray{4}(data)
        # linear indexing
        @fact_throws BoundsError imat[0]
        @fact imat[1] --> 0x00
        @fact imat[2] --> 0x03
        @fact imat[3] --> 0x01
        @fact imat[4] --> 0x04
        @fact imat[5] --> 0x02
        @fact imat[6] --> 0x05
        @fact_throws BoundsError imat[7]
        # tuples
        @fact_throws BoundsError imat[0,1]
        @fact imat[1,1] --> 0x00
        @fact imat[1,2] --> 0x01
        @fact imat[1,3] --> 0x02
        @fact imat[2,1] --> 0x03
        @fact imat[2,2] --> 0x04
        @fact imat[2,3] --> 0x05
        @fact_throws BoundsError imat[1,4]
        @fact_throws BoundsError imat[2,4]
        @fact_throws BoundsError imat[3,1]
    end
end

facts("setindex!") do
    context("IntVector") do
        data = [0x00, 0x01, 0x02]
        ivec = IntArray{2}(data)
        @fact_throws BoundsError ivec[0] = 0x00
        ivec[1] = 0x01
        @fact ivec[1] --> 0x01
        ivec[2] = 0x02
        @fact ivec[2] --> 0x02
        ivec[3] = 0x03
        @fact ivec[3] --> 0x03
        @fact_throws BoundsError ivec[4] = 0x01
    end
    context("IntMatrix") do
        data = [0x00 0x00 0x00; 0x00 0x00 0x00]
        imat = IntArray{2}(data)
        # linear
        @fact_throws BoundsError imat[0] = 0x00
        imat[2] = 0x01
        @fact imat[2] --> 0x01
        imat[2] = 0x00
        @fact imat[2] --> 0x00
        @fact_throws BoundsError imat[7] = 0x00
        # tuple
        imat[1,1] = 0x01
        @fact imat[1,1] --> 0x01
        imat[1,3] = 0x03
        @fact imat[1,3] --> 0x03
        @fact_throws BoundsError imat[1,4] = 0x00
        @fact_throws BoundsError imat[3,1] = 0x01
    end
end

facts("comparison") do
    a = IntVector{2}([0x00, 0x01, 0x02, 0x03])
    b = IntVector{2}([0x00, 0x01, 0x02, 0x03])
    c = IntVector{4}([0x00, 0x01, 0x02, 0x03])
    d = IntVector{2}([0x00, 0x02, 0x02, 0x03])
    e = IntMatrix{2}([0x00  0x02; 0x01  0x03])
    @fact a == b --> true
    @fact a == c --> true
    @fact a == d --> false
    @fact a == e --> false
end

facts("sizeof") do
    context("smaller bits") do
        n = 100
        data = rand(0x00:0x01, n)
        @fact sizeof(IntVector{1}(data)) --> less_than(sizeof(data))
        @fact sizeof(IntVector{2}(data)) --> less_than(sizeof(data))
        @fact sizeof(IntVector{3}(data)) --> less_than(sizeof(data))
        @fact sizeof(IntVector{4}(data)) --> less_than(sizeof(data))
    end
end

facts("copy") do
    context("same length") do
        data = rand(0x00:0x03, 10)
        ivec = IntVector{2,UInt8}(data)
        @fact copy(ivec) --> ivec
        @fact typeof(copy(ivec)) --> typeof(ivec)
        @fact size(copy(ivec)) --> size(ivec)
        ivec′ = IntVector{2,UInt8}(10)
        @fact copy!(ivec′, ivec) === ivec′ --> true
        @fact ivec′ --> ivec
    end
    context("larger") do
        data = rand(0x00:0x03, 10)
        ivec = IntVector{2,UInt8}(data)
        ivec′ = IntVector{2,UInt8}(20)
        copy!(ivec′, ivec)
        @fact ivec′[1:10] --> ivec
    end
    context("smaller") do
        data = rand(0x00:0x03, 10)
        ivec = IntVector{2,UInt8}(data)
        ivec′ = IntVector{2,UInt8}(5)
        @fact_throws BoundsError copy!(ivec′, ivec)
    end
end

facts("fill!") do
    context("IntVector") do
        n = 100
        data = rand(0x00:0x03, n)
        for x in 0x00:0x03
            ivec = IntVector{2}(data)
            @fact fill!(ivec, x) === ivec --> true
            @fact ivec --> ones(UInt8, n) * x
        end
    end
    context("IntMatrix") do
        m, n = 10, 11
        data = rand(0x00:0x03, (m, n))
        for x in 0x00:0x03
            #imat = IntMatrix{2}(m, n)
            #@fact fill!(imat, x) === imat --> true
            #@fact imat --> ones(UInt8, (m, n)) * x
        end
    end
end

facts("reverse") do
    ivec = IntVector{2,UInt8}()
    @fact reverse!(ivec) === ivec --> true
    @fact ivec --> isempty

    ivec = IntVector{2}([0x00])
    @fact reverse!(ivec) === ivec --> true
    @fact ivec --> [0x00]

    ivec = IntVector{2}([0x00, 0x01])
    @fact reverse!(ivec) === ivec --> true
    @fact ivec --> [0x01, 0x00]

    ivec = IntVector{2}([0x00, 0x01, 0x02])
    @fact reverse!(ivec) === ivec --> true
    @fact ivec --> [0x02, 0x01, 0x00]

    ivec = IntVector{2}([0x00, 0x01, 0x02, 0x03])
    @fact reverse!(ivec) === ivec --> true
    @fact ivec --> [0x03, 0x02, 0x01, 0x00]
end

facts("push!/pop!") do
    ivec = IntVector{4,UInt8}()
    @fact length(ivec) --> 0
    @fact push!(ivec, 3) === ivec --> true
    @fact length(ivec) --> 1
    @fact ivec[end] --> 3
    @fact pop!(ivec) --> 3
    @fact length(ivec) --> 0
end

facts("append!") do
    ivec = IntVector{4}([0x00])
    @fact append!(ivec, [0x01, 0x02]) === ivec --> true
    @fact ivec --> [0x00, 0x01, 0x02]
    append!(ivec, [3, 4])
    @fact ivec --> [0x00, 0x01, 0x02, 0x03, 0x04]
end

facts("radixsort") do
    data = UInt8[]
    ivec = IntVector{1}(data)
    @fact radixsort(ivec) --> issorted

    data = [0x00]
    ivec = IntVector{2}(data)
    @fact radixsort(ivec) --> issorted

    data = [0x01, 0x00]
    ivec = IntVector{2}(data)
    @fact radixsort(ivec) --> issorted

    n = 101
    data = rand(0x00:0x01, n)
    ivec = IntVector{1}(data)
    @fact radixsort(ivec) --> issorted
    @fact radixsort!(ivec) === ivec --> true
    @fact issorted(ivec) --> true
    data = rand(0x00:0x03, n)
    ivec = IntVector{2}(data)
    @fact radixsort(ivec) --> issorted
    @fact radixsort!(ivec) === ivec --> true
    @fact issorted(ivec) --> true
    data = rand(0x00:0x07, n)
    ivec = IntVector{3}(data)
    @fact radixsort(ivec) --> issorted
    @fact radixsort!(ivec) === ivec --> true
    @fact issorted(ivec) --> true
end

# thorough and time-consuming tests for each combination of width and element type

facts("conversion") do
    context("empty") do
        for T in Ts, w in 1:sizeof(T)*8
            data = Vector{T}(0)
            @fact typeof(IntArray{w}(data)) --> IntArray{w,T,1}
            @fact length(IntArray{w}(data)) --> 0

            data = Matrix{T}(0, 0)
            @fact typeof(IntArray{w}(data)) --> IntArray{w,T,2}
            @fact size(IntArray{w}(data)) --> (0, 0)
        end
    end
    context("small") do
        for T in Ts, w in 1:sizeof(T)*8
            data = T[0x00, 0x01]
            @fact typeof(IntArray{w}(data)) --> IntArray{w,T,1}
            @fact length(IntArray{w}(data)) --> 2

            data = T[0x00 0x01 0x00; 0x01 0x00 0x01]
            @fact typeof(IntArray{w}(data)) --> IntArray{w,T,2}
            @fact size(IntArray{w}(data)) --> (2, 3)
        end
    end
    context("large") do
        n = 1000
        for T in Ts, w in 1:sizeof(T)*8
            data = rand(T, n)
            @fact typeof(IntArray{w}(data)) --> IntArray{w,T,1}
            @fact length(IntArray{w}(data)) --> n
        end
    end
end

facts("random run") do
    context("IntVector") do
        n = 123
        for T in Ts, w in 1:sizeof(T)*8
            data = rand(T(0):T(2)^w-T(1), n)
            ivec = IntVector{w,T}(data)
            for i in 1:n
                @fact ivec[i] --> data[i]
            end

            # random update
            for _ in 1:100
                i = rand(1:n)
                x::T = rand(T) % w
                data[i] = x
                ivec[i] = x
                @fact ivec[i] --> data[i]
            end
            for i in 1:n
                @fact ivec[i] --> data[i]
            end
            @fact_throws BoundsError ivec[0]
            @fact_throws BoundsError ivec[n+1]

            # sort
            sort!(data)
            radixsort!(ivec)
            for i in 1:n
                @fact ivec[i] --> data[i]
            end

            # random push!/pop!
            for _ in 1:100
                if rand() < 0.5
                    x::T = rand(T) % w
                    push!(ivec, x)
                    push!(data, x)
                else
                    pop!(ivec)
                    pop!(data)
                end
                @fact length(ivec) --> length(data)
                @fact ivec[end] --> data[end]
            end
            while !isempty(ivec)
                x = pop!(ivec)
                y = pop!(data)
                @fact x --> y
            end
            @fact isempty(ivec) --> true
        end
    end
    context("IntMatrix") do
        m, n = 11, 28
        for T in Ts, w in 1:sizeof(T)*8
            data = rand(T(0):T(2)^w-T(1), (m, n))
            imat = IntMatrix{w,T}(data)
            for i in 1:m, j in 1:n
                @fact imat[i,j] --> data[i,j]
            end

            # random update
            for _ in 1:100
                i = rand(1:m)
                j = rand(1:n)
                x::T = rand(T) % w
                data[i,j] = x
                imat[i,j] = x
                @fact imat[i,j] --> data[i,j]
            end
            for i in 1:m, j in 1:n
                @fact imat[i,j] --> data[i,j]
            end
        end
    end
end
