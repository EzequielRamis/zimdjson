#include "simdjson.h"
#include "yyjson.h"
#include "template.hpp"
#include "traced_allocator.hpp"

using namespace std;
using namespace simdjson;

// result struct
struct top_tweet {
  string_view text;
  string_view screen_name;
  int64_t retweet_count;
};

const uint64_t max_retweet_count = 60;

// expected result
const top_tweet expected = {
  "RT @shiawaseomamori: 一に止まると書いて、正しいという意味だなんて、この年になるまで知りませんでした。 人は生きていると、前へ前へという気持ちばかり急いて、どんどん大切なものを置き去りにしていくものでしょう。本当に正しいことというのは、一番初めの場所にあるの…",
    "anime_toshiden1",
    58};

struct yyjson {

  string path;
  yyjson_doc *doc;
  top_tweet result;

  void init(string_view _path) {
    path = string(_path);
  }

  void prerun() {}

  void run() {
    result.retweet_count = -1;

    yyjson_val *top_tweet{};

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

      auto retweet_count_val = yyjson_obj_get(tweet, "retweet_count");
      if (!yyjson_is_uint(retweet_count_val)) { return; }
      int64_t retweet_count = yyjson_get_uint(retweet_count_val);
      if (retweet_count <= max_retweet_count && retweet_count >= result.retweet_count) {
        result.retweet_count = retweet_count;
        top_tweet = tweet;
      }
    }

    auto text = yyjson_obj_get(top_tweet, "text");
    if (!yyjson_is_str(text)) { return; }
    result.text = { yyjson_get_str(text), yyjson_get_len(text) };

    auto user = yyjson_obj_get(top_tweet, "user");
    if (!yyjson_is_obj(user)) { return; }
    auto screen_name = yyjson_obj_get(user, "screen_name");
    if (!yyjson_is_str(screen_name)) { return; }
    result.screen_name = { yyjson_get_str(screen_name), yyjson_get_len(screen_name) };
  }

  void postrun() {
    yyjson_doc_free(doc);
  }

  void deinit() {
    if (!(
            result.text == expected.text &&
            result.screen_name == expected.screen_name &&
            result.retweet_count == expected.retweet_count
          ))
      throw runtime_error("top tweet unequal to expected");
  }
};

BENCHMARK_TEMPLATE(yyjson);
