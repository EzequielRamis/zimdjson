#include "simdjson.h"

using namespace std;
using namespace simdjson;

ondemand::parser parser;
padded_string original_json{};
padded_string json{};

extern "C" void simdjson_ondemand__init() {
  auto err = padded_string::load("../simdjson-data/jsonexamples/twitter.json")
      .get(original_json);
  json = padded_string(original_json.data(), original_json.size());
}

extern "C" void simdjson_ondemand__prerun() {}

extern "C" void simdjson_ondemand__run() {
  ondemand::document document = parser.iterate(json);
  size_t i = rand() % 100;
  string_view created_at = document["statuses"].at(i)["source"];
}

extern "C" void simdjson_ondemand__postrun() {}

extern "C" void simdjson_ondemand__deinit() {}
