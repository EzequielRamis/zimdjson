const atoms = @import("parsers/atoms.zig");

pub const checkTrue = atoms.checkTrue;
pub const checkFalse = atoms.checkFalse;
pub const checkNull = atoms.checkNull;
pub const writeString = @import("parsers/string.zig").writeString;
pub const Number = @import("parsers/number/parser.zig").Parser;
