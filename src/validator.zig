const atoms = @import("validator/atoms.zig");
pub const true_atom = atoms.true_atom;
pub const false_atom = atoms.false_atom;
pub const null_atom = atoms.null_atom;
pub const number = @import("validator/number.zig").number;
pub const string = @import("validator/string.zig").string;
pub const rawString = @import("validator/string.zig").rawString;
