#include "simdjson.h"
#include "traced_allocator.hpp"

using namespace simdjson;

padded_string simdjson_ondemand__json;
ondemand::parser simdjson_ondemand__parser;

extern "C" void simdjson__init(char *ptr, size_t len) {
  padded_string original_json;
  string_view path{ptr, len};
  auto err = padded_string::load(path).get(original_json);
  simdjson_ondemand__json =
      padded_string(original_json.data(), original_json.size());
}

extern "C" void simdjson__prerun() {}

extern "C" void simdjson__run() {
  ondemand::document document =
      simdjson_ondemand__parser.iterate(simdjson_ondemand__json);
}

extern "C" void simdjson__postrun() {}

extern "C" void simdjson__deinit() {}

extern "C" size_t simdjson__memusage() { return allocated_bytes(); }
