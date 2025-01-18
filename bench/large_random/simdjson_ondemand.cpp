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
  ondemand::parser parser;
  vector<point> result{};

  void init(string_view _path) {
    path = string(_path);
  }

  void prerun() {
    result.clear();
  }

  void run() {
    padded_string json;
    simdjson::error_code err;
    if (err = padded_string::load(path).get(json)) throw runtime_error("file not found");

    auto doc = parser.iterate(json);
    for (ondemand::object coord : doc) {
      result.emplace_back(point{coord.find_field("x"), coord.find_field("y"), coord.find_field("z")});
    }
  }

  void postrun() {}

  void deinit() {}
};

BENCHMARK_TEMPLATE(simdjson_dom);
