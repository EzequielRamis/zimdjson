use core::slice;

use libc::{c_char, size_t};
use serde::Deserialize;

#[allow(dead_code)]
#[derive(Debug, Deserialize)]
#[serde(rename_all = "lowercase")]
enum ResultType {
    Recent,
}

#[allow(dead_code)]
#[derive(Debug, Deserialize)]
#[serde(rename_all = "lowercase")]
enum LanguageCode {
    #[serde(rename = "zh-cn")]
    Cn,
    En,
    Es,
    It,
    Ja,
    Zh,
}

#[allow(dead_code)]
#[derive(Debug, Deserialize)]
struct Metadata {
    result_type: ResultType,
    iso_language_code: LanguageCode,
}

#[allow(dead_code)]
#[derive(Debug, Deserialize)]
struct Url {
    url: String,
    expanded_url: String,
    display_url: String,
    indices: (u8, u8),
}

#[allow(dead_code)]
#[derive(Debug, Deserialize)]
struct UserEntitiesUrl {
    urls: Vec<Url>,
}

#[allow(dead_code)]
#[derive(Debug, Deserialize)]
struct UserEntitiesDescription {
    urls: Vec<Url>,
}

#[allow(dead_code)]
#[derive(Debug, Deserialize)]
struct UserEntities {
    // url: Option<UserEntitiesUrl>, // see std_json.zig
    description: UserEntitiesDescription,
}

#[allow(dead_code)]
#[derive(Debug, Deserialize)]
struct User {
    id: u32,
    id_str: String,
    name: String,
    screen_name: String,
    location: String,
    description: String,
    url: Option<String>,
    entities: UserEntities,
    protected: bool,
    followers_count: u32,
    friends_count: u32,
    listed_count: u32,
    created_at: String,
    favourites_count: u32,
    utc_offset: Option<i32>,
    time_zone: Option<String>,
    geo_enabled: bool,
    verified: bool,
    statuses_count: u32,
    lang: LanguageCode,
    contributors_enabled: bool,
    is_translator: bool,
    is_translation_enabled: bool,
    profile_background_color: String,
    profile_background_image_url: String,
    profile_background_image_url_https: String,
    profile_background_tile: bool,
    profile_image_url: String,
    profile_image_url_https: String,
    // profile_banner_url: Option<String>, // see std_json.zig
    profile_link_color: String,
    profile_sidebar_border_color: String,
    profile_sidebar_fill_color: String,
    profile_text_color: String,
    profile_use_background_image: bool,
    default_profile: bool,
    default_profile_image: bool,
    following: bool,
    follow_request_sent: bool,
    notifications: bool,
}

#[allow(dead_code)]
#[derive(Debug, Deserialize)]
struct HashTag {
    text: String,
    indices: (u8, u8),
}

#[allow(dead_code)]
#[derive(Debug, Deserialize)]
struct UserMention {
    screen_name: String,
    name: String,
    id: u32,
    id_str: String,
    indices: (u8, u8),
}

#[allow(dead_code)]
#[derive(Debug, Deserialize)]
#[serde(rename_all = "lowercase")]
enum Resize {
    Fit,
    Crop,
}

#[allow(dead_code)]
#[derive(Debug, Deserialize)]
struct Size {
    w: u16,
    h: u16,
    resize: String,
}

#[allow(dead_code)]
#[derive(Debug, Deserialize)]
struct Sizes {
    medium: Size,
    small: Size,
    thumb: Size,
    large: Size,
}

#[allow(dead_code)]
#[derive(Debug, Deserialize)]
struct Media {
    id: u64,
    id_str: String,
    media_url: String,
    media_url_https: String,
    url: String,
    display_url: String,
    expanded_url: String,
    #[serde(rename = "type")]
    media_type: String,
    sizes: Sizes,
    source_status_id: Option<u64>,
    source_status_id_str: Option<String>,
}

#[allow(dead_code)]
#[derive(Debug, Deserialize)]
struct StatusEntities {
    hashtags: Vec<HashTag>,
    symbols: Vec<()>,
    urls: Vec<Url>,
    user_mentions: Vec<UserMention>,
    // media: Option<Vec<Media>>, // see std_json.zig
}

#[allow(dead_code)]
#[derive(Debug, Deserialize)]
struct Status {
    metadata: Metadata,
    created_at: String,
    id: u64,
    id_str: String,
    text: String,
    source: String,
    truncated: bool,
    in_reply_to_status_id: Option<u64>,
    in_reply_to_status_id_str: Option<String>,
    in_reply_to_user_id: Option<u32>,
    in_reply_to_user_id_str: Option<String>,
    in_reply_to_screen_name: Option<String>,
    user: User,
    geo: (),
    coordinates: (),
    place: (),
    contributors: (),
    // retweeted_status: Option<Box<Status>>, // see std_json.zig
    retweet_count: u32,
    favorite_count: u32,
    entities: StatusEntities,
    favorited: bool,
    retweeted: bool,
    // possibly_sensitive: Option<bool>, // see std_json.zig
    lang: LanguageCode,
}

#[allow(dead_code)]
#[derive(Debug, Deserialize)]
struct Schema {
    statuses: Vec<Status>,
}

struct Global {
    json: Option<String>,
    doc: Option<Schema>,
}

static mut GLOBAL: Global = Global {
    json: None,
    doc: None,
};

#[no_mangle]
pub unsafe extern "C" fn serde__init(ptr: *const c_char, len: size_t) {
    let path = std::str::from_utf8_unchecked(slice::from_raw_parts(ptr as *const u8, len));
    let buffer = std::fs::read_to_string(path).unwrap();
    GLOBAL.json = Some(buffer);
}

#[no_mangle]
pub unsafe extern "C" fn serde__prerun() {}

#[allow(static_mut_refs)]
#[no_mangle]
pub unsafe extern "C" fn serde__run() {
    let content = GLOBAL.json.as_ref().unwrap();
    GLOBAL.doc = Some(serde_json::from_str(content.as_str()).unwrap());
}

#[no_mangle]
pub unsafe extern "C" fn serde__postrun() {}

#[no_mangle]
pub unsafe extern "C" fn serde__deinit() {
    GLOBAL.json = None;
    GLOBAL.doc = None;
}

#[no_mangle]
pub unsafe extern "C" fn serde__memusage() -> size_t {
    0
}
