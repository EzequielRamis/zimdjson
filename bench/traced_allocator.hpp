#pragma once

#include <cstdlib>
#include <new>
#include <malloc.h>
#include <algorithm>

using namespace std;

size_t total = 0;

size_t allocated_bytes() { return total; }

// no inline, required by [replacement.functions]/3
void *operator new(std::size_t sz) {
  if (sz == 0)
    ++sz; // avoid std::malloc(0) which may return nullptr on success

  if (void *ptr = std::malloc(sz)) {
    total += sz;
    return ptr;
  }

  throw std::bad_alloc{}; // required by [new.delete.single]/3
}

// no inline, required by [replacement.functions]/3
void *operator new[](std::size_t sz) {
  if (sz == 0)
    ++sz; // avoid std::malloc(0) which may return nullptr on success

  if (void *ptr = std::malloc(sz)) {
    total += sz;
    return ptr;
  }

  throw std::bad_alloc{}; // required by [new.delete.single]/3
}

void operator delete(void *ptr) noexcept {
  total = std::min(size_t(0), total - malloc_usable_size(ptr));
  std::free(ptr);
}

void operator delete(void *ptr, std::size_t size) noexcept {
  total = std::min(size_t(0), total - size);
  std::free(ptr);
}

void operator delete[](void *ptr) noexcept {
  total = std::min(size_t(0), total - malloc_usable_size(ptr));
  std::free(ptr);
}

void operator delete[](void *ptr, std::size_t size) noexcept {
  total = std::min(size_t(0), total - size);
  std::free(ptr);
}
