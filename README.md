# IntArrays

[![Build Status](https://travis-ci.org/bicycle1885/IntArrays.jl.svg?branch=master)](https://travis-ci.org/bicycle1885/IntArrays.jl)

`IntArray` is an array of packed integers.

The `IntArray` type is defined as follows:

```julia
type IntArray{w,T<:Unsigned,n} <: AbstractArray{T,n}
```

where

* `w`: the width of integers (i.e. the number of bits to encode an integer)
* `T`: the type of integers
* `n`: the number of dimensions in the array.

This works like normal arrays, but each element is packed in a buffer as compact as possible.
Hence, the total size is about `w * length(int_array)` bits.

You can think of it as a generalization of `BitArray` defined in the standard library:
`BitArray` can store only `Bool` values, whereas `IntArray` can store any (unsigned) integers.

Like `Vector{T}` and `Matrix{T}` in `Base`, `IntVector{w,T}` and `IntMatrix{w,T}` are also defined as a type alias of `IntArray{w,T,n}`.

## Example

```julia
julia> using IntArrays

julia> ivec = IntVector{2}([0x00, 0x01, 0x03, 0x02])
4-element IntArrays.IntArray{2,UInt8,1}:
 0x00
 0x01
 0x03
 0x02

julia> ivec[2]
0x01

julia> ivec[2] = 0x03
0x03

julia> ivec[2]
0x03
```

## Benchmark

Micro benchmarks can be found in the [benchmark](./benchmark) directory.

The `getindex` and `setindex!` functions are 2-7 times slower than raw arrays due to the heavy bit operations.

![Benchmark of getindex on UInt8](./benchmark/getindex_UInt8.png?raw=true)
![Benchmark of setindex on UInt8](./benchmark/setindex_UInt8.png?raw=true)

---

```
julia> versioninfo()
Julia Version 0.4.0-dev+6632
Commit d5b880d* (2015-08-11 18:40 UTC)
Platform Info:
  System: Darwin (x86_64-apple-darwin14.4.0)
  CPU: Intel(R) Core(TM) i5-4288U CPU @ 2.60GHz
  WORD_SIZE: 64
  BLAS: libopenblas (USE64BITINT DYNAMIC_ARCH NO_AFFINITY Haswell)
  LAPACK: libopenblas
  LIBM: libopenlibm
  LLVM: libLLVM-3.3
```
