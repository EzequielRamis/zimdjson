#include "simdjson.h"
#include "rapidjson/document.h"
#include "template.hpp"
#include "traced_allocator.hpp"

using namespace std;
using namespace rapidjson;
using namespace simdjson;

struct rapidjson_dom {

  padded_string json;
  Document doc{};

  void init(string_view path) {
    simdjson::error_code err;
    if (err = padded_string::load(path).get(json)) throw runtime_error("file not found");
  }

  void prerun() {}

  void run() { doc.Parse(json.data()); }

  void postrun() {}

  void deinit() {}


};

BENCHMARK_TEMPLATE(rapidjson_dom);
