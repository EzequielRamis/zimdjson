#include "simdjson.h"
#include "yyjson.h"
#include "template.hpp"
#include "traced_allocator.hpp"

using namespace std;
using namespace simdjson;

struct yyjson {

  padded_string json;
  yyjson_doc *doc;

  void init(string_view path) {
    simdjson::error_code err;
    if (err = padded_string::load(path).get(json)) throw runtime_error("file not found");
  }

  void prerun() {}

  void run() { doc = yyjson_read(json.data(), json.size(), 0); }

  void postrun() {
    yyjson_doc_free(doc);
  }

  void deinit() {}
};

BENCHMARK_TEMPLATE(yyjson);
