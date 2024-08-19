#pragma once

#include <algorithm>
#include <cstdlib>
#include <malloc.h>
#include <new>

size_t total = 0;

size_t allocated_bytes() { return total; }

// no inline, required by [replacement.functions]/3
void *operator new(std::size_t sz) {
  if (sz == 0)
    ++sz; // avoid std::malloc(0) which may return nullptr on success

  if (void *ptr = std::malloc(sz)) {
    total += malloc_usable_size(ptr);
    return ptr;
  }

  throw std::bad_alloc{}; // required by [new.delete.single]/3
}

// no inline, required by [replacement.functions]/3
void *operator new[](std::size_t sz) {
  if (sz == 0)
    ++sz; // avoid std::malloc(0) which may return nullptr on success

  if (void *ptr = std::malloc(sz)) {
    total += malloc_usable_size(ptr);
    return ptr;
  }

  throw std::bad_alloc{}; // required by [new.delete.single]/3
}

void operator delete(void *ptr) noexcept {
  total -= malloc_usable_size(ptr);
  std::free(ptr);
}

void operator delete(void *ptr, std::size_t size) noexcept {
  total -= malloc_usable_size(ptr);
  std::free(ptr);
}

void operator delete[](void *ptr) noexcept {
  total -= malloc_usable_size(ptr);
  std::free(ptr);
}

void operator delete[](void *ptr, std::size_t size) noexcept {
  total -= malloc_usable_size(ptr);
  std::free(ptr);
}
