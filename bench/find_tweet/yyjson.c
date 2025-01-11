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

u_int64_t find_id = 505874901689851904;
const char *expected = "RT @shiawaseomamori: 一に止まると書いて、正しいという意味だなんて、この年になるまで知りませんでした。 人は生きていると、前へ前へという気持ちばかり急いて、どんどん大切なものを置き去りにしていくものでしょう。本当に正しいことというのは、一番初めの場所にあるの…";
const char *result;

yyjson_doc *doc;
char *path;

void yyjson__init(char *ptr, size_t len) {
    path = ptr;
}

void yyjson__prerun() {}

void yyjson__run() {
    doc = yyjson_read_file(path, 0, NULL, NULL);
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
      yyjson_val *id = yyjson_obj_get(tweet, "id");
      if (!yyjson_is_uint(id)) { return; }
      if (yyjson_get_uint(id) == find_id) {
        yyjson_val *text = yyjson_obj_get(tweet, "text");
        if (yyjson_is_str(id)) { return; }
        result = yyjson_get_str(text);
        return;
      }
    }
    printf("tweet not found");
}

void yyjson__postrun() {
  yyjson_doc_free(doc);
}

void yyjson__deinit() {
    if (strcmp(expected, result) != 0) {
        printf("tweet text unequal to expected");
    }
}

size_t yyjson__memusage() {
    return yyjson_total; // ignore yyjson memory allocations because it does not work 100%
}
