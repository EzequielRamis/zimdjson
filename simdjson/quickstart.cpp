#include "simdjson.h"
#include <iostream>
using namespace simdjson;

int main(int argc, char *argv[]) {
  simdjson::get_active_implementation() = simdjson::get_available_implementations()["haswell"];
  dom::parser parser;
  dom::element tweets = parser.load(argv[1]);
}
