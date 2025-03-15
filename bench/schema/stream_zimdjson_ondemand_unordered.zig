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
    lang: LanguageCode,
    // possibly_sensitive: ?bool, // see std_json.zig
    retweeted: bool,
    favorited: bool,
    entities: StatusEntities,
    favorite_count: u32,
    retweet_count: u32,
    // retweeted_status: ?*const Status, // see std_json.zig
    contributors: void,
    place: void,
    coordinates: void,
    geo: void,
    user: User,
    in_reply_to_screen_name: ?[]const u8,
    in_reply_to_user_id_str: ?[]const u8,
    in_reply_to_user_id: ?u32,
    in_reply_to_status_id_str: ?[]const u8,
    in_reply_to_status_id: ?u64,
    truncated: bool,
    source: []const u8,
    text: []const u8,
    id_str: []const u8,
    id: u64,
    created_at: []const u8,
    metadata: Metadata,
};

const Metadata = struct {
    iso_language_code: LanguageCode,
    result_type: ResultType,
};

const ResultType = enum { recent };
const LanguageCode = enum { @"zh-cn", cn, en, es, it, ja, zh };

const StatusEntities = struct {
    // media: ?[]const Media, // see std_json.zig
    user_mentions: ArrayList(UserMention),
    urls: ArrayList(Url),
    symbols: [0]void,
    hashtags: ArrayList(HashTag),
};

const HashTag = struct {
    indices: struct { u8, u8 },
    text: []const u8,
};

const Url = struct {
    indices: struct { u8, u8 },
    display_url: []const u8,
    expanded_url: []const u8,
    url: []const u8,
};

const UserMention = struct {
    indices: struct { u8, u8 },
    id_str: []const u8,
    id: u32,
    name: []const u8,
    screen_name: []const u8,
};

const Media = struct {
    source_status_id_str: ?[]const u8,
    source_status_id: ?u64,
    sizes: Sizes,
    type: []const u8,
    expanded_url: []const u8,
    display_url: []const u8,
    url: []const u8,
    media_url_https: []const u8,
    media_url: []const u8,
    id_str: []const u8,
    id: u64,
};

const Sizes = struct {
    large: Size,
    thumb: Size,
    small: Size,
    medium: Size,
};

const Size = struct {
    resize: []const u8,
    h: u16,
    w: u16,
};

const User = struct {
    notifications: bool,
    follow_request_sent: bool,
    following: bool,
    default_profile_image: bool,
    default_profile: bool,
    profile_use_background_image: bool,
    profile_text_color: []const u8,
    profile_sidebar_fill_color: []const u8,
    profile_sidebar_border_color: []const u8,
    profile_link_color: []const u8,
    // profile_banner_url: ?[]const u8, // see std_json.zig
    profile_image_url_https: []const u8,
    profile_image_url: []const u8,
    profile_background_tile: bool,
    profile_background_image_url_https: []const u8,
    profile_background_image_url: []const u8,
    profile_background_color: []const u8,
    is_translation_enabled: bool,
    is_translator: bool,
    contributors_enabled: bool,
    lang: LanguageCode,
    statuses_count: u32,
    verified: bool,
    geo_enabled: bool,
    time_zone: ?[]const u8,
    utc_offset: ?i32,
    favourites_count: u32,
    created_at: []const u8,
    listed_count: u32,
    friends_count: u32,
    followers_count: u32,
    protected: bool,
    entities: UserEntities,
    url: ?[]const u8,
    description: []const u8,
    location: []const u8,
    screen_name: []const u8,
    name: []const u8,
    id_str: []const u8,
    id: u32,
};

const UserEntities = struct {
    description: struct { urls: ArrayList(Url) },
    // url: ?struct { urls: []const Url }, // see std_json.zig
};

fn parseSchema(document: Parser.Document) !std.json.Parsed(Schema) {
    var dest: std.json.Parsed(Schema) = .{
        .arena = try allocator.create(std.heap.ArenaAllocator),
        .value = .{ .statuses = .empty },
    };
    errdefer allocator.destroy(dest.arena);
    dest.arena.* = .init(allocator);
    errdefer dest.arena.deinit();
    try parseSchemaInner(document, dest.arena.allocator(), &dest.value);
    return dest;
}

fn parseSchemaInner(document: Parser.Document, alloc: std.mem.Allocator, dest: *Schema) !void {
    var statuses = (try document.at("statuses").asArray()).iterator();
    while (try statuses.next()) |status| {
        try dest.statuses.append(alloc, try parseStatus(status, alloc));
    }
}

