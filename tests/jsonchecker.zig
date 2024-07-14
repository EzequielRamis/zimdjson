//! This file is auto-generated with `zig build test-jsonchecker`
const std = @import("std");
const DOM = @import("zimdjson").DOM;
const SIMDJSON_DATA = @embedFile("simdjson-data");

test "fail02"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail02.json") catch return;
  return error.MustHaveFailed;
}

test "fail03"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail03.json") catch return;
  return error.MustHaveFailed;
}

test "fail04"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail04.json") catch return;
  return error.MustHaveFailed;
}

test "fail05"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail05.json") catch return;
  return error.MustHaveFailed;
}

test "fail06"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail06.json") catch return;
  return error.MustHaveFailed;
}

test "fail07"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail07.json") catch return;
  return error.MustHaveFailed;
}

test "fail08"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail08.json") catch return;
  return error.MustHaveFailed;
}

test "fail09"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail09.json") catch return;
  return error.MustHaveFailed;
}

test "fail10"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail10.json") catch return;
  return error.MustHaveFailed;
}

test "fail11"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail11.json") catch return;
  return error.MustHaveFailed;
}

test "fail12"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail12.json") catch return;
  return error.MustHaveFailed;
}

test "fail13"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail13.json") catch return;
  return error.MustHaveFailed;
}

test "fail14"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail14.json") catch return;
  return error.MustHaveFailed;
}

test "fail15"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail15.json") catch return;
  return error.MustHaveFailed;
}

test "fail16"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail16.json") catch return;
  return error.MustHaveFailed;
}

test "fail17"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail17.json") catch return;
  return error.MustHaveFailed;
}

test "fail19"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail19.json") catch return;
  return error.MustHaveFailed;
}

test "fail20"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail20.json") catch return;
  return error.MustHaveFailed;
}

test "fail21"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail21.json") catch return;
  return error.MustHaveFailed;
}

test "fail22"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail22.json") catch return;
  return error.MustHaveFailed;
}

test "fail23"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail23.json") catch return;
  return error.MustHaveFailed;
}

test "fail24"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail24.json") catch return;
  return error.MustHaveFailed;
}

test "fail25"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail25.json") catch return;
  return error.MustHaveFailed;
}

test "fail26"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail26.json") catch return;
  return error.MustHaveFailed;
}

test "fail27"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail27.json") catch return;
  return error.MustHaveFailed;
}

test "fail28"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail28.json") catch return;
  return error.MustHaveFailed;
}

test "fail29"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail29.json") catch return;
  return error.MustHaveFailed;
}

test "fail30"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail30.json") catch return;
  return error.MustHaveFailed;
}

test "fail31"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail31.json") catch return;
  return error.MustHaveFailed;
}

test "fail32"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail32.json") catch return;
  return error.MustHaveFailed;
}

test "fail33"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail33.json") catch return;
  return error.MustHaveFailed;
}

test "fail34"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail34.json") catch return;
  return error.MustHaveFailed;
}

test "fail35"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail35.json") catch return;
  return error.MustHaveFailed;
}

test "fail36"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail36.json") catch return;
  return error.MustHaveFailed;
}

test "fail37"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail37.json") catch return;
  return error.MustHaveFailed;
}

test "fail38"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail38.json") catch return;
  return error.MustHaveFailed;
}

test "fail41_toolarge"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail41_toolarge.json") catch return;
  return error.MustHaveFailed;
}

test "fail42"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail42.json") catch return;
  return error.MustHaveFailed;
}

test "fail43"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail43.json") catch return;
  return error.MustHaveFailed;
}

test "fail44"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail44.json") catch return;
  return error.MustHaveFailed;
}

test "fail45"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail45.json") catch return;
  return error.MustHaveFailed;
}

test "fail46"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail46.json") catch return;
  return error.MustHaveFailed;
}

test "fail47"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail47.json") catch return;
  return error.MustHaveFailed;
}

test "fail48"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail48.json") catch return;
  return error.MustHaveFailed;
}

