using IntArrays

srand(12345)

function bench_getindex(array, n)
    # warming up
    for i in 1:endof(array)
        array[i]
    end
    t = @elapsed for _ in 1:n
        for i in 1:endof(array)
            array[i]
        end
    end
    return t / (n * length(array))
end

function bench_setindex(array, n)
    # warming up
    x = 0x00
    for i in 1:endof(array)
        array[i] = x
    end
    t = @elapsed for _ in 1:n
        for i in 1:endof(array)
            array[i] = x
        end
    end
    return t / (n * length(array))
end

let
    baseline = !isempty(ARGS) && shift!(ARGS) == "--baseline"
    Ts = [UInt8, UInt16, UInt32, UInt64]
    size = 100_000
    n = 100
    if baseline
        columns = ["type", "eltype", "bench_getindex", "bench_setindex"]
        println(join(columns, '\t'))
        for T in Ts
            array = Vector{T}(rand(typemin(T):typemax(T), size))
            print(typeof(array), '\t', eltype(array), '\t')
            print(bench_getindex(array, n), '\t')
            print(bench_setindex(array, n), '\n')
        end
    else
        columns = ["type", "eltype", "w", "bench_getindex", "bench_setindex"]
        println(join(columns, '\t'))
        for T in Ts, w in 1:sizeof(T)*8
            array = IntVector{w,T}(rand(typemin(T):typemax(T), size))
            print(typeof(array), '\t', eltype(array), '\t', w, '\t')
            print(bench_getindex(array, n), '\t')
            print(bench_setindex(array, n), '\n')
        end
    end
end
