#include "simdjson.h"
#include "yyjson.h"
#include "template.hpp"
#include "traced_allocator.hpp"

using namespace std;
using namespace simdjson;

template<typename StringType=std::string_view>
struct twitter_user {
  uint64_t id{};
  StringType screen_name{};

  template<typename OtherStringType>
  bool operator==(const twitter_user<OtherStringType> &other) const {
    return id == other.id &&
           screen_name == other.screen_name;
  }
};

template<typename StringType=std::string_view>
struct tweet {
  StringType created_at{};
  uint64_t id{};
  StringType result{};
  uint64_t in_reply_to_status_id{};
  twitter_user<StringType> user{};
  uint64_t retweet_count{};
  uint64_t favorite_count{};
  template<typename OtherStringType>
  simdjson_inline bool operator==(const tweet<OtherStringType> &other) const {
    return created_at == other.created_at &&
           id == other.id &&
           result == other.result &&
           in_reply_to_status_id == other.in_reply_to_status_id &&
           user == other.user &&
           retweet_count == other.retweet_count &&
           favorite_count == other.favorite_count;
  }
  template<typename OtherStringType>
  simdjson_inline bool operator!=(const tweet<OtherStringType> &other) const { return !(*this == other); }
};

struct yyjson {

  string path;
  yyjson_doc *doc;
  vector<tweet<std::string_view>> result{};

  void init(string_view _path) {
    path = string(_path);
  }

  void prerun() {
      result.clear();
  }

  simdjson_inline std::string_view get_string_view(yyjson_val *obj, std::string_view key) {
    auto val = yyjson_obj_getn(obj, key.data(), key.length());
    if (!yyjson_is_str(val)) { throw "field is not uint64 or null!"; }
    return { yyjson_get_str(val), yyjson_get_len(val) };
  }
  simdjson_inline uint64_t get_uint64(yyjson_val *obj, std::string_view key) {
    auto val = yyjson_obj_getn(obj, key.data(), key.length());
    if (!yyjson_is_uint(val)) { throw "field is not uint64 or null!"; }
    return yyjson_get_uint(val);
  }
  simdjson_inline uint64_t get_nullable_uint64(yyjson_val *obj, std::string_view key) {
    auto val = yyjson_obj_getn(obj, key.data(), key.length());
    if (!yyjson_is_uint(val)) { }
    auto type = yyjson_get_type(val);
    if (type != YYJSON_TYPE_NUM && type != YYJSON_TYPE_NULL ) { throw "field is not uint64 or null!"; }
    return yyjson_get_uint(val);
  }
  simdjson_inline twitter_user<std::string_view> get_user(yyjson_val *obj, std::string_view key) {
    auto user = yyjson_obj_getn(obj, key.data(), key.length());
    if (!yyjson_is_obj(user)) { throw "missing twitter user field!"; }
    return { get_uint64(user, "id"), get_string_view(user, "screen_name") };
  }

  void run() {
    doc = yyjson_read_file(path.data(), 0, NULL, NULL);
    if (!doc) { return; }
    yyjson_val *root = yyjson_doc_get_root(doc);
    if (!yyjson_is_obj(root)) { return; }
    yyjson_val *statuses = yyjson_obj_get(root, "statuses");
    if (!yyjson_is_arr(statuses)) { return; }

    // Walk the document, parsing the tweets as we go
    size_t tweet_idx, tweets_max;
    yyjson_val *t;
    yyjson_arr_foreach(statuses, tweet_idx, tweets_max, t) {
      if (!yyjson_is_obj(t)) { return; }
      // TODO these can't actually handle errors
      result.emplace_back(tweet<std::string_view>{
        get_string_view(t, "created_at"),
        get_uint64     (t, "id"),
        get_string_view(t, "text"),
        get_nullable_uint64     (t, "in_reply_to_status_id"),
        get_user       (t, "user"),
        get_uint64     (t, "retweet_count"),
        get_uint64     (t, "favorite_count")
      });
    }
  }

  void postrun() {
    yyjson_doc_free(doc);
  }

  void deinit() {}
};

BENCHMARK_TEMPLATE(yyjson);
