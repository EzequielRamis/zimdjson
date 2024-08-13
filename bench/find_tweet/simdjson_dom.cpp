#include "simdjson.h"

extern "C" void simdjson_dom__init() {}
extern "C" void simdjson_dom__prerun() {}
extern "C" void simdjson_dom__postrun() {}
extern "C" void simdjson_dom__deinit() {}

using namespace std;
using namespace simdjson;

extern "C" void simdjson_dom__run() {
  dom::parser parser;
  dom::element document =
      parser.load("../simdjson-data/jsonexamples/twitter.json");
  int i = rand() % 100;
  string_view created_at =
      document.at_key("statuses").at(i).at_key("source").get_string();
}
