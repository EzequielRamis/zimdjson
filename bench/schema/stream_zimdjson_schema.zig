const std = @import("std");
const zimdjson = @import("zimdjson");
const TracedAllocator = @import("TracedAllocator");
const Parser = zimdjson.ondemand.StreamParser(.default);
const ArrayList = std.ArrayListUnmanaged;

var traced = TracedAllocator{ .wrapped = std.heap.c_allocator };
const allocator = traced.allocator();

var file: std.fs.File = undefined;
var json: []const u8 = undefined;
var doc: std.json.Parsed(Schema) = undefined;
var parser = Parser.init;

pub fn init(path: []const u8) !void {
    json = path;
}

pub fn prerun() !void {}

pub fn run() !void {
    file = try std.fs.openFileAbsolute(json, .{});
    try parser.expectDocumentSize(allocator, (try file.stat()).size);
    const document = try parser.parseFromReader(allocator, file.reader().any());
    doc = try document.as(Schema, allocator, .{});
}

pub fn postrun() !void {
    file.close();
    doc.deinit();
}

pub fn deinit() void {
    parser.deinit(allocator);
}

pub fn memusage() usize {
    return traced.total;
}

const Schema = struct {
    statuses: ArrayList(Status),
};

const Status = struct {
    metadata: Metadata,
    created_at: []const u8,
    id: u64,
    id_str: []const u8,
    text: []const u8,
    source: []const u8,
    truncated: bool,
    in_reply_to_status_id: ?u64,
    in_reply_to_status_id_str: ?[]const u8,
    in_reply_to_user_id: ?u32,
    in_reply_to_user_id_str: ?[]const u8,
    in_reply_to_screen_name: ?[]const u8,
    user: User,
    geo: ?struct {},
    coordinates: ?struct {},
    place: ?struct {},
    contributors: ?struct {},
    // retweeted_status: ?*const Status, // see std_json.zig
    retweet_count: u32,
    favorite_count: u32,
    entities: StatusEntities,
    favorited: bool,
    retweeted: bool,
    // possibly_sensitive: ?bool, // see std_json.zig
    lang: LanguageCode,
};

const Metadata = struct {
    result_type: ResultType,
    iso_language_code: LanguageCode,
};

const ResultType = enum { recent };
const LanguageCode = enum { @"zh-cn", cn, en, es, it, ja, zh };

const StatusEntities = struct {
    hashtags: ArrayList(HashTag),
    // symbols: [0]?struct {}, // see std_json.zig
    urls: ArrayList(Url),
    user_mentions: ArrayList(UserMention),
    // media: ?[]const Media, // see std_json.zig
};

const HashTag = struct {
    text: []const u8,
    indices: struct { u8, u8 },
};

const Url = struct {
    url: []const u8,
    expanded_url: []const u8,
    display_url: []const u8,
    indices: struct { u8, u8 },
};

const UserMention = struct {
    screen_name: []const u8,
    name: []const u8,
    id: u32,
    id_str: []const u8,
    indices: struct { u8, u8 },
};

const Media = struct {
    id: u64,
    id_str: []const u8,
    media_url: []const u8,
    media_url_https: []const u8,
    url: []const u8,
    display_url: []const u8,
    expanded_url: []const u8,
    type: []const u8,
    sizes: Sizes,
    source_status_id: ?u64,
    source_status_id_str: ?[]const u8,
};

const Sizes = struct {
    medium: Size,
    small: Size,
    thumb: Size,
    large: Size,
};

const Size = struct {
    w: u16,
    h: u16,
    resize: []const u8,
};

const User = struct {
    id: u32,
    id_str: []const u8,
    name: []const u8,
    screen_name: []const u8,
    location: []const u8,
    description: []const u8,
    url: ?[]const u8,
    entities: UserEntities,
    protected: bool,
    followers_count: u32,
    friends_count: u32,
    listed_count: u32,
    created_at: []const u8,
    favourites_count: u32,
    utc_offset: ?i32,
    time_zone: ?[]const u8,
    geo_enabled: bool,
    verified: bool,
    statuses_count: u32,
    lang: LanguageCode,
    contributors_enabled: bool,
    is_translator: bool,
    is_translation_enabled: bool,
    profile_background_color: []const u8,
    profile_background_image_url: []const u8,
    profile_background_image_url_https: []const u8,
    profile_background_tile: bool,
    profile_image_url: []const u8,
    profile_image_url_https: []const u8,
    // profile_banner_url: ?[]const u8, // see std_json.zig
    profile_link_color: []const u8,
    profile_sidebar_border_color: []const u8,
    profile_sidebar_fill_color: []const u8,
    profile_text_color: []const u8,
    profile_use_background_image: bool,
    default_profile: bool,
    default_profile_image: bool,
    following: bool,
    follow_request_sent: bool,
    notifications: bool,
};

const UserEntities = struct {
    // url: ?struct { urls: []const Url }, // see std_json.zig
    description: struct { urls: ArrayList(Url) },
};
