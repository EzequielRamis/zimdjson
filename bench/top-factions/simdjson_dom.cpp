#include "simdjson.h"
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

struct simdjson_dom {

  string path;
  dom::parser parser;
  top_factions result;

  void init(string_view _path) {
    path = string(_path);
  }

  void prerun() {}

  void run() {
    result.factions_count = 0;
    dom::element top_factions{};

    auto doc = parser.load(path);
    for (auto system : doc) {
      auto factions = system["factions"];
      if (factions.error() == NO_SUCH_FIELD) continue;
      size_t factions_count = factions.get_array().size();
      if (factions_count >= result.factions_count) {
        result.factions_count = factions_count;
        top_factions = system;
      }
    }

    result.id = top_factions["id64"];
    result.name = top_factions["name"];
  }

  void postrun() {
    if (!(
            result.id == expected.id &&
            result.name == expected.name &&
            result.factions_count == expected.factions_count
          ))
      throw runtime_error("top factions unequal to expected");
  }

  void deinit() {}
};

BENCHMARK_TEMPLATE(simdjson_dom);
