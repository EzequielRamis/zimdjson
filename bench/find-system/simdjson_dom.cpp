#include "simdjson.h"
#include "template.hpp"
#include "traced_allocator.hpp"

using namespace std;
using namespace simdjson;

const uint64_t find_id = 168814437556;
const string expected = "16 Persei";

struct simdjson_dom {

  string path;
  dom::parser parser;
  string_view result;

  void init(string_view _path) {
    path = string(_path);
  }

  void prerun() {}

  void run() {
    auto doc = parser.load(path);
    for (auto system : doc) {
      if (uint64_t(system["id64"]) == find_id) {
        result = system["name"];
        return;
      }
    }
    throw runtime_error("system not found");
  }

  void postrun() {
    if (expected != result)
      throw runtime_error("system name unequal to expected");
  }

  void deinit() {}
};

BENCHMARK_TEMPLATE(simdjson_dom);
