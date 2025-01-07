#include "simdjson.h"
#include "template.hpp"
#include "traced_allocator.hpp"

using namespace std;
using namespace simdjson;

struct simdjson_dom {

  string path;
  dom::parser parser;

  void init(string_view _path) {
    path = string(_path);
  }

  void prerun() {}

  void run() { auto doc = parser.load(path); }

  void postrun() {}

  void deinit() {}
};

BENCHMARK_TEMPLATE(simdjson_dom);
