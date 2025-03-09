pub const dom = @import("dom.zig");
pub const ondemand = @import("ondemand.zig");

const types = @import("types.zig");
pub const recommended_alignment = types.Aligned(true).alignment;
pub const recommended_padding = types.Vector.bytes_len;