test "fail49"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail49.json") catch return;
  return error.MustHaveFailed;
}

test "fail50"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail50.json") catch return;
  return error.MustHaveFailed;
}

test "fail51"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail51.json") catch return;
  return error.MustHaveFailed;
}

test "fail52"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail52.json") catch return;
  return error.MustHaveFailed;
}

test "fail53"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail53.json") catch return;
  return error.MustHaveFailed;
}

test "fail54"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail54.json") catch return;
  return error.MustHaveFailed;
}

test "fail55"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail55.json") catch return;
  return error.MustHaveFailed;
}

test "fail56"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail56.json") catch return;
  return error.MustHaveFailed;
}

test "fail57"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail57.json") catch return;
  return error.MustHaveFailed;
}

test "fail58"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail58.json") catch return;
  return error.MustHaveFailed;
}

test "fail59"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail59.json") catch return;
  return error.MustHaveFailed;
}

test "fail60"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail60.json") catch return;
  return error.MustHaveFailed;
}

test "fail61"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail61.json") catch return;
  return error.MustHaveFailed;
}

test "fail62"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail62.json") catch return;
  return error.MustHaveFailed;
}

test "fail63"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail63.json") catch return;
  return error.MustHaveFailed;
}

test "fail64"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail64.json") catch return;
  return error.MustHaveFailed;
}

test "fail65"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail65.json") catch return;
  return error.MustHaveFailed;
}

test "fail66"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail66.json") catch return;
  return error.MustHaveFailed;
}

test "fail67"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail67.json") catch return;
  return error.MustHaveFailed;
}

test "fail68"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail68.json") catch return;
  return error.MustHaveFailed;
}

test "fail69"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail69.json") catch return;
  return error.MustHaveFailed;
}

test "fail70"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail70.json") catch return;
  return error.MustHaveFailed;
}

test "fail71"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail71.json") catch return;
  return error.MustHaveFailed;
}

test "fail72"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail72.json") catch return;
  return error.MustHaveFailed;
}

test "fail73"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail73.json") catch return;
  return error.MustHaveFailed;
}

test "fail74"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail74.json") catch return;
  return error.MustHaveFailed;
}

test "fail75"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail75.json") catch return;
  return error.MustHaveFailed;
}

test "fail76"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail76.json") catch return;
  return error.MustHaveFailed;
}

test "fail77"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail77.json") catch return;
  return error.MustHaveFailed;
}

test "fail78"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail78.json") catch return;
  return error.MustHaveFailed;
}

test "fail79"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail79.json") catch return;
  return error.MustHaveFailed;
}

test "fail80"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail80.json") catch return;
  return error.MustHaveFailed;
}

test "fail81"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail81.json") catch return;
  return error.MustHaveFailed;
}

test "fail82"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail82.json") catch return;
  return error.MustHaveFailed;
}

test "n_array_1_true_without_comma"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_array_1_true_without_comma.json") catch return;
  return error.MustHaveFailed;
}

test "n_array_a_invalid_utf8"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_array_a_invalid_utf8.json") catch return;
  return error.MustHaveFailed;
}

test "n_array_colon_instead_of_comma"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_array_colon_instead_of_comma.json") catch return;
  return error.MustHaveFailed;
}

test "n_array_comma_after_close"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_array_comma_after_close.json") catch return;
  return error.MustHaveFailed;
}

test "n_array_comma_and_number"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_array_comma_and_number.json") catch return;
  return error.MustHaveFailed;
}

test "n_array_double_comma"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_array_double_comma.json") catch return;
  return error.MustHaveFailed;
}

test "n_array_double_extra_comma"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_array_double_extra_comma.json") catch return;
  return error.MustHaveFailed;
}

test "n_array_extra_close"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_array_extra_close.json") catch return;
  return error.MustHaveFailed;
}

test "n_array_extra_comma"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_array_extra_comma.json") catch return;
  return error.MustHaveFailed;
}