fn parseStatus(status: Parser.Value, alloc: std.mem.Allocator) !Status {
    return .{
        .lang = try parseLanguageCode(status.at("lang")),
        .retweeted = try status.at("retweeted").asBool(),
        .favorited = try status.at("favorited").asBool(),
        .entities = try parseStatusEntities(status.at("entities"), alloc),
        .favorite_count = @intCast(try status.at("favorite_count").asUnsigned()),
        .retweet_count = @intCast(try status.at("retweet_count").asUnsigned()),
        .contributors = try status.at("contributors").asLeaky(void, null, .{}),
        .place = try status.at("place").asLeaky(void, null, .{}),
        .coordinates = try status.at("coordinates").asLeaky(void, null, .{}),
        .geo = try status.at("geo").asLeaky(void, null, .{}),
        .user = try parseUser(status.at("user"), alloc),
        .in_reply_to_screen_name = try status.at("in_reply_to_screen_name").asLeaky(?[]const u8, null, .{}),
        .in_reply_to_user_id_str = try status.at("in_reply_to_user_id_str").asLeaky(?[]const u8, null, .{}),
        .in_reply_to_user_id = try status.at("in_reply_to_user_id").asLeaky(?u32, null, .{}),
        .in_reply_to_status_id_str = try status.at("in_reply_to_status_id_str").asLeaky(?[]const u8, null, .{}),
        .in_reply_to_status_id = try status.at("in_reply_to_status_id").asLeaky(?u64, null, .{}),
        .truncated = try status.at("truncated").asBool(),
        .source = try status.at("source").asString(),
        .text = try status.at("text").asString(),
        .id_str = try status.at("id_str").asString(),
        .id = try status.at("id").asUnsigned(),
        .created_at = try status.at("created_at").asString(),
        .metadata = try parseMetadata(status.at("metadata")),
    };
}

fn parseMetadata(metadata: Parser.Value) !Metadata {
    return .{
        .iso_language_code = try parseLanguageCode(metadata.at("iso_language_code")),
        .result_type = try parseResultType(metadata.at("result_type")),
    };
}

fn parseResultType(value: Parser.Value) !ResultType {
    const str = try value.asString();
    if (!std.mem.eql(u8, str, "recent")) return error.IncorrectType;
    return .recent;
}

fn parseLanguageCode(value: Parser.Value) !LanguageCode {
    const str = try value.asString();
    if (std.mem.eql(u8, str, "zh-cn")) return .@"zh-cn";
    if (std.mem.eql(u8, str, "cn")) return .cn;
    if (std.mem.eql(u8, str, "en")) return .en;
    if (std.mem.eql(u8, str, "es")) return .es;
    if (std.mem.eql(u8, str, "it")) return .it;
    if (std.mem.eql(u8, str, "ja")) return .ja;
    if (std.mem.eql(u8, str, "zh")) return .zh;
    return error.IncorrectType;
}

fn parseUser(value: Parser.Value, alloc: std.mem.Allocator) !User {
    return .{
        .notifications = try value.at("notifications").asBool(),
        .follow_request_sent = try value.at("follow_request_sent").asBool(),
        .following = try value.at("following").asBool(),
        .default_profile_image = try value.at("default_profile_image").asBool(),
        .default_profile = try value.at("default_profile").asBool(),
        .profile_use_background_image = try value.at("profile_use_background_image").asBool(),
        .profile_text_color = try value.at("profile_text_color").asString(),
        .profile_sidebar_fill_color = try value.at("profile_sidebar_fill_color").asString(),
        .profile_sidebar_border_color = try value.at("profile_sidebar_border_color").asString(),
        .profile_link_color = try value.at("profile_link_color").asString(),
        .profile_image_url_https = try value.at("profile_image_url_https").asString(),
        .profile_image_url = try value.at("profile_image_url").asString(),
        .profile_background_tile = try value.at("profile_background_tile").asBool(),
        .profile_background_image_url_https = try value.at("profile_background_image_url_https").asString(),
        .profile_background_image_url = try value.at("profile_background_image_url").asString(),
        .profile_background_color = try value.at("profile_background_color").asString(),
        .is_translation_enabled = try value.at("is_translation_enabled").asBool(),
        .is_translator = try value.at("is_translator").asBool(),
        .contributors_enabled = try value.at("contributors_enabled").asBool(),
        .lang = try parseLanguageCode(value.at("lang")),
        .statuses_count = @intCast(try value.at("statuses_count").asUnsigned()),
        .verified = try value.at("verified").asBool(),
        .geo_enabled = try value.at("geo_enabled").asBool(),
        .time_zone = try value.at("time_zone").asLeaky(?[]const u8, null, .{}),
        .utc_offset = try value.at("utc_offset").asLeaky(?i32, null, .{}),
        .favourites_count = @intCast(try value.at("favourites_count").asUnsigned()),
        .created_at = try value.at("created_at").asString(),
        .listed_count = @intCast(try value.at("listed_count").asUnsigned()),
        .friends_count = @intCast(try value.at("friends_count").asUnsigned()),
        .followers_count = @intCast(try value.at("followers_count").asUnsigned()),
        .protected = try value.at("protected").asBool(),
        .entities = try parseUserEntities(value.at("entities"), alloc),
        .url = try value.at("url").asLeaky(?[]const u8, null, .{}),
        .description = try value.at("description").asString(),
        .location = try value.at("location").asString(),
        .screen_name = try value.at("screen_name").asString(),
        .name = try value.at("name").asString(),
        .id_str = try value.at("id_str").asString(),
        .id = @intCast(try value.at("id").asUnsigned()),
    };
}

