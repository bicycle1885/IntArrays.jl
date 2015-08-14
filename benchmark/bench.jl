using IntArrays

function bench_getindex(array, n)
    s = zero(eltype(array))
    for i in 1:endof(array)
        s += array[i]
    end
    t = @elapsed for _ in 1:n
        for i in 1:endof(array)
            s += array[i]
        end
    end
    return t / (n * length(array))
end

function bench_setindex(array, n)
    x = rand(0x00:0x01)
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

function bench_fill0(array, n)
    fill!(array, 0)
    t = @elapsed for _ in 1:n
        fill!(array, 0)
    end
    return t / n
end

function bench_fill1(array, n)
    fill!(array, 0)
    t = @elapsed for _ in 1:n
        fill!(array, 1)
    end
    return t / n
end

function bench_copy(array, n)
    copy(array)
    t = @elapsed for _ in 1:n
        copy(array)
    end
    return t / n
end

function bench_copysort(array, n)
    tmp = similar(array)
    sort!(copy!(tmp, array))
    t = @elapsed for _ in 1:n
        sort!(copy!(tmp, array))
    end
    return t / n
end

let
    srand(12345)
    baseline = !isempty(ARGS) && shift!(ARGS) == "--baseline"
    Ts = [UInt8, UInt16, UInt32, UInt64]
    size = 100_000
    small = 5
    large = 100
    benchmarks = [
        (:bench_getindex, large),
        (:bench_setindex, large),
        (:bench_fill0, small),
        (:bench_fill1, small),
        (:bench_copy, small),
        (:bench_copysort, small),
    ]
    if baseline
        columns = ["type", "eltype"]
        println(join(vcat(columns, [name for (name, _) in benchmarks]), '\t'))
        for T in Ts
            array = Vector{T}(rand(typemin(T):typemax(T), size))
            print(typeof(array), '\t', eltype(array))
            for (benchmark, n) in benchmarks
                gc()
                print('\t', eval(benchmark)(array, n))
            end
            println()
        end
    else
        columns = ["type", "eltype", "w"]
        println(join(vcat(columns, [name for (name, _) in benchmarks]), '\t'))
        for T in Ts, w in 1:sizeof(T)*8
            array = IntVector{w,T}(rand(typemin(T):typemax(T), size))
            print(typeof(array), '\t', eltype(array), '\t', w)
            for (benchmark, n) in benchmarks
                gc()
                print('\t', eval(benchmark)(array, n))
            end
            println()
        end
    end
end
