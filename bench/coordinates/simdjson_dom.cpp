#include "simdjson.h"
#include "template.hpp"
#include "traced_allocator.hpp"

using namespace std;
using namespace simdjson;

struct point {
  double x;
  double y;
  double z;
};

struct simdjson_dom {

  string path;
  dom::parser parser;
  vector<point> result{};

  void init(string_view _path) {
    path = string(_path);
  }

  void prerun() {
    result.clear();
  }

  void run() {
    auto doc = parser.load(path);
    for (dom::object sys: doc) {
      auto coords = sys["coords"];
      result.emplace_back(point{coords["x"], coords["y"], coords["z"]});
    }
  }

  void postrun() {}

  void deinit() {}
};

BENCHMARK_TEMPLATE(simdjson_dom);
