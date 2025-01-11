#include <stdlib.h>
#include <stddef.h>
#include <malloc.h>
#include <stdio.h>
#include "yyjson.h"

size_t yyjson_total = 0;

static void *priv_malloc(void *ctx, size_t size) {
    void *ptr = malloc(size);
    yyjson_total += malloc_usable_size(ptr);
    return ptr;
}

static void *priv_realloc(void *ctx, void *ptr, size_t old_size, size_t size) {
    size_t old_total = malloc_usable_size(ptr);
    void *new_ptr = realloc(ptr, size);
    size_t new_total = malloc_usable_size(ptr);
    yyjson_total += new_total - old_total;
    return new_ptr;
}

static void priv_free(void *ctx, void *ptr) {
    yyjson_total -= malloc_usable_size(ptr);
    free(ptr);
}

static const yyjson_alc PRIV_ALC = {
    priv_malloc,
    priv_realloc,
    priv_free,
    NULL
};

struct top_tweet_result {
  int64_t retweet_count;
  const char* screen_name;
  const char* text;
};

struct top_tweet_result expected  = {
  58,
  "anime_toshiden1",
  "RT @shiawaseomamori: 一に止まると書いて、正しいという意味だなんて、この年になるまで知りませんでした。 人は生きていると、前へ前へという気持ちばかり急いて、どんどん大切なものを置き去りにしていくものでしょう。本当に正しいことというのは、一番初めの場所にあるの…"
};

int64_t max_retweet_count = 60;

struct top_tweet_result result;

yyjson_doc *doc;
char *path;

void yyjson__init(char *ptr, size_t len) {
    path = ptr;
}

void yyjson__prerun() {}

void yyjson__run() {
    doc = yyjson_read_file(path, 0, NULL, NULL);
    result.retweet_count = -1;

    yyjson_val *top_tweet;

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

      yyjson_val *retweet_count_val = yyjson_obj_get(tweet, "retweet_count");
      if (!yyjson_is_uint(retweet_count_val)) { return; }
      int64_t retweet_count = yyjson_get_uint(retweet_count_val);
      if (retweet_count <= max_retweet_count && retweet_count >= result.retweet_count) {
        result.retweet_count = retweet_count;
        top_tweet = tweet;
      }
    }

    yyjson_val *text = yyjson_obj_get(top_tweet, "text");
    if (!yyjson_is_str(text)) { return; }
    result.text = yyjson_get_str(text);

    yyjson_val *user = yyjson_obj_get(top_tweet, "user");
    if (!yyjson_is_obj(user)) { return; }
    yyjson_val *screen_name = yyjson_obj_get(user, "screen_name");
    if (!yyjson_is_str(screen_name)) { return; }
    result.screen_name = yyjson_get_str(screen_name);
}

void yyjson__postrun() {
  yyjson_doc_free(doc);
}

void yyjson__deinit() {
    if (!(strcmp(result.text, expected.text) == 0 &&
        strcmp(result.screen_name, expected.screen_name) == 0 &&
        result.retweet_count == expected.retweet_count))
    {
        printf("top tweet text unequal to expected");
    }
}

size_t yyjson__memusage() {
    return yyjson_total; // ignore yyjson memory allocations because it does not work 100%
}
