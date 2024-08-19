#include "simdjson.h"
#include "traced_allocator.hpp"

using namespace simdjson;

const uint64_t find_id = 505874901689851904;
const string expected = "RT @shiawaseomamori: "
                        "一に止まると書いて、正しいという意味だなんて、この年に"
                        "なるまで知りませんでした。 "
                        "人は生きていると、前へ前へという気持ちばかり急いて、ど"
                        "んどん大切なものを置き去りにしていくものでしょう。本当"
                        "に正しいことというのは、一番初めの場所にあるの…";

padded_string simdjson_dom__json;
dom::parser simdjson_dom__parser;
string_view simdjson_dom__result;

extern "C" void simdjson_dom__init(char *ptr, size_t len) {
  padded_string original_json;
  string_view path{ptr, len};
  auto err = padded_string::load(path).get(original_json);
  simdjson_dom__json =
      padded_string(original_json.data(), original_json.size());
}

extern "C" void simdjson_dom__prerun() {}

extern "C" void simdjson_dom__run() {
  auto doc = simdjson_dom__parser.parse(simdjson_dom__json);
  for (auto tweet : doc["statuses"]) {
    if (uint64_t(tweet["id"]) == find_id) {
      simdjson_dom__result = tweet["text"];
      return;
    }
  }
  throw runtime_error("tweet not found");
}

extern "C" void simdjson_dom__postrun() {}

extern "C" void simdjson_dom__deinit() {
  if (expected != simdjson_dom__result)
    throw runtime_error("tweet text unequal to expected");
}

extern "C" size_t simdjson_dom__memusage() { return allocated_bytes(); }
