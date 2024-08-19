#include "simdjson.h"
#include "traced_allocator.hpp"

using namespace simdjson;

const uint64_t find_id = 505874901689851904;
const string expected_two =
    "RT @shiawaseomamori: "
    "一に止まると書いて、正しいという意味だなんて、この年に"
    "なるまで知りませんでした。 "
    "人は生きていると、前へ前へという気持ちばかり急いて、ど"
    "んどん大切なものを置き去りにしていくものでしょう。本当"
    "に正しいことというのは、一番初めの場所にあるの…";

padded_string simdjson_ondemand__json;
ondemand::parser simdjson_ondemand__parser;
string_view simdjson_ondemand__result;

extern "C" void simdjson_ondemand__init(char *ptr, size_t len) {
  padded_string original_json;
  string_view path{ptr, len};
  auto err = padded_string::load(path).get(original_json);
  simdjson_ondemand__json =
      padded_string(original_json.data(), original_json.size());
}

extern "C" void simdjson_ondemand__prerun() {}

extern "C" void simdjson_ondemand__run() {
  auto doc =
      simdjson_ondemand__parser.iterate(simdjson_ondemand__json);
  for (auto tweet : doc["statuses"]) {
    if (uint64_t(tweet["id"]) == find_id) {
      simdjson_ondemand__result = tweet["text"];
      return;
    }
  }
  throw runtime_error("tweet not found");
}

extern "C" void simdjson_ondemand__postrun() {}

extern "C" void simdjson_ondemand__deinit() {
  if (expected_two != simdjson_ondemand__result)
    throw runtime_error("tweet text unequal to expected");
}

extern "C" size_t simdjson_ondemand__memusage() { return allocated_bytes(); }
