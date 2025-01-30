#include "simdjson.h"
#include "template.hpp"
#include "traced_allocator.hpp"

using namespace std;
using namespace simdjson;

// result struct
struct top_tweet {
  string_view text;
  string_view screen_name;
  int64_t retweet_count;
};

const uint64_t max_retweet_count = 60;

// expected result
const top_tweet expected = {
  "RT @shiawaseomamori: 一に止まると書いて、正しいという意味だなんて、この年になるまで知りませんでした。 人は生きていると、前へ前へという気持ちばかり急いて、どんどん大切なものを置き去りにしていくものでしょう。本当に正しいことというのは、一番初めの場所にあるの…",
    "anime_toshiden1",
    58};

struct simdjson_dom {

  string path;
  dom::parser parser;
  top_tweet result;

  void init(string_view _path) {
    path = string(_path);
  }

  void prerun() {}

  void run() {
    result.retweet_count = -1;
    dom::element top_tweet{};

    auto doc = parser.load(path);
    for (auto tweet : doc["statuses"]) {
      int64_t retweet_count = tweet["retweet_count"];
      if (retweet_count <= max_retweet_count && retweet_count >= result.retweet_count) {
        result.retweet_count = retweet_count;
        top_tweet = tweet;
      }
    }

    result.text = top_tweet["text"];
    result.screen_name = top_tweet["user"]["screen_name"];
  }

  void postrun() {
    if (!(
            result.text == expected.text &&
            result.screen_name == expected.screen_name &&
            result.retweet_count == expected.retweet_count
          ))
      throw runtime_error("top tweet unequal to expected");
  }

  void deinit() {}
};

BENCHMARK_TEMPLATE(simdjson_dom);
