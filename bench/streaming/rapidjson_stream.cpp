#include <cstdio>
#include "simdjson.h"
#include "rapidjson/document.h"
#include "rapidjson/filereadstream.h"
#include "template.hpp"
#include "traced_allocator.hpp"

using namespace std;
using namespace rapidjson;
using namespace simdjson;

struct rapidjson_stream {

  string_view path;
  Document* doc;
  FILE* fp;

  void init(string_view _path) {
    path = _path;
  }

  void prerun() {
    doc = new Document();
  }

  void run() {
    fp = fopen(path.data(), "r"); // non-Windows use "r"

    char readBuffer[65536];
    FileReadStream is(fp, readBuffer, sizeof(readBuffer));

    doc->ParseStream(is);
  }

  void postrun() {
    delete doc;
    fclose(fp);
  }

  void deinit() {}


};

BENCHMARK_TEMPLATE(rapidjson_stream);
