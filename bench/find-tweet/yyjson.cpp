#include "simdjson.h"
#include "yyjson.h"
#include "template.hpp"
#include "traced_allocator.hpp"

using namespace std;
using namespace simdjson;

const uint64_t find_id = 505874901689851904;
const string expected = "RT @shiawaseomamori: "
                        "一に止まると書いて、正しいという意味だなんて、この年に"
                        "なるまで知りませんでした。 "
                        "人は生きていると、前へ前へという気持ちばかり急いて、ど"
                        "んどん大切なものを置き去りにしていくものでしょう。本当"
                        "に正しいことというのは、一番初めの場所にあるの…";

struct yyjson {

  string path;
  yyjson_doc *doc;
  string_view result;

  void init(string_view _path) {
    path = string(_path);
  }

  void prerun() {}

  void run() {
    doc = yyjson_read_file(path.data(), 0, NULL, NULL);
    if (!doc) { return; }
    yyjson_val *root = yyjson_doc_get_root(doc);
    if (!yyjson_is_obj(root)) { return; }
    yyjson_val *statuses = yyjson_obj_get(root, "statuses");
    if (!yyjson_is_arr(statuses)) { return; }

    // Walk the document, parsing the tweets as we go
    size_t tweet_idx, tweets_max;
    yyjson_val *tweet;
    yyjson_arr_foreach(statuses, tweet_idx, tweets_max, tweet) {
      if (!yyjson_is_obj(tweet)) { return; }
      auto id = yyjson_obj_get(tweet, "id");
      if (!yyjson_is_uint(id)) { return; }
      if (yyjson_get_uint(id) == find_id) {
        auto text = yyjson_obj_get(tweet, "text");
        if (!yyjson_is_str(text)) { return; }
        result = { yyjson_get_str(text), yyjson_get_len(text) };
        return;
      }
    }
    throw runtime_error("tweet not found");
  }

  void postrun() {
    if (expected != result)
      throw runtime_error("tweet text unequal to expected");
    yyjson_doc_free(doc);
  }

  void deinit() {}
};

BENCHMARK_TEMPLATE(yyjson);
