#include "simdjson.h"
#include "template.hpp"
#include "traced_allocator.hpp"

using namespace std;
using namespace simdjson;

struct simdjson_dom {

  string path;
  dom::parser parser;
  vector<uint64_t> result{};

  void init(string_view _path) {
    path = string(_path);
  }

  void prerun() {
    result.clear();
  }

  void run() {
    // Walk the document, parsing as we go
    auto doc = parser.load(path);
    for (dom::object tweet : doc["statuses"]) {
      // We believe that all statuses have a matching
      // user, and we are willing to throw when they do not.
      result.push_back(tweet["user"]["id"]);
      // Not all tweets have a "retweeted_status", but when they do
      // we want to go and find the user within.
      auto retweet = tweet["retweeted_status"];
      if (retweet.error() != NO_SUCH_FIELD) {
        result.push_back(retweet["user"]["id"]);
      }
    }
  }

  void postrun() {}

  void deinit() {}
};

BENCHMARK_TEMPLATE(simdjson_dom);
