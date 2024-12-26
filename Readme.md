# zimdjson
A Zig version of [simdjson](https://github.com/simdjson/simdjson), a JSON parser using SIMD instructions, based on the paper [Parsing Gigabytes of JSON per Second](https://arxiv.org/abs/1902.08318) by Geoff Langdale and Daniel Lemire.

## Features
`zimdjson` covers the basic features `simdjson` provides like a DOM/OnDemand parser plus some that are, at the time being, unsolved:
- [No 4GB document limit](https://github.com/simdjson/simdjson/issues/670)
- [No padding requirement](https://github.com/simdjson/simdjson/issues/174)

## Future work
- Reflection (Zig provides compile-time reflection but I will wait until this [proposal](https://github.com/ziglang/zig/issues/1099) is resolved so I can choose a reasonable interface)
- Runtime detection (this [proposal](https://github.com/ziglang/zig/issues/1018) must be resolved first)
