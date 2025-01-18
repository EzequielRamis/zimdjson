#include "simdjson.h"
#include "template.hpp"
#include "traced_allocator.hpp"

using namespace std;
using namespace simdjson;

struct twitter_user {
  uint64_t id{};
  string_view screen_name{};
};

struct partial_tweet {
  string_view created_at{};
  uint64_t id{};
  string_view result{};
  uint64_t in_reply_to_status_id{};
  twitter_user user{};
  uint64_t retweet_count{};
  uint64_t favorite_count{};
};

struct simdjson_dom {

  string path;
  ondemand::parser parser;
  vector<partial_tweet> result{};

  void init(string_view _path) {
    path = string(_path);
  }

  void prerun() {
    result.clear();
  }

  simdjson_inline uint64_t nullable_int(ondemand::element element) {
    if (element.is_null()) { return 0; }
    return element;
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
    for (ondemand::object tweet : doc.find_field("statuses")) {
      result.emplace_back(partial_tweets::tweet<std::string_view>{
        tweet.find_field("created_at"),
        tweet.find_field("id"),
        tweet.find_field("text"),
        nullable_int(tweet.find_field("in_reply_to_status_id")),
        read_user(tweet.find_field("user")),
        tweet.find_field("retweet_count"),
        tweet.find_field("favorite_count")
      });
    }
  }

  void postrun() {}

  void deinit() {}
};

BENCHMARK_TEMPLATE(simdjson_dom);
