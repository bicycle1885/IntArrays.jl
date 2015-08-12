using IntArrays

srand(12345)

function bench_getindex(array, n)
    # warming up
    for i in 1:div(endof(array), 10)
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
    for i in 1:div(endof(array), 10)
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
    columns = ["type", "size", "w", "bench_getindex", "bench_setindex"]
    println(join(columns, '\t'))
    for T in [UInt8, UInt16], size in [1_000_000], w in 1:sizeof(T)*8
        range = typemin(T):typemax(T)
        if baseline
            array = Vector{T}(rand(range, size))
        else
            array = IntVector{w,T}(rand(range, size))
        end
        print(T, '\t', size, '\t', w, '\t')
        print(bench_getindex(array, 100), '\t')
        print(bench_setindex(array, 100), '\t')
        println()
    end
end
