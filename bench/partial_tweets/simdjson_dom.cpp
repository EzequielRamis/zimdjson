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

  padded_string json;
  dom::parser parser;
  vector<partial_tweet> result{};

  void init(string_view path) {
    simdjson::error_code err;
    if (err = padded_string::load(path).get(json)) throw runtime_error("file not found");
  }

  void prerun() {}

  simdjson_inline uint64_t nullable_int(dom::element element) {
    if (element.is_null()) { return 0; }
    return element;
  }

  void run() {
    for (dom::element tweet : parser.parse(json)["statuses"]) {
      auto user = tweet["user"];
      result.emplace_back(partial_tweet{
        tweet["created_at"],
        tweet["id"],
        tweet["text"],
        nullable_int(tweet["in_reply_to_status_id"]),
        { user["id"], user["screen_name"] },
        tweet["retweet_count"],
        tweet["favorite_count"]
      });
    }
  }

  void postrun() {}

  void deinit() {}
};

BENCHMARK_TEMPLATE(simdjson_dom);
