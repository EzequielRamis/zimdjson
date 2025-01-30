#include "simdjson.h"
#include "yyjson.h"
#include "template.hpp"
#include "traced_allocator.hpp"

using namespace std;
using namespace simdjson;

struct yyjson {

  string path;
  yyjson_doc *doc;
  vector<uint64_t> result{};

  void init(string_view _path) {
    path = string(_path);
  }

  void prerun() {
      result.clear();
  }

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
      auto user = yyjson_obj_get(tweet, "user");
      if (!yyjson_is_obj(user)) { return; }
      auto id = yyjson_obj_get(user, "id");
      if (!yyjson_is_uint(id)) { return; }
      result.push_back(yyjson_get_uint(id));

      // Not all tweets have a "retweeted_status", but when they do
      // we want to go and find the user within.
      auto retweet = yyjson_obj_get(tweet, "retweeted_status");
      if (retweet) {
        if (!yyjson_is_obj(retweet)) { return; }
        user = yyjson_obj_get(retweet, "user");
        if (!yyjson_is_obj(user)) { return; }
        id = yyjson_obj_get(user, "id");
        if (!yyjson_is_uint(id)) { return; }
        result.push_back(yyjson_get_sint(id));
      }
    }
  }

  void postrun() {
    yyjson_doc_free(doc);
  }

  void deinit() {}
};

BENCHMARK_TEMPLATE(yyjson);