test "n_array_incomplete"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_array_incomplete.json") catch return;
  return error.MustHaveFailed;
}

test "n_array_incomplete_invalid_value"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_array_incomplete_invalid_value.json") catch return;
  return error.MustHaveFailed;
}

test "n_array_inner_array_no_comma"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_array_inner_array_no_comma.json") catch return;
  return error.MustHaveFailed;
}

test "n_array_invalid_utf8"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_array_invalid_utf8.json") catch return;
  return error.MustHaveFailed;
}

test "n_array_items_separated_by_semicolon"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_array_items_separated_by_semicolon.json") catch return;
  return error.MustHaveFailed;
}

test "n_array_just_comma"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_array_just_comma.json") catch return;
  return error.MustHaveFailed;
}

test "n_array_just_minus"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_array_just_minus.json") catch return;
  return error.MustHaveFailed;
}

test "n_array_missing_value"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_array_missing_value.json") catch return;
  return error.MustHaveFailed;
}

test "n_array_newlines_unclosed"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_array_newlines_unclosed.json") catch return;
  return error.MustHaveFailed;
}

test "n_array_number_and_comma"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_array_number_and_comma.json") catch return;
  return error.MustHaveFailed;
}

test "n_array_number_and_several_commas"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_array_number_and_several_commas.json") catch return;
  return error.MustHaveFailed;
}

test "n_array_spaces_vertical_tab_formfeed"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_array_spaces_vertical_tab_formfeed.json") catch return;
  return error.MustHaveFailed;
}

test "n_array_star_inside"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_array_star_inside.json") catch return;
  return error.MustHaveFailed;
}

test "n_array_unclosed"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_array_unclosed.json") catch return;
  return error.MustHaveFailed;
}

test "n_array_unclosed_trailing_comma"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_array_unclosed_trailing_comma.json") catch return;
  return error.MustHaveFailed;
}

test "n_array_unclosed_with_new_lines"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_array_unclosed_with_new_lines.json") catch return;
  return error.MustHaveFailed;
}

test "n_array_unclosed_with_object_inside"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_array_unclosed_with_object_inside.json") catch return;
  return error.MustHaveFailed;
}

test "n_incomplete_false"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_incomplete_false.json") catch return;
  return error.MustHaveFailed;
}

test "n_incomplete_null"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_incomplete_null.json") catch return;
  return error.MustHaveFailed;
}

test "n_incomplete_true"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_incomplete_true.json") catch return;
  return error.MustHaveFailed;
}

test "n_multidigit_number_then_00"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_multidigit_number_then_00.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_++"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_++.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_+1"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_+1.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_+Inf"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_+Inf.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_-01"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_-01.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_-1.0."{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_-1.0..json") catch return;
  return error.MustHaveFailed;
}

test "n_number_-2."{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_-2..json") catch return;
  return error.MustHaveFailed;
}

test "n_number_-NaN"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_-NaN.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_.-1"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_.-1.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_.2e-3"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_.2e-3.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_0.1.2"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_0.1.2.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_0.3e+"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_0.3e+.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_0.3e"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_0.3e.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_0.e1"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_0.e1.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_0_capital_E+"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_0_capital_E+.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_0_capital_E"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_0_capital_E.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_0e+"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_0e+.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_0e"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_0e.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_1.0e+"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_1.0e+.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_1.0e-"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_1.0e-.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_1.0e"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_1.0e.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_1_000"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_1_000.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_1eE2"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_1eE2.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_2.e+3"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_2.e+3.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_2.e-3"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_2.e-3.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_2.e3"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_2.e3.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_9.e+"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_9.e+.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_Inf"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_Inf.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_NaN"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_NaN.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_U+FF11_fullwidth_digit_one"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_U+FF11_fullwidth_digit_one.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_expression"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_expression.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_hex_1_digit"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_hex_1_digit.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_hex_2_digits"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_hex_2_digits.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_infinity"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_infinity.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_invalid+-"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_invalid+-.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_invalid-negative-real"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_invalid-negative-real.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_invalid-utf-8-in-bigger-int"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_invalid-utf-8-in-bigger-int.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_invalid-utf-8-in-exponent"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_invalid-utf-8-in-exponent.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_invalid-utf-8-in-int"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_invalid-utf-8-in-int.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_minus_infinity"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_minus_infinity.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_minus_sign_with_trailing_garbage"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_minus_sign_with_trailing_garbage.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_minus_space_1"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_minus_space_1.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_neg_int_starting_with_zero"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_neg_int_starting_with_zero.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_neg_real_without_int_part"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_neg_real_without_int_part.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_neg_with_garbage_at_end"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_neg_with_garbage_at_end.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_real_garbage_after_e"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_real_garbage_after_e.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_real_with_invalid_utf8_after_e"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_real_with_invalid_utf8_after_e.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_real_without_fractional_part"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_real_without_fractional_part.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_starting_with_dot"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_starting_with_dot.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_with_alpha"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_with_alpha.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_with_alpha_char"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_with_alpha_char.json") catch return;
  return error.MustHaveFailed;
}

