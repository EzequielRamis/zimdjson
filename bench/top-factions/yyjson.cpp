#include "simdjson.h"
#include "yyjson.h"
#include "template.hpp"
#include "traced_allocator.hpp"

using namespace std;
using namespace simdjson;

// result struct
struct top_factions {
  uint64_t id;
  string_view name;
  size_t factions_count;
};

// expected result
const top_factions expected = {
    4207021134570,
    "Tigurd",
    33};

struct yyjson {

  string path;
  yyjson_doc *doc;
  top_factions result;

  void init(string_view _path) {
    path = string(_path);
  }

  void prerun() {}

  void run() {
    result.factions_count = 0;

    yyjson_val *top_factions{};

    doc = yyjson_read_file(path.data(), 0, NULL, NULL);
    if (!doc) { return; }
    yyjson_val *root = yyjson_doc_get_root(doc);
    if (!yyjson_is_arr(root)) { return; }

    // Walk the document, parsing the tweets as we go
    yyjson_val *system;
    yyjson_arr_iter iter = yyjson_arr_iter_with(root);
    while ((system = yyjson_arr_iter_next(&iter))) {
      if (!yyjson_is_obj(system)) { return; }

      auto factions_val = yyjson_obj_get(system, "factions");
      if (factions_val == NULL) continue;
      if (!yyjson_is_arr(factions_val)) { return; }
      size_t factions_count = yyjson_arr_size(factions_val);
      if (factions_count >= result.factions_count) {
        result.factions_count = factions_count;
        top_factions = system;
      }
    }

    auto id = yyjson_obj_get(top_factions, "id64");
    if (!yyjson_is_uint(id)) { return; }
    result.id = yyjson_get_uint(id);

    auto name = yyjson_obj_get(top_factions, "name");
    if (!yyjson_is_str(name)) { return; }
    result.name = { yyjson_get_str(name), yyjson_get_len(name) };
  }

  void postrun() {
    if (!(
            result.id == expected.id &&
            result.name == expected.name &&
            result.factions_count == expected.factions_count
          ))
      throw runtime_error("top factions unequal to expected");
    yyjson_doc_free(doc);
  }

  void deinit() {}
};

BENCHMARK_TEMPLATE(yyjson);
