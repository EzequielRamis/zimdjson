#include "simdjson.h"
#include "template.hpp"
#include "traced_allocator.hpp"

using namespace std;
using namespace simdjson;

struct simdjson_dom {

  string path;
  ondemand::parser parser;
  vector<uint64_t> result{};

  void init(string_view _path) {
    path = string(_path);
  }

  void prerun() {
    result.clear();
  }

  void run() {
    padded_string json;
    simdjson::error_code err;
    if (err = padded_string::load(path).get(json)) throw runtime_error("file not found");

    // Walk the document, parsing as we go
    auto doc = parser.iterate(json);
    for (ondemand::object tweet : doc.find_field("statuses")) {
      // We believe that all statuses have a matching
      // user, and we are willing to throw when they do not.
      result.push_back(tweet.find_field("user").find_field("id"));
      // Not all tweets have a "retweeted_status", but when they do
      // we want to go and find the user within.
      auto retweet = tweet.find_field("retweeted_status");
      if (!retweet.error()) {
        result.push_back(retweet.find_field("user").find_field("id"));
      }
    }
  }

  void postrun() {}

  void deinit() {}
};

BENCHMARK_TEMPLATE(simdjson_dom);
