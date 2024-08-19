#include "simdjson.h"
#include "template.hpp"
#include "traced_allocator.hpp"

using namespace std;
using namespace simdjson;

struct simdjson_ondemand {

  padded_string json;
  ondemand::parser parser;

  void init(string_view str) {
    padded_string original_json;
    auto err = padded_string::load(str).get(original_json);
    json = padded_string(original_json.data(), original_json.size());
  }

  void prerun() {}

  void run() { auto doc = parser.iterate(json); }

  void postrun() {}

  void deinit() {}
};

BENCHMARK_TEMPLATE(simdjson_ondemand);