test "n_number_with_leading_zero"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_number_with_leading_zero.json") catch return;
  return error.MustHaveFailed;
}

test "n_object_bad_value"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_object_bad_value.json") catch return;
  return error.MustHaveFailed;
}

test "n_object_bracket_key"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_object_bracket_key.json") catch return;
  return error.MustHaveFailed;
}

test "n_object_comma_instead_of_colon"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_object_comma_instead_of_colon.json") catch return;
  return error.MustHaveFailed;
}

test "n_object_double_colon"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_object_double_colon.json") catch return;
  return error.MustHaveFailed;
}

test "n_object_emoji"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_object_emoji.json") catch return;
  return error.MustHaveFailed;
}

test "n_object_garbage_at_end"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_object_garbage_at_end.json") catch return;
  return error.MustHaveFailed;
}

test "n_object_key_with_single_quotes"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_object_key_with_single_quotes.json") catch return;
  return error.MustHaveFailed;
}

test "n_object_lone_continuation_byte_in_key_and_trailing_comma"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_object_lone_continuation_byte_in_key_and_trailing_comma.json") catch return;
  return error.MustHaveFailed;
}

test "n_object_missing_colon"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_object_missing_colon.json") catch return;
  return error.MustHaveFailed;
}

test "n_object_missing_key"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_object_missing_key.json") catch return;
  return error.MustHaveFailed;
}

test "n_object_missing_semicolon"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_object_missing_semicolon.json") catch return;
  return error.MustHaveFailed;
}

test "n_object_missing_value"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_object_missing_value.json") catch return;
  return error.MustHaveFailed;
}

test "n_object_no-colon"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_object_no-colon.json") catch return;
  return error.MustHaveFailed;
}

test "n_object_non_string_key"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_object_non_string_key.json") catch return;
  return error.MustHaveFailed;
}

test "n_object_non_string_key_but_huge_number_instead"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_object_non_string_key_but_huge_number_instead.json") catch return;
  return error.MustHaveFailed;
}

test "n_object_repeated_null_null"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_object_repeated_null_null.json") catch return;
  return error.MustHaveFailed;
}

test "n_object_several_trailing_commas"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_object_several_trailing_commas.json") catch return;
  return error.MustHaveFailed;
}

test "n_object_single_quote"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_object_single_quote.json") catch return;
  return error.MustHaveFailed;
}

test "n_object_trailing_comma"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_object_trailing_comma.json") catch return;
  return error.MustHaveFailed;
}

test "n_object_trailing_comment"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_object_trailing_comment.json") catch return;
  return error.MustHaveFailed;
}

test "n_object_trailing_comment_open"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_object_trailing_comment_open.json") catch return;
  return error.MustHaveFailed;
}

test "n_object_trailing_comment_slash_open"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_object_trailing_comment_slash_open.json") catch return;
  return error.MustHaveFailed;
}

test "n_object_trailing_comment_slash_open_incomplete"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_object_trailing_comment_slash_open_incomplete.json") catch return;
  return error.MustHaveFailed;
}

