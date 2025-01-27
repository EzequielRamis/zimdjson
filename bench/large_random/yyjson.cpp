#include "simdjson.h"
#include "yyjson.h"
#include "template.hpp"
#include "traced_allocator.hpp"

using namespace std;
using namespace simdjson;

struct point {
  double x;
  double y;
  double z;
};

struct yyjson {

  string path;
  yyjson_doc *doc;
  vector<point> result{};

  simdjson_inline double get_double(yyjson_val *obj, std::string_view key) {
    yyjson_val *val = yyjson_obj_getn(obj, key.data(), key.length());
    if (!val) { throw "missing point field!"; }
    if (yyjson_get_type(val) != YYJSON_TYPE_NUM) { throw "Number is not a type!"; }

    switch (yyjson_get_subtype(val)) {
      case YYJSON_SUBTYPE_UINT:
        return double(yyjson_get_uint(val));
      case YYJSON_SUBTYPE_SINT:
        return double(yyjson_get_sint(val));
      case YYJSON_SUBTYPE_REAL:
        return yyjson_get_real(val);
      default:
        SIMDJSON_UNREACHABLE();
    }
    SIMDJSON_UNREACHABLE();
    return 0.0; // unreachable
  }

  void init(string_view _path) {
    path = string(_path);
  }

  void prerun() {
      result.clear();
  }

  void run() {
    doc = yyjson_read_file(path.data(), 0, NULL, NULL);
    if (!doc) { return; }
    yyjson_val *systems = yyjson_doc_get_root(doc);
    if (!yyjson_is_arr(systems)) { return; }

    // Walk the document, parsing the tweets as we go
    size_t idx, max;
    yyjson_val *sys;
    yyjson_arr_foreach(systems, idx, max, sys) {
      if (!yyjson_is_obj(sys)) { return; }
      yyjson_val *coords = yyjson_obj_get(sys, "coords");
      if (!yyjson_is_obj(coords)) { return; }
      result.emplace_back(point{get_double(coords, "x"), get_double(coords, "y"), get_double(coords, "z")});
    }
  }

  void postrun() {
    yyjson_doc_free(doc);
  }

  void deinit() {}
};

BENCHMARK_TEMPLATE(yyjson);
