#include "simdjson.h"

using namespace std;
using namespace simdjson;

padded_string *json;
ondemand::parser *parser;

extern "C" void simdjson__init() {
  padded_string original_json;
  auto err = padded_string::load("../simdjson-data/jsonexamples/twitter.json")
                 .get(original_json);
  json = new padded_string(original_json.data(), original_json.size());
  parser = new ondemand::parser();
}

extern "C" void simdjson__prerun() {}

extern "C" void simdjson__run() {
  ondemand::document document = parser->iterate(*json);
}

extern "C" void simdjson__postrun() {}

extern "C" void simdjson__deinit() {
  delete json;
  delete parser;
}
