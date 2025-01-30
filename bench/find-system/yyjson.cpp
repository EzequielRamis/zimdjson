#include "simdjson.h"
#include "yyjson.h"
#include "template.hpp"
#include "traced_allocator.hpp"

using namespace std;
using namespace simdjson;

const uint64_t find_id = 168814437556;
const string expected = "16 Persei";

struct yyjson {

  string path;
  yyjson_doc *doc;
  string_view result;

  void init(string_view _path) {
    path = string(_path);
  }

  void prerun() {}

  void run() {
    doc = yyjson_read_file(path.data(), 0, NULL, NULL);
    if (!doc) { return; }
    yyjson_val *root = yyjson_doc_get_root(doc);
    if (!yyjson_is_arr(root)) { return; }

    // Walk the document, parsing the tweets as we go
    size_t system_idx, systems_max;
    yyjson_val *system;
    yyjson_arr_foreach(root, system_idx, systems_max, system) {
      if (!yyjson_is_obj(system)) { return; }
      auto id = yyjson_obj_get(system, "id64");
      if (!yyjson_is_uint(id)) { return; }
      if (yyjson_get_uint(id) == find_id) {
        auto name = yyjson_obj_get(system, "name");
        if (!yyjson_is_str(name)) { return; }
        result = { yyjson_get_str(name), yyjson_get_len(name) };
        return;
      }
    }
    throw runtime_error("system not found");
  }

  void postrun() {
    if (expected != result)
      throw runtime_error("system name unequal to expected");
    yyjson_doc_free(doc);
  }

  void deinit() {}
};

BENCHMARK_TEMPLATE(yyjson);
