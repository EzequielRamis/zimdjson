//! Welcome to the documentation of zimdjson: a high-performance JSON parser that takes
//! advantage of SIMD vector instructions, based on the paper
//! [Parsing Gigabytes JSON per Second](https://arxiv.org/abs/1902.08318).
//!
//! The majority of the source code is based on the C++ implementation of
//! https://github.com/simdjson/simdjson with the addition of some fundamental features
//! like:
//! * Streaming support which can handle arbitrarily large documents.
//! * An ergonomic, [Serde](https://serde.rs)-like deserialization interface thanks to
//! compile-time reflection.
//! See [`ondemand.Parser.schema`](#zimdjson.ondemand.Parser.schema).
//! * More efficient memory usage.
//!
//! To get started, choose one of the following parsing approaches:
//! * `dom`: A simple and "user friendly" API in which an intermediate tree-like
//! structure is constructed for the whole document and can be traversed.
//! * `ondemand`: At the cost of incomplete validation, this API allows you to do
//! just-in-time parsing, without the need to store an entire document structure in
//! memory.
//!
//! For daily use, the `ondemand` approach is recommended, as it is more efficient and
//! has an API similar to `dom`.
//!
//! For more infomation, including code examples and benchmarks, check out
//! https://github.com/ezequielramis/zimdjson.

const std = @import("std");
const types = @import("types.zig");

pub const dom = @import("dom.zig");
pub const ondemand = @import("ondemand.zig");

/// Depending on the processor, aligned SIMD vector instructions may provide higher
/// performance (benchmarking is recommended). To enforce the use of these instructions,
/// the input must be properly aligned.
pub const alignment = types.Aligned(true).alignment;

/// The input does not need to be padded to be parsed, as it is handled automatically.
/// However, if you assume it has a sufficient padding, it must be at least this size.
pub const padding = std.simd.suggestVectorLength(u8) orelse @compileError("No SIMD features available");

test {
    std.testing.refAllDeclsRecursive(@This());
}
