# IntArrays

[![Build Status](https://travis-ci.org/bicycle1885/IntArrays.jl.svg?branch=master)](https://travis-ci.org/bicycle1885/IntArrays.jl)

IntArrays.jl is a package for packed integer arrays.
An array type, `IntArray`, is exported from this package and some methods in
`Base` are extended for it.

The `IntArray` type is defined as follows:

```julia
type IntArray{w,T<:Unsigned,n} <: AbstractArray{T,n}
```

where

* `w`: the bit width of integers (i.e. the number of bits to encode an integer)
* `T`: the type of integers
* `n`: the number of dimensions in the array.

This works like normal arrays, but each element is packed in a buffer as compact as possible.
That means the total memory footprint can be reduced if you specify small `w`
value: the total size is about `w * length(int_array)` bits.
You can think of it as a generalization of `BitArray` defined in the standard library:
`IntArray` can store any (unsigned) integers, whereas `BitArray` is restricted
to `Bool`.
It is your responsibility to keep values between `0` and `2^w-1`; otherwise
values will be truncated to `w` bits with no warning.

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

See [tutorial.ipynb](./tutorial.ipynb) for more details.

## Benchmark

Micro benchmarks can be found in the [benchmark](./benchmark) directory.

The `getindex` and `setindex!` methods of `IntArray` are 2-7 times slower than those of raw arrays due to the heavy bit operations.
Any pull request that fills the gap is welcome!

**UInt8**

![Benchmark of getindex on UInt8](./benchmark/getindex_UInt8.png?raw=true)
![Benchmark of setindex on UInt8](./benchmark/setindex_UInt8.png?raw=true)

**UInt64**

![Benchmark of getindex on UInt64](./benchmark/getindex_UInt64.png?raw=true)
![Benchmark of setindex on UInt64](./benchmark/setindex_UInt64.png?raw=true)

---

```
julia> versioninfo()
Julia Version 0.4.0-dev+6866
Commit e0b4510* (2015-08-20 22:06 UTC)
DEBUG build
Platform Info:
  System: Darwin (x86_64-apple-darwin14.4.0)
  CPU: Intel(R) Core(TM) i5-4288U CPU @ 2.60GHz
  WORD_SIZE: 64
  BLAS: libopenblas (USE64BITINT DYNAMIC_ARCH NO_AFFINITY Haswell)
  LAPACK: libopenblas
  LIBM: libopenlibm
  LLVM: libLLVM-3.3
```

## Plan

* Behave more like normal arrays
* Store signed integers