fn parseUserEntities(value: Parser.Value, alloc: std.mem.Allocator) !UserEntities {
    var arr = (try value.at("description").at("urls").asArray()).iterator();
    var arr_result: ArrayList(Url) = .empty;
    while (try arr.next()) |url| {
        try arr_result.append(alloc, try parseUrl(url));
    }
    return .{ .description = .{ .urls = arr_result } };
}

fn parseUrl(value: Parser.Value) !Url {
    return .{
        .indices = brk: {
            var indices: struct { u8, u8 } = undefined;
            var arr = (try value.at("indices").asArray()).iterator();
            indices[0] = @intCast(try (try arr.next() orelse return error.MissingField).asUnsigned());
            indices[1] = @intCast(try (try arr.next() orelse return error.MissingField).asUnsigned());
            break :brk indices;
        },
        .display_url = try value.at("display_url").asString(),
        .expanded_url = try value.at("expanded_url").asString(),
        .url = try value.at("url").asString(),
    };
}

fn parseStatusEntities(value: Parser.Value, alloc: std.mem.Allocator) !StatusEntities {
    var user_mentions_arr = (try value.at("user_mentions").asArray()).iterator();
    var user_mentions_result: ArrayList(UserMention) = .empty;
    while (try user_mentions_arr.next()) |user_mention| {
        try user_mentions_result.append(alloc, try parseUserMention(user_mention));
    }

    var urls_arr = (try value.at("urls").asArray()).iterator();
    var urls_result: ArrayList(Url) = .empty;
    while (try urls_arr.next()) |url| {
        try urls_result.append(alloc, try parseUrl(url));
    }

    const symbols_arr = try value.at("symbols").asArray();
    if (!try symbols_arr.isEmpty()) return error.IncorrectType;

    var hashtags_arr = (try value.at("hashtags").asArray()).iterator();
    var hashtags_result: ArrayList(HashTag) = .empty;
    while (try hashtags_arr.next()) |hashtag| {
        try hashtags_result.append(alloc, try parseHashTag(hashtag));
    }
    return .{
        .hashtags = hashtags_result,
        .symbols = .{},
        .urls = urls_result,
        .user_mentions = user_mentions_result,
    };
}

fn parseHashTag(value: Parser.Value) !HashTag {
    return .{
        .indices = brk: {
            var indices: struct { u8, u8 } = undefined;
            var arr = (try value.at("indices").asArray()).iterator();
            indices[0] = @intCast(try (try arr.next() orelse return error.MissingField).asUnsigned());
            indices[1] = @intCast(try (try arr.next() orelse return error.MissingField).asUnsigned());
            break :brk indices;
        },
        .text = try value.at("text").asString(),
    };
}

fn parseUserMention(value: Parser.Value) !UserMention {
    return .{
        .indices = brk: {
            var indices: struct { u8, u8 } = undefined;
            var arr = (try value.at("indices").asArray()).iterator();
            indices[0] = @intCast(try (try arr.next() orelse return error.MissingField).asUnsigned());
            indices[1] = @intCast(try (try arr.next() orelse return error.MissingField).asUnsigned());
            break :brk indices;
        },
        .id_str = try value.at("id_str").asString(),
        .id = @intCast(try value.at("id").asUnsigned()),
        .name = try value.at("name").asString(),
        .screen_name = try value.at("screen_name").asString(),
    };
}
