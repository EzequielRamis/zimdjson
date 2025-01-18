#include "simdjson.h"
#include "yyjson.h"
#include "template.hpp"
#include "traced_allocator.hpp"

using namespace std;
using namespace simdjson;

struct yyjson {

  string path;
  yyjson_doc *doc;

  void init(string_view _path) {
    path = string(_path);
  }

  void prerun() {}

  void run() { doc = yyjson_read_file(path.data(), 0, NULL, NULL); }

  void postrun() {
    yyjson_doc_free(doc);
  }

  void deinit() {}
};

BENCHMARK_TEMPLATE(yyjson);
