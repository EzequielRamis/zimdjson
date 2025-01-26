#include "simdjson.h"
#include "template.hpp"
#include "traced_allocator.hpp"

using namespace std;
using namespace simdjson;

struct simdjson_ondemand {

  padded_string json;
  ondemand::parser parser;

  void init(string_view path) {
    simdjson::error_code err;
    if (err = padded_string::load(path).get(json)) throw runtime_error("file not found");
  }

  void prerun() {}

  void run() { auto doc = parser.iterate(json); }

  void postrun() {}

  void deinit() {}
};

BENCHMARK_TEMPLATE(simdjson_ondemand);
