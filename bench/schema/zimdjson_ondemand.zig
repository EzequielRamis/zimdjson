const std = @import("std");
const zimdjson = @import("zimdjson");
const TracedAllocator = @import("TracedAllocator");
const Parser = zimdjson.ondemand.parserFromSlice(.default);
const ArrayList = std.ArrayListUnmanaged;

var traced = TracedAllocator{ .wrapped = std.heap.c_allocator };
const allocator = traced.allocator();

var json: []u8 = undefined;
var doc: std.json.Parsed(Schema) = undefined;
var parser = Parser.init;

pub fn init(path: []const u8) !void {
    const file = try std.fs.openFileAbsolute(path, .{});
    defer file.close();
    json = try file.readToEndAlloc(allocator, std.math.maxInt(u32));
}

pub fn prerun() !void {}

pub fn run() !void {
    const document = try parser.parse(allocator, json);
    doc = try parseSchema(document);
}

pub fn postrun() !void {
    doc.deinit();
}

pub fn deinit() void {
    allocator.free(json);
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
    geo: void,
    coordinates: void,
    place: void,
    contributors: void,
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
    symbols: [0]void,
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
        .metadata = try parseMetadata(status.at("metadata")),
        .created_at = try status.at("created_at").asString().get(),
        .id = try status.at("id").asUnsigned(),
        .id_str = try status.at("id_str").asString().get(),
        .text = try status.at("text").asString().get(),
        .source = try status.at("source").asString().get(),
        .truncated = try status.at("truncated").asBool(),
        .in_reply_to_status_id = try status.at("in_reply_to_status_id").asLeaky(?u64, null, .{}),
        .in_reply_to_status_id_str = try status.at("in_reply_to_status_id_str").asLeaky(?[]const u8, null, .{}),
        .in_reply_to_user_id = try status.at("in_reply_to_user_id").asLeaky(?u32, null, .{}),
        .in_reply_to_user_id_str = try status.at("in_reply_to_user_id_str").asLeaky(?[]const u8, null, .{}),
        .in_reply_to_screen_name = try status.at("in_reply_to_screen_name").asLeaky(?[]const u8, null, .{}),
        .user = try parseUser(status.at("user"), alloc),
        .geo = try status.at("geo").asLeaky(void, null, .{}),
        .coordinates = try status.at("coordinates").asLeaky(void, null, .{}),
        .place = try status.at("place").asLeaky(void, null, .{}),
        .contributors = try status.at("contributors").asLeaky(void, null, .{}),
        .retweet_count = @intCast(try status.at("retweet_count").asUnsigned()),
        .favorite_count = @intCast(try status.at("favorite_count").asUnsigned()),
        .entities = try parseStatusEntities(status.at("entities"), alloc),
        .favorited = try status.at("favorited").asBool(),
        .retweeted = try status.at("retweeted").asBool(),
        .lang = try parseLanguageCode(status.at("lang")),
    };
}

fn parseMetadata(metadata: Parser.Value) !Metadata {
    return .{
        .result_type = try parseResultType(metadata.at("result_type")),
        .iso_language_code = try parseLanguageCode(metadata.at("iso_language_code")),
    };
}

fn parseResultType(value: Parser.Value) !ResultType {
    const str = try value.asString().get();
    if (!std.mem.eql(u8, str, "recent")) return error.IncorrectType;
    return .recent;
}

