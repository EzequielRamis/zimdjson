# zimdjson
A Zig version of [simdjson](https://github.com/simdjson/simdjson), a JSON parser using SIMD instructions, based on the paper [Parsing Gigabytes of JSON per Second](https://arxiv.org/abs/1902.08318) by Geoff Langdale and Daniel Lemire.

At the current state, using the latest Zig version, it runs on average at about 90% to 95% of the speed of `simdjson`.

## Features
`zimdjson` covers the basic features `simdjson` provides like a DOM/OnDemand parser plus some that are, at the time being, unsolved:
- No 4GB document limit
- No padding requirement
- Reflection
