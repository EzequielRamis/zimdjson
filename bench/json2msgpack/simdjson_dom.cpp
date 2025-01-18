#include "simdjson.h"
#include "template.hpp"
#include "traced_allocator.hpp"

using namespace std;
using namespace simdjson;

struct point {
  double x;
  double y;
  double z;
};

struct simdjson_dom {

  string path;
  dom::parser parser;
  string_view result;
  char *buffer;
  uint8_t *buff{};

  std::string_view
  simdjsondom2msgpack::to_msgpack(const string &path,
                              uint8_t *buf) {
    buff = buf;

    recursive_processor(parser.load(path));
    return std::string_view(reinterpret_cast<char *>(buf), size_t(buff - buf));
  }
  void simdjsondom2msgpack::write_string(const std::string_view v) noexcept {
    write_byte(0xdb);
    write_uint32(uint32_t(v.size()));
    ::memcpy(buff, v.data(), v.size());
    buff += v.size();
  }
  void simdjsondom2msgpack::write_double(const double d) noexcept {
    *buff++ = 0xcb;
    ::memcpy(buff, &d, sizeof(d));
    buff += sizeof(d);
  }

  void simdjsondom2msgpack::write_byte(const uint8_t b) noexcept {
    *buff = b;
    buff++;
  }

  void simdjsondom2msgpack::write_uint32(const uint32_t w) noexcept {
    ::memcpy(buff, &w, sizeof(w));
    buff += sizeof(w);
  }

  uint8_t *simdjsondom2msgpack::skip_uint32() noexcept {
    uint8_t *ret = buff;
    buff += sizeof(uint32_t);
    return ret;
  }

  void simdjsondom2msgpack::write_uint32_at(const uint32_t w, uint8_t *p) noexcept {
    ::memcpy(p, &w, sizeof(w));
  }


  void simdjsondom2msgpack::recursive_processor(simdjson::dom::element element) {
    switch (element.type()) {
      case dom::element_type::ARRAY: {
        uint32_t counter = 0;
        write_byte(0xdd);
        uint8_t *location = skip_uint32();
        for (auto child : dom::array(element)) {
          counter++;
          recursive_processor(child);
        }
        write_uint32_at(counter, location);}
        break;
      case dom::element_type::OBJECT:{
        uint32_t counter = 0;
        write_byte(0xdf);
        uint8_t *location = skip_uint32();
        for (dom::key_value_pair field : dom::object(element)) {
          counter++;
          write_string(field.key);
          recursive_processor(field.value);
        }
        write_uint32_at(counter, location);
        }
        break;
      case dom::element_type::INT64:
      case dom::element_type::UINT64:
      case dom::element_type::DOUBLE:
        write_double( double(element));
        break;
      case dom::element_type::STRING:
        write_string(std::string_view(element));
        break;
      case dom::element_type::BOOL:
        write_byte(0xc2 + bool(element));
        break;
      case dom::element_type::NULL_VALUE:
        write_byte(0xc0);
        break;
      default:
        break;
    }
  }

  void init(string_view _path) {
    path = string(_path);
  }

  void prerun() {
    result.clear();
  }

  void run() {
    result = parser.to_msgpack(path, reinterpret_cast<uint8_t *>(buffer));
  }

  void postrun() {}

  void deinit() {}
};

BENCHMARK_TEMPLATE(simdjson_dom);
