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
  dom::parser parser;
  vector<partial_tweet> result{};

  void init(string_view _path) {
    path = string(_path);
  }

  void prerun() {
    result.clear();
  }

  simdjson_inline uint64_t nullable_int(dom::element element) {
    if (element.is_null()) { return 0; }
    return element;
  }

  void run() {
    for (dom::element tweet : parser.load(path)["statuses"]) {
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
