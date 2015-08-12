# IntArrays

[![Build Status](https://travis-ci.org/bicycle1885/IntArrays.jl.svg?branch=master)](https://travis-ci.org/bicycle1885/IntArrays.jl)

`IntArray` is an array of packed integers.

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
