#include <stddef.h>
#include "simdjson.h"
#include "traced_allocator.hpp"

using namespace std;
using namespace simdjson;

padded_string *json;
ondemand::parser *parser;

extern "C" void simdjson__init(char *ptr, size_t len) {
  padded_string original_json;
  string_view path{ptr, len};
  auto err = padded_string::load(path).get(original_json);
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

extern "C" size_t simdjson__memusage() {
  return allocated_bytes();
}
