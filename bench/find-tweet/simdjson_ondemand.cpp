#include "simdjson.h"
#include "template.hpp"
#include "traced_allocator.hpp"

using namespace std;
using namespace simdjson;

const uint64_t find_id = 505874901689851904;
const string expected = "RT @shiawaseomamori: "
                        "一に止まると書いて、正しいという意味だなんて、この年に"
                        "なるまで知りませんでした。 "
                        "人は生きていると、前へ前へという気持ちばかり急いて、ど"
                        "んどん大切なものを置き去りにしていくものでしょう。本当"
                        "に正しいことというのは、一番初めの場所にあるの…";

struct simdjson_ondemand {

  string path;
  string_view result;
  ondemand::parser parser;

  void init(string_view _path) {
    path = string(_path);
  }

  void prerun() {}

  void run() {
    padded_string json;
    simdjson::error_code err;
    if (err = padded_string::load(path).get(json)) throw runtime_error("file not found");

    auto doc = parser.iterate(json);
    for (auto tweet : doc["statuses"]) {
      if (uint64_t(tweet["id"]) == find_id) {
        result = tweet["text"];
        return;
      }
    }
    throw runtime_error("tweet not found");
  }

  void postrun() {
    if (expected != result)
      throw runtime_error("tweet text unequal to expected");
  }

  void deinit() {}
};

BENCHMARK_TEMPLATE(simdjson_ondemand);
