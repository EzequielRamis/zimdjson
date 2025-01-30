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

struct simdjson_ondemand {

  string path;
  ondemand::parser parser;
  top_factions result;

  void init(string_view _path) {
    path = string(_path);
  }

  void prerun() {}

  void run() {
    result.factions_count = 0;

    padded_string json;
    simdjson::error_code err;
    if (err = padded_string::load(path).get(json)) throw runtime_error("file not found");

    auto doc = parser.iterate(json);
    for (auto system : doc) {
      auto id = system["id64"];
      auto name = system["name"];
      auto factions = system["factions"];
      if (factions.error() == NO_SUCH_FIELD) continue;
      size_t factions_count = 0;
      for (auto f : factions) factions_count++;
      if (factions_count >= result.factions_count) {
        result.id = id;
        result.name = name;
        result.factions_count = factions_count;
      }
    }

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

BENCHMARK_TEMPLATE(simdjson_ondemand);
