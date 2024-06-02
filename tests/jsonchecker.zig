//! This file is auto-generated with `zig build test-jsonchecker`
const std = @import("std");
const DOM = @import("zimdjson").DOM;
const SIMDJSON_DATA = @embedFile("simdjson-data");

test "fail01_EXCLUDE"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail01_EXCLUDE.json") catch return;
  return error.MustHaveFailed;
}

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

test "fail18_EXCLUDE"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail18_EXCLUDE.json") catch return;
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

test "fail39_EXCLUDE"{
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  var parser = DOM.Parser.init(allocator);
  defer parser.deinit();
  _ = parser.load(SIMDJSON_DATA ++ "/jsonchecker/fail39_EXCLUDE.json") catch return;
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

