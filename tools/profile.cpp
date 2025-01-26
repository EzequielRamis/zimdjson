#include "simdjson.h"
#include "yyjson.h"
#include <iostream>
#include <tracy/Tracy.hpp>

using namespace std;
using namespace simdjson;

// simdjson
int main(int argc, char* argv[]) {
  padded_string json;
  simdjson::error_code err;
  if (err = padded_string::load(argv[1]).get(json)) throw runtime_error("file not found");

  ondemand::parser parser;
  while (true) {
    ZoneScopedN("parser");
    auto document = parser.iterate(json);
  }
}

// yyjson
// int main(int argc, char* argv[]) {
//   while (true) {
//     ZoneScopedN("parser");
//     yyjson_doc *doc = yyjson_read_file(argv[1], 0, NULL, NULL);
//     yyjson_doc_free(doc);
//   }
// }

void * operator new ( std :: size_t count )
{
auto ptr = malloc ( count ) ;
TracyAlloc ( ptr , count ) ;
return ptr ;
}
void operator delete ( void * ptr ) noexcept
{
TracyFree ( ptr ) ;
free ( ptr ) ;
}