test "n_object_two_commas_in_a_row"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_object_two_commas_in_a_row.json") catch return;
  return error.MustHaveFailed;
}

test "n_object_unquoted_key"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_object_unquoted_key.json") catch return;
  return error.MustHaveFailed;
}

test "n_object_unterminated-value"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_object_unterminated-value.json") catch return;
  return error.MustHaveFailed;
}

test "n_object_with_single_string"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_object_with_single_string.json") catch return;
  return error.MustHaveFailed;
}

test "n_object_with_trailing_garbage"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_object_with_trailing_garbage.json") catch return;
  return error.MustHaveFailed;
}

test "n_single_space"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_single_space.json") catch return;
  return error.MustHaveFailed;
}

test "n_string_1_surrogate_then_escape"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_string_1_surrogate_then_escape.json") catch return;
  return error.MustHaveFailed;
}

test "n_string_1_surrogate_then_escape_u"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_string_1_surrogate_then_escape_u.json") catch return;
  return error.MustHaveFailed;
}

test "n_string_1_surrogate_then_escape_u1"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_string_1_surrogate_then_escape_u1.json") catch return;
  return error.MustHaveFailed;
}

test "n_string_1_surrogate_then_escape_u1x"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_string_1_surrogate_then_escape_u1x.json") catch return;
  return error.MustHaveFailed;
}

test "n_string_accentuated_char_no_quotes"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_string_accentuated_char_no_quotes.json") catch return;
  return error.MustHaveFailed;
}

test "n_string_backslash_00"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_string_backslash_00.json") catch return;
  return error.MustHaveFailed;
}

test "n_string_escape_x"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_string_escape_x.json") catch return;
  return error.MustHaveFailed;
}

test "n_string_escaped_backslash_bad"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_string_escaped_backslash_bad.json") catch return;
  return error.MustHaveFailed;
}

test "n_string_escaped_ctrl_char_tab"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_string_escaped_ctrl_char_tab.json") catch return;
  return error.MustHaveFailed;
}

test "n_string_escaped_emoji"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_string_escaped_emoji.json") catch return;
  return error.MustHaveFailed;
}

test "n_string_incomplete_escape"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_string_incomplete_escape.json") catch return;
  return error.MustHaveFailed;
}

test "n_string_incomplete_escaped_character"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_string_incomplete_escaped_character.json") catch return;
  return error.MustHaveFailed;
}

test "n_string_incomplete_surrogate"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_string_incomplete_surrogate.json") catch return;
  return error.MustHaveFailed;
}

test "n_string_incomplete_surrogate_escape_invalid"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_string_incomplete_surrogate_escape_invalid.json") catch return;
  return error.MustHaveFailed;
}

test "n_string_invalid-utf-8-in-escape"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_string_invalid-utf-8-in-escape.json") catch return;
  return error.MustHaveFailed;
}

test "n_string_invalid_backslash_esc"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_string_invalid_backslash_esc.json") catch return;
  return error.MustHaveFailed;
}

test "n_string_invalid_unicode_escape"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_string_invalid_unicode_escape.json") catch return;
  return error.MustHaveFailed;
}

test "n_string_invalid_utf8_after_escape"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_string_invalid_utf8_after_escape.json") catch return;
  return error.MustHaveFailed;
}

test "n_string_leading_uescaped_thinspace"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_string_leading_uescaped_thinspace.json") catch return;
  return error.MustHaveFailed;
}

test "n_string_no_quotes_with_bad_escape"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_string_no_quotes_with_bad_escape.json") catch return;
  return error.MustHaveFailed;
}

test "n_string_single_doublequote"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_string_single_doublequote.json") catch return;
  return error.MustHaveFailed;
}

test "n_string_single_quote"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_string_single_quote.json") catch return;
  return error.MustHaveFailed;
}

test "n_string_single_string_no_double_quotes"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_string_single_string_no_double_quotes.json") catch return;
  return error.MustHaveFailed;
}

test "n_string_start_escape_unclosed"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_string_start_escape_unclosed.json") catch return;
  return error.MustHaveFailed;
}

