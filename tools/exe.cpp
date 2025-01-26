#include "simdjson.h"
#include "yyjson.h"
#include <iostream>

using namespace std;
using namespace simdjson;

// simdjson
int main(int argc, char* argv[]) {
  dom::parser parser;
  dom::element document = parser.load(argv[1]);
}

// yyjson
// int main(int argc, char* argv[]) {
//   yyjson_doc *doc = yyjson_read_file(argv[1], 0, NULL, NULL);
//   yyjson_doc_free(doc);
// }