fn parseLanguageCode(value: Parser.Value) !LanguageCode {
    const str = try value.asString().get();
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
        .id = @intCast(try value.at("id").asUnsigned()),
        .id_str = try value.at("id_str").asString().get(),
        .name = try value.at("name").asString().get(),
        .screen_name = try value.at("screen_name").asString().get(),
        .location = try value.at("location").asString().get(),
        .description = try value.at("description").asString().get(),
        .url = try value.at("url").asLeaky(?[]const u8, null, .{}),
        .entities = try parseUserEntities(value.at("entities"), alloc),
        .protected = try value.at("protected").asBool(),
        .followers_count = @intCast(try value.at("followers_count").asUnsigned()),
        .friends_count = @intCast(try value.at("friends_count").asUnsigned()),
        .listed_count = @intCast(try value.at("listed_count").asUnsigned()),
        .created_at = try value.at("created_at").asString().get(),
        .favourites_count = @intCast(try value.at("favourites_count").asUnsigned()),
        .utc_offset = try value.at("utc_offset").asLeaky(?i32, null, .{}),
        .time_zone = try value.at("time_zone").asLeaky(?[]const u8, null, .{}),
        .geo_enabled = try value.at("geo_enabled").asBool(),
        .verified = try value.at("verified").asBool(),
        .statuses_count = @intCast(try value.at("statuses_count").asUnsigned()),
        .lang = try parseLanguageCode(value.at("lang")),
        .contributors_enabled = try value.at("contributors_enabled").asBool(),
        .is_translator = try value.at("is_translator").asBool(),
        .is_translation_enabled = try value.at("is_translation_enabled").asBool(),
        .profile_background_color = try value.at("profile_background_color").asString().get(),
        .profile_background_image_url = try value.at("profile_background_image_url").asString().get(),
        .profile_background_image_url_https = try value.at("profile_background_image_url_https").asString().get(),
        .profile_background_tile = try value.at("profile_background_tile").asBool(),
        .profile_image_url = try value.at("profile_image_url").asString().get(),
        .profile_image_url_https = try value.at("profile_image_url_https").asString().get(),
        .profile_link_color = try value.at("profile_link_color").asString().get(),
        .profile_sidebar_border_color = try value.at("profile_sidebar_border_color").asString().get(),
        .profile_sidebar_fill_color = try value.at("profile_sidebar_fill_color").asString().get(),
        .profile_text_color = try value.at("profile_text_color").asString().get(),
        .profile_use_background_image = try value.at("profile_use_background_image").asBool(),
        .default_profile = try value.at("default_profile").asBool(),
        .default_profile_image = try value.at("default_profile_image").asBool(),
        .following = try value.at("following").asBool(),
        .follow_request_sent = try value.at("follow_request_sent").asBool(),
        .notifications = try value.at("notifications").asBool(),
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
        .url = try value.at("url").asString().get(),
        .expanded_url = try value.at("expanded_url").asString().get(),
        .display_url = try value.at("display_url").asString().get(),
        .indices = brk: {
            var indices: struct { u8, u8 } = undefined;
            var arr = (try value.at("indices").asArray()).iterator();
            indices[0] = @intCast(try (try arr.next() orelse return error.MissingField).asUnsigned());
            indices[1] = @intCast(try (try arr.next() orelse return error.MissingField).asUnsigned());
            break :brk indices;
        },
    };
}

fn parseStatusEntities(value: Parser.Value, alloc: std.mem.Allocator) !StatusEntities {
    var hashtags_arr = (try value.at("hashtags").asArray()).iterator();
    var hashtags_result: ArrayList(HashTag) = .empty;
    while (try hashtags_arr.next()) |hashtag| {
        try hashtags_result.append(alloc, try parseHashTag(hashtag));
    }
    const symbols_arr = try value.at("symbols").asArray();
    if (!try symbols_arr.isEmpty()) return error.IncorrectType;
    var urls_arr = (try value.at("urls").asArray()).iterator();
    var urls_result: ArrayList(Url) = .empty;
    while (try urls_arr.next()) |url| {
        try urls_result.append(alloc, try parseUrl(url));
    }
    var user_mentions_arr = (try value.at("user_mentions").asArray()).iterator();
    var user_mentions_result: ArrayList(UserMention) = .empty;
    while (try user_mentions_arr.next()) |user_mention| {
        try user_mentions_result.append(alloc, try parseUserMention(user_mention));
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
        .text = try value.at("text").asString().get(),
        .indices = brk: {
            var indices: struct { u8, u8 } = undefined;
            var arr = (try value.at("indices").asArray()).iterator();
            indices[0] = @intCast(try (try arr.next() orelse return error.MissingField).asUnsigned());
            indices[1] = @intCast(try (try arr.next() orelse return error.MissingField).asUnsigned());
            break :brk indices;
        },
    };
}

fn parseUserMention(value: Parser.Value) !UserMention {
    return .{
        .screen_name = try value.at("screen_name").asString().get(),
        .name = try value.at("name").asString().get(),
        .id = @intCast(try value.at("id").asUnsigned()),
        .id_str = try value.at("id_str").asString().get(),
        .indices = brk: {
            var indices: struct { u8, u8 } = undefined;
            var arr = (try value.at("indices").asArray()).iterator();
            indices[0] = @intCast(try (try arr.next() orelse return error.MissingField).asUnsigned());
            indices[1] = @intCast(try (try arr.next() orelse return error.MissingField).asUnsigned());
            break :brk indices;
        },
    };
}