test "n_string_unescaped_crtl_char"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_string_unescaped_crtl_char.json") catch return;
  return error.MustHaveFailed;
}

test "n_string_unescaped_newline"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_string_unescaped_newline.json") catch return;
  return error.MustHaveFailed;
}

test "n_string_unescaped_tab"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_string_unescaped_tab.json") catch return;
  return error.MustHaveFailed;
}

test "n_string_unicode_CapitalU"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_string_unicode_CapitalU.json") catch return;
  return error.MustHaveFailed;
}

test "n_string_with_trailing_garbage"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_string_with_trailing_garbage.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_100000_opening_arrays"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_100000_opening_arrays.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_U+2060_word_joined"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_U+2060_word_joined.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_UTF8_BOM_no_data"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_UTF8_BOM_no_data.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_angle_bracket_."{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_angle_bracket_..json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_angle_bracket_null"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_angle_bracket_null.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_array_trailing_garbage"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_array_trailing_garbage.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_array_with_extra_array_close"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_array_with_extra_array_close.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_array_with_unclosed_string"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_array_with_unclosed_string.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_ascii-unicode-identifier"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_ascii-unicode-identifier.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_capitalized_True"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_capitalized_True.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_close_unopened_array"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_close_unopened_array.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_comma_instead_of_closing_brace"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_comma_instead_of_closing_brace.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_double_array"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_double_array.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_end_array"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_end_array.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_incomplete_UTF8_BOM"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_incomplete_UTF8_BOM.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_lone-invalid-utf-8"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_lone-invalid-utf-8.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_lone-open-bracket"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_lone-open-bracket.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_no_data"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_no_data.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_null-byte-outside-string"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_null-byte-outside-string.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_number_with_trailing_garbage"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_number_with_trailing_garbage.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_object_followed_by_closing_object"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_object_followed_by_closing_object.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_object_unclosed_no_value"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_object_unclosed_no_value.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_object_with_comment"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_object_with_comment.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_object_with_trailing_garbage"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_object_with_trailing_garbage.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_open_array_apostrophe"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_open_array_apostrophe.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_open_array_comma"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_open_array_comma.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_open_array_object"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_open_array_object.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_open_array_open_object"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_open_array_open_object.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_open_array_open_string"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_open_array_open_string.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_open_array_string"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_open_array_string.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_open_object"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_open_object.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_open_object_close_array"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_open_object_close_array.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_open_object_comma"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_open_object_comma.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_open_object_open_array"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_open_object_open_array.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_open_object_open_string"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_open_object_open_string.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_open_object_string_with_apostrophes"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_open_object_string_with_apostrophes.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_open_open"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_open_open.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_single_eacute"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_single_eacute.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_single_star"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_single_star.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_trailing_#"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_trailing_#.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_uescaped_LF_before_string"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_uescaped_LF_before_string.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_unclosed_array"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_unclosed_array.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_unclosed_array_partial_null"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_unclosed_array_partial_null.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_unclosed_array_unfinished_false"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_unclosed_array_unfinished_false.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_unclosed_array_unfinished_true"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_unclosed_array_unfinished_true.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_unclosed_object"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_unclosed_object.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_unicode-identifier"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_unicode-identifier.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_whitespace_U+2060_word_joiner"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_whitespace_U+2060_word_joiner.json") catch return;
  return error.MustHaveFailed;
}

test "n_structure_whitespace_formfeed"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/n_structure_whitespace_formfeed.json") catch return;
  return error.MustHaveFailed;
}

test "pass01"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/pass01.json");
}

test "pass02"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/pass02.json");
}

test "pass03"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/pass03.json");
}

test "pass04"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/pass04.json");
}

test "pass05"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/pass05.json");
}

test "pass06"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/pass06.json");
}

test "pass07"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/pass07.json");
}

test "pass08"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/pass08.json");
}

test "pass09"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/pass09.json");
}

test "pass10"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/pass10.json");
}

test "pass11"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/pass11.json");
}

test "pass12"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/pass12.json");
}

test "pass13"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/pass13.json");
}

test "pass14"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/pass14.json");
}

test "pass15"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/pass15.json");
}

