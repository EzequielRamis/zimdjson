# zimdjson

A Zig version of [simdjson](https://github.com/simdjson/simdjson), a JSON parser using SIMD instructions, based on the paper [Parsing Gigabytes of JSON per Second](https://arxiv.org/abs/1902.08318) by Geoff Langdale and Daniel Lemire.

## Features

`zimdjson` covers the basic features `simdjson` provides like a DOM/OnDemand parser plus some that are, at the time being, unsolved:

- [No padding requirement.](https://github.com/simdjson/simdjson/issues/174)
- [No 4GB document limit on streaming.](https://github.com/simdjson/simdjson/issues/670)

```mermaid
  flowchart TD;
      parse[Choosing a JSON parsing strategy]
      input{What is the input type?}
      size{Is it size known?}
      valid1{Do you want a fully validated tree?}
      valid2{Do you want a fully validated tree?}
      big1{Is the document too big?}
      big2{Is the document too big?}
      dom1([DOM])
      dom2([DOM])
      ondemand1([OnDemand])
      ondemand2([OnDemand])
      stream_dom([Streaming DOM])
      stream_ondemand([Streaming OnDemand])
      error([None is suitable])
      
      parse --> input
      input -- String --> big1
      size -- Yes --> big2
      input -- File / Stream --> size
      size -- No --> stream_ondemand
      big1 -- Yes --> error
      big1 -- No --> valid1
      big2 -- No ---> valid2
      big2 ~~~ comment@{ shape: brace-l, label: "At this stage there is no clear answer so benchmarking should be considered" }
      big2 -- Yes --> stream_ondemand
      valid1 -- Yes --> dom1
      valid1 -- No --> ondemand1
      valid2 -- Yes --> dom2
      valid2 -- Yes --> stream_dom
      valid2 -- No --> ondemand2
      valid2 -- No --> stream_ondemand
```

## Future work

- Reflection (Zig provides compile-time reflection but I will wait until there is a decision about this [proposal](https://github.com/ziglang/zig/issues/1099) to prevent wasted work).
- Runtime CPU Detection (this [proposal](https://github.com/ziglang/zig/issues/1018) must be resolved first).
- Multithreading on streaming.
