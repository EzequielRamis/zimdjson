#include "simdjson.h"
#include "yyjson.h"
#include "template.hpp"
#include "traced_allocator.hpp"

using namespace std;
using namespace simdjson;

struct yyjson {

  string path;
  yyjson_doc *doc;
  char *buffer;

  std::string_view to_msgpack(yyjson_doc *d, uint8_t *buf) {
    buff = buf;
    yyjson_val *root = yyjson_doc_get_root(d);
    recursive_processor(root);
    return std::string_view(reinterpret_cast<char *>(buf), size_t(buff - buf));
  }

  void write_string(const char *c, size_t len) noexcept {
    write_byte(0xdb);
    write_uint32(uint32_t(len));
    ::memcpy(buff, c, len);
    buff += len;
  }

  void write_double(const double d) noexcept {
    *buff++ = 0xcb;
    ::memcpy(buff, &d, sizeof(d));
    buff += sizeof(d);
  }

  void write_byte(const uint8_t b) noexcept {
    *buff = b;
    buff++;
  }

  void write_uint32(const uint32_t w) noexcept {
    ::memcpy(buff, &w, sizeof(w));
    buff += sizeof(w);
  }

  void recursive_processor(yyjson_val *obj) {
    size_t idx, max;
    yyjson_val *val;
    yyjson_val *key;
    switch (yyjson_get_type(obj)) {
    case YYJSON_TYPE_STR:
      write_string(yyjson_get_str(obj), yyjson_get_len(obj));
      break;
    case YYJSON_TYPE_ARR:
      write_byte(0xdf);
      write_uint32(uint32_t(yyjson_arr_size(obj)));
      yyjson_arr_foreach(obj, idx, max, val) { recursive_processor(val); }
    break;
    case YYJSON_TYPE_OBJ:
      write_byte(0xdd);
      write_uint32(uint32_t(yyjson_obj_size(obj)));
      yyjson_obj_foreach(obj, idx, max, key, val) {
        write_string(yyjson_get_str(key), yyjson_get_len(key));
        recursive_processor(val);
      }
      break;
    case YYJSON_TYPE_BOOL:
      write_byte(0xc2 + yyjson_get_bool(obj));
      break;
    case YYJSON_TYPE_NULL:
      write_byte(0xc0);
      break;
    case YYJSON_TYPE_NUM:
      switch (yyjson_get_subtype(obj)) {
      case YYJSON_SUBTYPE_UINT:
        write_double(double(yyjson_get_uint(obj)));
        break;
      case YYJSON_SUBTYPE_SINT:
        write_double(double(yyjson_get_sint(obj)));
        break;
      case YYJSON_SUBTYPE_REAL:
        write_double(yyjson_get_real(obj));
        break;
      default:
        SIMDJSON_UNREACHABLE();
      }
      break;
    default:
      SIMDJSON_UNREACHABLE();
    }
  }

  void init(string_view _path) {
    path = string(_path);
  }

  void prerun() {}

  void run() {
    doc = yyjson_read_file(path.data(), 0, NULL, NULL);
    result = to_msgpack(doc, reinterpret_cast<uint8_t*>(buffer));
  }

  void postrun() {
    yyjson_doc_free(doc);
  }

  void deinit() {}
};

BENCHMARK_TEMPLATE(yyjson);
