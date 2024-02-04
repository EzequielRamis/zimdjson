#include "simdjson.h"
#include <iostream>
using namespace simdjson;

int main(int argc, char *argv[]) {
  dom::parser parser;
  dom::element tweets = parser.load(argv[1]);
}
