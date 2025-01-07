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

yyjson_doc *doc;
char *dat;
long file_len;

void yyjson__init(char *ptr, size_t len) {
    FILE *file = fopen(ptr, "r");
    fseek(file, 0, SEEK_END);
    file_len = ftell(file);
    rewind(file);

    dat = malloc(file_len);
    fread(dat, 1, file_len, file);
    fclose(file);
}

void yyjson__prerun() {}

void yyjson__run() {
  doc = yyjson_read(dat, file_len, 0);
}

void yyjson__postrun() {
  yyjson_doc_free(doc);
}

void yyjson__deinit() {
  free(dat);
}

size_t yyjson__memusage() {
    return yyjson_total; // ignore yyjson memory allocations because it does not work 100%
}