test "pass16"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/pass16.json");
}

test "pass17"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/pass17.json");
}

test "pass18"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/pass18.json");
}

test "pass19"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/pass19.json");
}

test "pass20"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/pass20.json");
}

test "pass21"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/pass21.json");
}

test "pass22"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/pass22.json");
}

test "pass23"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/pass23.json");
}

test "pass24"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/pass24.json");
}

test "pass25"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/pass25.json");
}

test "pass26"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/pass26.json");
}

test "pass27"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/pass27.json");
}

test "y_array_arraysWithSpaces"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_array_arraysWithSpaces.json");
}

test "y_array_empty-string"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_array_empty-string.json");
}

test "y_array_empty"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_array_empty.json");
}

test "y_array_ending_with_newline"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_array_ending_with_newline.json");
}

test "y_array_false"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_array_false.json");
}

test "y_array_heterogeneous"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_array_heterogeneous.json");
}

test "y_array_null"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_array_null.json");
}

test "y_array_with_1_and_newline"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_array_with_1_and_newline.json");
}

test "y_array_with_leading_space"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_array_with_leading_space.json");
}

test "y_array_with_several_null"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_array_with_several_null.json");
}

test "y_array_with_trailing_space"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_array_with_trailing_space.json");
}

test "y_number"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_number.json");
}

test "y_number_0e+1"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_number_0e+1.json");
}

test "y_number_0e1"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_number_0e1.json");
}

test "y_number_after_space"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_number_after_space.json");
}

test "y_number_double_close_to_zero"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_number_double_close_to_zero.json");
}

test "y_number_int_with_exp"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_number_int_with_exp.json");
}

test "y_number_minus_zero"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_number_minus_zero.json");
}

test "y_number_negative_int"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_number_negative_int.json");
}

test "y_number_negative_one"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_number_negative_one.json");
}

test "y_number_negative_zero"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_number_negative_zero.json");
}

test "y_number_real_capital_e"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_number_real_capital_e.json");
}

test "y_number_real_capital_e_neg_exp"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_number_real_capital_e_neg_exp.json");
}

test "y_number_real_capital_e_pos_exp"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_number_real_capital_e_pos_exp.json");
}

test "y_number_real_exponent"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_number_real_exponent.json");
}

test "y_number_real_fraction_exponent"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_number_real_fraction_exponent.json");
}

test "y_number_real_neg_exp"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_number_real_neg_exp.json");
}

test "y_number_real_pos_exponent"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_number_real_pos_exponent.json");
}

test "y_number_simple_int"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_number_simple_int.json");
}

test "y_number_simple_real"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_number_simple_real.json");
}

test "y_object"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_object.json");
}

test "y_object_basic"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_object_basic.json");
}

test "y_object_duplicated_key"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_object_duplicated_key.json");
}

test "y_object_duplicated_key_and_value"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_object_duplicated_key_and_value.json");
}

test "y_object_empty"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_object_empty.json");
}

test "y_object_empty_key"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_object_empty_key.json");
}

test "y_object_escaped_null_in_key"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_object_escaped_null_in_key.json");
}

test "y_object_extreme_numbers"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_object_extreme_numbers.json");
}

test "y_object_long_strings"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_object_long_strings.json");
}

test "y_object_simple"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_object_simple.json");
}

test "y_object_string_unicode"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_object_string_unicode.json");
}

test "y_object_with_newlines"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_object_with_newlines.json");
}

test "y_string_1_2_3_bytes_UTF-8_sequences"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_1_2_3_bytes_UTF-8_sequences.json");
}

test "y_string_accepted_surrogate_pair"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_accepted_surrogate_pair.json");
}

test "y_string_accepted_surrogate_pairs"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_accepted_surrogate_pairs.json");
}

test "y_string_allowed_escapes"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_allowed_escapes.json");
}

test "y_string_backslash_and_u_escaped_zero"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_backslash_and_u_escaped_zero.json");
}

test "y_string_backslash_doublequotes"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_backslash_doublequotes.json");
}

test "y_string_comments"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_comments.json");
}

