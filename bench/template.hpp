#pragma once

#define BENCHMARK_TEMPLATE(alias)                                              \
  alias __##alias;                                                             \
                                                                               \
  extern "C" void alias##__init(char *ptr, size_t len) {                       \
    return __##alias.init(std::string_view{ptr, len});                         \
  }                                                                            \
                                                                               \
  extern "C" void alias##__prerun() { return __##alias.prerun(); }             \
                                                                               \
  extern "C" void alias##__run() { return __##alias.run(); }                   \
                                                                               \
  extern "C" void alias##__postrun() { return __##alias.postrun(); }           \
                                                                               \
  extern "C" void alias##__deinit() { return __##alias.deinit(); }             \
                                                                               \
  extern "C" size_t alias##__memusage() { return allocated_bytes(); }
