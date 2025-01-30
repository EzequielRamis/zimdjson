#include "simdjson.h"
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


struct simdjson_ondemand {

  string path;
  ondemand::parser parser;
  vector<tweet<std::string_view>> result{};

  void init(string_view _path) {
    path = string(_path);
  }

  void prerun() {
    result.clear();
  }

  simdjson_inline uint64_t nullable_int(ondemand::value value) {
    if (value.is_null()) { return 0; }
    return value;
  }

  simdjson_inline twitter_user<std::string_view> read_user(ondemand::object user) {
    return { user.find_field("id"), user.find_field("screen_name") };
  }

  void run() {
    padded_string json;
    simdjson::error_code err;
    if (err = padded_string::load(path).get(json)) throw runtime_error("file not found");

    // Walk the document, parsing the tweets as we go
    auto doc = parser.iterate(json);
    for (ondemand::object t: doc.find_field("statuses")) {
      result.emplace_back(tweet<std::string_view>{
        t.find_field("created_at"),
        t.find_field("id"),
        t.find_field("text"),
        nullable_int(t.find_field("in_reply_to_status_id")),
        read_user(t.find_field("user")),
        t.find_field("retweet_count"),
        t.find_field("favorite_count")
      });
    }
  }

  void postrun() {}

  void deinit() {}
};

BENCHMARK_TEMPLATE(simdjson_ondemand);