test "y_string_double_escape_a"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_double_escape_a.json");
}

test "y_string_double_escape_n"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_double_escape_n.json");
}

test "y_string_escaped_control_character"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_escaped_control_character.json");
}

test "y_string_escaped_noncharacter"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_escaped_noncharacter.json");
}

test "y_string_in_array"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_in_array.json");
}

test "y_string_in_array_with_leading_space"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_in_array_with_leading_space.json");
}

test "y_string_last_surrogates_1_and_2"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_last_surrogates_1_and_2.json");
}

test "y_string_nbsp_uescaped"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_nbsp_uescaped.json");
}

test "y_string_nonCharacterInUTF-8_U+10FFFF"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_nonCharacterInUTF-8_U+10FFFF.json");
}

test "y_string_nonCharacterInUTF-8_U+FFFF"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_nonCharacterInUTF-8_U+FFFF.json");
}

test "y_string_null_escape"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_null_escape.json");
}

test "y_string_one-byte-utf-8"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_one-byte-utf-8.json");
}

test "y_string_pi"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_pi.json");
}

test "y_string_reservedCharacterInUTF-8_U+1BFFF"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_reservedCharacterInUTF-8_U+1BFFF.json");
}

test "y_string_simple_ascii"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_simple_ascii.json");
}

test "y_string_space"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_space.json");
}

test "y_string_surrogates_U+1D11E_MUSICAL_SYMBOL_G_CLEF"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_surrogates_U+1D11E_MUSICAL_SYMBOL_G_CLEF.json");
}

test "y_string_three-byte-utf-8"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_three-byte-utf-8.json");
}

test "y_string_two-byte-utf-8"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_two-byte-utf-8.json");
}

test "y_string_u+2028_line_sep"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_u+2028_line_sep.json");
}

test "y_string_u+2029_par_sep"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_u+2029_par_sep.json");
}

test "y_string_uEscape"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_uEscape.json");
}

test "y_string_uescaped_newline"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_uescaped_newline.json");
}

test "y_string_unescaped_char_delete"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_unescaped_char_delete.json");
}

test "y_string_unicode"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_unicode.json");
}

test "y_string_unicodeEscapedBackslash"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_unicodeEscapedBackslash.json");
}

test "y_string_unicode_2"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_unicode_2.json");
}

test "y_string_unicode_U+10FFFE_nonchar"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_unicode_U+10FFFE_nonchar.json");
}

test "y_string_unicode_U+1FFFE_nonchar"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_unicode_U+1FFFE_nonchar.json");
}

test "y_string_unicode_U+200B_ZERO_WIDTH_SPACE"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_unicode_U+200B_ZERO_WIDTH_SPACE.json");
}

test "y_string_unicode_U+2064_invisible_plus"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_unicode_U+2064_invisible_plus.json");
}

test "y_string_unicode_U+FDD0_nonchar"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_unicode_U+FDD0_nonchar.json");
}

test "y_string_unicode_U+FFFE_nonchar"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_unicode_U+FFFE_nonchar.json");
}

test "y_string_unicode_escaped_double_quote"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_unicode_escaped_double_quote.json");
}

test "y_string_utf8"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_utf8.json");
}

test "y_string_with_del_character"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_string_with_del_character.json");
}

test "y_structure_lonely_false"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_structure_lonely_false.json");
}

test "y_structure_lonely_int"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_structure_lonely_int.json");
}

test "y_structure_lonely_negative_real"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_structure_lonely_negative_real.json");
}

test "y_structure_lonely_null"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_structure_lonely_null.json");
}

test "y_structure_lonely_string"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_structure_lonely_string.json");
}

test "y_structure_lonely_true"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_structure_lonely_true.json");
}

test "y_structure_string_empty"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_structure_string_empty.json");
}

test "y_structure_trailing_newline"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_structure_trailing_newline.json");
}

test "y_structure_true_in_array"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_structure_true_in_array.json");
}

test "y_structure_whitespace_array"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = try parser.load(SIMDJSON_DATA ++ "/jsonchecker/minefield/y_structure_whitespace_array.json");
}

