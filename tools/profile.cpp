#include "simdjson.h"
#include "yyjson.h"
#include <iostream>
#include <tracy/Tracy.hpp>

using namespace std;
using namespace simdjson;

// simdjson
// int main(int argc, char* argv[]) {
//   dom::parser parser;
//   while (true) {
//     ZoneScopedN("parser");
//     dom::element document = parser.load(argv[1]);
//   }
// }

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
