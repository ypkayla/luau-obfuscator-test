-- =========================================================================
-- LUAU VM OBFUSCATOR TEST SUITE  (self-checking)  --  Luau-safe edition
-- =========================================================================

local PASSED, FAILED = 0, 0
local FAILURES = {}
local SECTIONS = {}
local CURRENT_SECTION = "(none)"

local function fmt(v)
    if v == nil then return "nil" end
    if type(v) == "string" then return string.format("%q", v) end
    return tostring(v)
end

local function out(s) if io and io.write then io.write(s) end end

local function pass()
    PASSED += 1
    SECTIONS[CURRENT_SECTION].passed += 1
    out(".")
end

local function fail(name, got, expected)
    FAILED += 1
    SECTIONS[CURRENT_SECTION].failed += 1
    FAILURES[#FAILURES + 1] = { name = name, got = got, expected = expected, section = CURRENT_SECTION }
    out("F")
    print(("\n  [FAIL] %s\n         expected: %s\n         got:      %s")
        :format(name, fmt(expected), fmt(got)))
end

local function test(name, fn, expected)
    local ok, got = pcall(fn)
    if not ok then return fail(name, "ERROR: " .. tostring(got), expected) end
    if got ~= expected then return fail(name, got, expected) end
    pass()
end

local function section(title)
    CURRENT_SECTION = title
    SECTIONS[title] = { passed = 0, failed = 0 }
    print("\n-- " .. title .. " --")
end

-- =========================================================================
section("1. Literals")
-- =========================================================================
test("nil",                function() return nil end, nil)
test("true",               function() return true end, true)
test("false",              function() return false end, false)
test("int",                function() return 42 end, 42)
test("neg int",            function() return -17 end, -17)
test("float",              function() return 3.5 end, 3.5)
test("hex",                function() return 0xFF end, 255)
test("binary",             function() return 0b1010 end, 10)
test("scientific",         function() return 1e3 end, 1000)
test("neg exp",            function() return 1.5e-2 end, 0.015)
test("underscore num",     function() return 1_000_000 end, 1000000)
test("single quote",       function() return 'hi' end, "hi")
test("double quote",       function() return "hi" end, "hi")
test("long string",        function() return [[hi]] end, "hi")
test("long string lvl2",   function() return [==[a]]b]==] end, "a]]b")
test("escape \\n",         function() return "a\nb" end, "a\nb")
test("escape \\t",         function() return "a\tb" end, "a\tb")
test("escape quote",       function() return "a\"b" end, "a\"b")
test("escape backslash",   function() return "a\\b" end, "a\\b")
test("decimal escape",     function() return "\65" end, "A")
test("hex escape",         function() return "\x41" end, "A")

-- =========================================================================
section("2. Arithmetic")
-- =========================================================================
test("+",          function() return 2 + 3 end, 5)
test("-",          function() return 10 - 4 end, 6)
test("*",          function() return 6 * 7 end, 42)
test("/",          function() return 10 / 4 end, 2.5)
test("//",         function() return 10 // 4 end, 2)
test("%",          function() return 10 % 3 end, 1)
test("^",          function() return 2 ^ 10 end, 1024)
test("unary -",    function() return -5 end, -5)
test("precedence", function() return 1 + 2 * 3 end, 7)
test("parens",     function() return (1 + 2) * 3 end, 9)
test("float idiv", function() return 7.5 // 2 end, 3)
test("neg mod",    function() return -7 % 3 end, 2)

-- =========================================================================
section("3. Comparison & Logic")
-- =========================================================================
test("==",                function() return 1 == 1 end, true)
test("~=",                function() return 1 ~= 2 end, true)
test("<",                 function() return 1 < 2 end, true)
test("<=",                function() return 2 <= 2 end, true)
test(">",                 function() return 3 > 2 end, true)
test(">=",                function() return 2 >= 3 end, false)
test("and true",          function() return true and true end, true)
test("and false",         function() return true and false end, false)
test("or",                function() return false or true end, true)
test("not",               function() return not false end, true)
test("short-circ and",    function() return false and error("boom") end, false)
test("short-circ or",     function() return true or error("boom") end, true)
test("and value",         function() return 1 and 2 end, 2)
test("or value",          function() return nil or 5 end, 5)
test("ternary-style",     function() local x = 5 return x > 0 and "pos" or "neg" end, "pos")

-- =========================================================================
section("4. Strings & Length")
-- =========================================================================
test("concat",        function() return "a" .. "b" end, "ab")
test("concat num",    function() return "n=" .. 5 end, "n=5")
test("concat chain",  function() return "a" .. "b" .. "c" end, "abc")
test("len string",    function() return #"hello" end, 5)
test("len table",     function() return #{1, 2, 3} end, 3)
test("interp",        function() local n = "Luau" return `Hello, {n}!` end, "Hello, Luau!")
test("interp expr",   function() return `1+2={1 + 2}` end, "1+2=3")
test("interp nested", function() local x = 5 return `double={x * 2}` end, "double=10")

-- =========================================================================
section("5. Control Flow")
-- =========================================================================
test("if branch", function()
    if 5 > 0 then return "pos" else return "neg" end
end, "pos")

test("elseif", function()
    local function f(n)
        if n < 0 then return "neg"
        elseif n == 0 then return "zero"
        else return "pos" end
    end
    return f(-1) .. "," .. f(0) .. "," .. f(1)
end, "neg,zero,pos")

test("while", function()
    local i, s = 0, 0
    while i < 5 do s += i; i += 1 end
    return s
end, 10)

test("repeat", function()
    local i = 0
    repeat i += 1 until i >= 3
    return i
end, 3)

test("numeric for", function()
    local s = 0 for i = 1, 10 do s += i end return s
end, 55)

test("for step", function()
    local s = 0 for i = 0, 10, 2 do s += i end return s
end, 30)

test("for neg step", function()
    local s = "" for i = 3, 1, -1 do s = s .. i end return s
end, "321")

test("break", function()
    local n = 0
    for i = 1, 100 do
        if i > 5 then break end
        n = i
    end
    return n
end, 5)

test("continue", function()
    local s = 0
    for i = 1, 10 do
        if i % 2 == 0 then continue end
        s += i
    end
    return s
end, 25)

test("nested loops", function()
    local c = 0
    for _ = 1, 3 do for _ = 1, 3 do c += 1 end end
    return c
end, 9)

test("if-expr", function()
    local x = 5
    return if x > 0 then "pos" else "neg"
end, "pos")

test("nested if-expr", function()
    local x = 0
    return if x < 0 then "neg" elseif x == 0 then "zero" else "pos"
end, "zero")

-- =========================================================================
section("6. Functions")
-- =========================================================================
test("anon fn",       function() local f = function(x) return x * 2 end return f(21) end, 42)
test("named fn",      function() local function f(a, b) return a + b end return f(3, 4) end, 7)
test("multi returns", function() local function f() return 1, 2, 3 end return select("#", f()) end, 3)
test("multi assign",  function() local function f() return "a", "b" end local x, y = f() return x .. y end, "ab")
test("varargs count", function() local function f(...) return select("#", ...) end return f(1, 2, 3, 4) end, 4)
test("varargs table", function() local function f(...) return {...} end return #f("x", "y", "z") end, 3)
test("select n",      function() local function f(...) return select(3, ...) end return (f("a", "b", "c", "d")) end, "c")
test("select -1",     function() local function f(...) return select(-1, ...) end return f("a", "b", "last") end, "last")
test("closure",       function()
    local function counter() local n = 0 return function() n += 1; return n end end
    local c = counter(); c(); c()
    return c()
end, 3)
test("upvalue mut", function()
    local x = 0
    local function inc() x += 1 end
    inc(); inc(); inc()
    return x
end, 3)
test("factorial", function()
    local function fact(n) if n <= 1 then return 1 end return n * fact(n - 1) end
    return fact(5)
end, 120)
test("fib", function()
    local function fib(n) if n < 2 then return n end return fib(n - 1) + fib(n - 2) end
    return fib(10)
end, 55)
test("method syntax", function()
    local obj = { val = 10 }
    function obj:get() return self.val end
    return obj:get()
end, 10)
test("fn value", function()
    local fns = { function() return 1 end, function() return 2 end }
    return fns[1]() + fns[2]()
end, 3)
test("mutual recursion", function()
    local isEven, isOdd
    function isEven(n) if n == 0 then return true end return isOdd(n - 1) end
    function isOdd(n)  if n == 0 then return false end return isEven(n - 1) end
    return isEven(10) and isOdd(7)
end, true)

-- =========================================================================
section("7. Tables")
-- =========================================================================
test("array ctor",    function() local t = {1, 2, 3} return t[1] + t[2] + t[3] end, 6)
test("dict ctor",     function() local t = {a = 1, b = 2} return t.a + t.b end, 3)
test("mixed ctor",    function() local t = {1, 2, x = 3} return t[1] + t.x end, 4)
test("nested",        function() local t = {a = {b = {c = 7}}} return t.a.b.c end, 7)
test("dynamic index", function() local t = {} t["k"] = 5 return t.k end, 5)
test("computed key",  function() local k = "x" local t = {[k] = 9} return t.x end, 9)
test("len op",        function() return #{10, 20, 30, 40} end, 4)
test("t.insert",      function() local t = {1} table.insert(t, 2) return #t end, 2)
test("t.insert@",     function() local t = {1, 3} table.insert(t, 2, 99) return t[2] end, 99)
test("t.remove",      function() local t = {1, 2, 3} table.remove(t) return #t end, 2)
test("t.concat",      function() return table.concat({"a", "b", "c"}, "-") end, "a-b-c")
test("t.sort",        function() local t = {3, 1, 2} table.sort(t) return t[1] .. t[2] .. t[3] end, "123")
test("sort cmp",      function() local t = {3, 1, 2} table.sort(t, function(a, b) return a > b end) return t[1] .. t[2] .. t[3] end, "321")
test("t.unpack",      function() local a, b, c = table.unpack({1, 2, 3}) return a + b + c end, 6)
test("pairs count",   function()
    local n = 0
    for _ in pairs({a = 1, b = 2, c = 3}) do n += 1 end
    return n
end, 3)
test("ipairs order", function()
    local s = ""
    for _, v in ipairs({"x", "y", "z"}) do s = s .. v end
    return s
end, "xyz")
test("custom iterator", function()
    local function range(n)
        local i = 0
        return function() i += 1; if i <= n then return i end end
    end
    local s = 0
    for i in range(3) do s += i end
    return s
end, 6)

-- =========================================================================
section("8. Metatables")
-- =========================================================================
test("__index table",    function()
    local obj = setmetatable({}, { __index = { greet = "hi" } })
    return obj.greet
end, "hi")
test("__index fn",       function()
    local obj = setmetatable({}, { __index = function(_, k) return "auto:" .. k end })
    return obj.foo
end, "auto:foo")
test("__newindex",       function()
    local log = {}
    local obj = setmetatable({}, { __newindex = function(_, k, v) log[k] = v end })
    obj.x = 10
    return log.x
end, 10)
test("__add",    function()
    local mt = { __add = function(a, b) return a.v + b.v end }
    return setmetatable({v = 3}, mt) + setmetatable({v = 4}, mt)
end, 7)
test("__sub",    function()
    local mt = { __sub = function(a, b) return a.v - b.v end }
    return setmetatable({v = 10}, mt) - setmetatable({v = 3}, mt)
end, 7)
test("__mul",    function()
    local mt = { __mul = function(a, b) return a.v * b.v end }
    return setmetatable({v = 5}, mt) * setmetatable({v = 3}, mt)
end, 15)
test("__div",    function()
    local mt = { __div = function(a, b) return a.v / b.v end }
    return setmetatable({v = 10}, mt) / setmetatable({v = 2}, mt)
end, 5)
test("__mod",    function()
    local mt = { __mod = function(a, b) return a.v % b.v end }
    return setmetatable({v = 10}, mt) % setmetatable({v = 3}, mt)
end, 1)
test("__pow",    function()
    local mt = { __pow = function(a, b) return a.v ^ b.v end }
    return setmetatable({v = 2}, mt) ^ setmetatable({v = 10}, mt)
end, 1024)
test("__unm",    function()
    local mt = { __unm = function(a) return -a.v end }
    return -setmetatable({v = 5}, mt)
end, -5)
test("__concat", function()
    local mt = { __concat = function(a, b) return tostring(a.v) .. tostring(b.v) end }
    return setmetatable({v = "a"}, mt) .. setmetatable({v = "b"}, mt)
end, "ab")
test("__len",    function()
    return #setmetatable({}, { __len = function() return 99 end })
end, 99)
test("__call",   function()
    local f = setmetatable({}, { __call = function(_, x) return x * 2 end })
    return f(21)
end, 42)
test("__tostring", function()
    return tostring(setmetatable({}, { __tostring = function() return "CUSTOM" end }))
end, "CUSTOM")
test("__eq",     function()
    local mt = { __eq = function() return true end }
    return setmetatable({}, mt) == setmetatable({}, mt)
end, true)
test("__lt",     function()
    local mt = { __lt = function(a, b) return a.v < b.v end }
    return setmetatable({v = 1}, mt) < setmetatable({v = 2}, mt)
end, true)
test("__le",     function()
    local mt = { __le = function(a, b) return a.v <= b.v end }
    return setmetatable({v = 2}, mt) <= setmetatable({v = 2}, mt)
end, true)
test("__metatable", function()
    return getmetatable(setmetatable({}, { __metatable = "locked" }))
end, "locked")
test("getmetatable", function()
    local m = {}
    return getmetatable(setmetatable({}, m)) == m
end, true)
test("rawget/rawset", function()
    local obj = setmetatable({}, { __index = { x = 1 } })
    obj.y = 2
    return rawget(obj, "x") == nil and rawget(obj, "y") == 2
end, true)
test("rawequal", function()
    local t = {}
    return rawequal(t, t)
end, true)

-- =========================================================================
section("9. String Library")
-- =========================================================================
test("len",         function() return string.len("hello") end, 5)
test("upper",       function() return string.upper("abc") end, "ABC")
test("lower",       function() return string.lower("ABC") end, "abc")
test("sub",         function() return string.sub("hello", 2, 4) end, "ell")
test("sub neg",     function() return string.sub("hello", -3) end, "llo")
-- [FIXED] Luau does NOT support string.rep's 3rd (separator) argument.
test("rep",         function() return string.rep("ab", 3) end, "ababab")
test("reverse",     function() return string.reverse("abc") end, "cba")
test("byte",        function() return string.byte("A") end, 65)
test("char",        function() return string.char(72, 105) end, "Hi")
test("find",        function() return (string.find("hello world", "world")) end, 7)
test("find plain",  function() return (string.find("a.b", ".", 1, true)) end, 2)
test("match",       function() return string.match("key=value", "(%w+)=(%w+)") end, "key")
test("gmatch",      function()
    local n = 0
    for _ in string.gmatch("a,b,c,d", "[^,]+") do n += 1 end
    return n
end, 4)
test("gsub",        function() return (string.gsub("hello", "l", "L")) end, "heLLo")
test("format",      function() return string.format("%d-%s-%.2f", 42, "x", 3.14159) end, "42-x-3.14")
test("format hex",  function() return string.format("%x", 255) end, "ff")

-- =========================================================================
section("10. Math")
-- =========================================================================
test("abs",   function() return math.abs(-5) end, 5)
test("ceil",  function() return math.ceil(3.1) end, 4)
test("floor", function() return math.floor(3.9) end, 3)
test("max",   function() return math.max(1, 5, 2) end, 5)
test("min",   function() return math.min(1, 5, 2) end, 1)
test("sqrt",  function() return math.sqrt(16) end, 4)
test("pow",   function() return math.pow(2, 8) end, 256)
test("huge",  function() return math.huge > 1e300 end, true)
test("pi",    function() return math.pi > 3.14 and math.pi < 3.15 end, true)
test("rand",  function() return type(math.random(1, 10)) end, "number")
test("fmod",  function() return math.fmod(10, 3) end, 1)
test("exp",   function() return math.exp(0) end, 1)
test("log",   function() return math.log(1) end, 0)

-- =========================================================================
section("11. Bit32")
-- =========================================================================
test("band",   function() return bit32.band(0xF0, 0x0F) end, 0)
test("bor",    function() return bit32.bor(0xF0, 0x0F) end, 0xFF)
test("bxor",   function() return bit32.bxor(0xFF, 0x0F) end, 0xF0)
test("bnot",   function() return bit32.bnot(0) end, 0xFFFFFFFF)
test("lshift", function() return bit32.lshift(1, 4) end, 16)
test("rshift", function() return bit32.rshift(16, 4) end, 1)

-- =========================================================================
section("12. Error Handling")
-- =========================================================================
test("pcall ok",   function() return (pcall(function() return 42 end)) end, true)
test("pcall fail", function() return (pcall(function() error("boom") end)) end, false)
test("pcall msg",  function()
    local ok, err = pcall(function() error("boom") end)
    return ok == false and string.find(err, "boom") ~= nil
end, true)
test("pcall vals", function()
    local ok, a, b = pcall(function() return 1, 2 end)
    return ok and a == 1 and b == 2
end, true)
test("error table", function()
    local ok, err = pcall(function() error({ code = 42 }) end)
    return ok == false and type(err) == "table" and err.code == 42
end, true)
test("error lvl0", function()
    local ok, err = pcall(function() error("x", 0) end)
    return ok == false and err == "x"
end, true)
test("xpcall", function()
    local ok, err = xpcall(function() error("x", 0) end, function(e) return "handled:" .. e end)
    return ok == false and err == "handled:x"
end, true)
test("assert pass", function() return (pcall(function() assert(true) end)) end, true)
test("assert fail", function() return (pcall(function() assert(false, "msg") end)) end, false)
test("nested pcall", function()
    local ok = pcall(function()
        pcall(function() error("inner") end)
        error("outer")
    end)
    return ok
end, false)

-- =========================================================================
section("13. Types")
-- =========================================================================
test("type nil",      function() return type(nil) end, "nil")
test("type num",      function() return type(1) end, "number")
test("type str",      function() return type("s") end, "string")
test("type bool",     function() return type(true) end, "boolean")
test("type tbl",      function() return type({}) end, "table")
test("type fn",       function() return type(print) end, "function")
test("typeof tbl",    function() return typeof({}) end, "table")
test("typeof num",    function() return typeof(1) end, "number")
test("tostring",      function() return tostring(42) end, "42")
test("tonumber",      function() return tonumber("42") end, 42)
test("tonumber base", function() return tonumber("ff", 16) end, 255)
test("tonumber bad",  function() return tonumber("xyz") end, nil)

-- =========================================================================
section("14. Coroutines")
-- =========================================================================
test("resume/yield", function()
    local co = coroutine.create(function(a, b)
        local c = coroutine.yield(a + b)
        return c * 2
    end)
    local ok1, v1 = coroutine.resume(co, 3, 4)
    local ok2, v2 = coroutine.resume(co, 10)
    return ok1 and ok2 and v1 == 7 and v2 == 20
end, true)

test("status", function()
    local co = coroutine.create(function() coroutine.yield() end)
    local s1 = coroutine.status(co)
    coroutine.resume(co)
    local s2 = coroutine.status(co)
    coroutine.resume(co)
    local s3 = coroutine.status(co)
    return s1 .. "|" .. s2 .. "|" .. s3
end, "suspended|suspended|dead")

test("wrap", function()
    local f = coroutine.wrap(function(a)
        coroutine.yield(a + 1)
        coroutine.yield(a + 2)
        return a + 3
    end)
    return f(10) + f(10) + f(10)
end, 11 + 12 + 13)

-- [FIXED] Behaviour of coroutine.running() varies by Luau build.
-- We only require it to be callable and to return nil or a thread.
test("running callable", function()
    return pcall(coroutine.running)
end, true)

test("running from main", function()
    local r = coroutine.running()
    return r == nil or type(r) == "thread"
end, true)

test("running inside co", function()
    local co = coroutine.create(function()
        return coroutine.running()
    end)
    local ok, r = coroutine.resume(co)
    return ok and (r == nil or type(r) == "thread")
end, true)

-- =========================================================================
section("15. Compound Assignment (Luau)")
-- =========================================================================
test("+=",  function() local x = 5 x += 3 return x end, 8)
test("-=",  function() local x = 5 x -= 3 return x end, 2)
test("*=",  function() local x = 5 x *= 3 return x end, 15)
test("/=",  function() local x = 6 x /= 2 return x end, 3)
test("//=", function() local x = 7 x //= 2 return x end, 3)
test("%=",  function() local x = 7 x %= 3 return x end, 1)
test("^=",  function() local x = 2 x ^= 5 return x end, 32)
test("..=", function() local x = "a" x ..= "b" return x end, "ab")

-- =========================================================================
section("16. Multiple Assignment")
-- =========================================================================
test("swap", function()
    local a, b = 1, 2
    a, b = b, a
    return a * 10 + b
end, 21)
test("partial fill", function()
    local a, b, c = 0, 0, 0
    a, b = 5, 6
    return a + b + c
end, 11)
test("drop extra", function()
    local function f() return 1, 2, 3 end
    local a, b = f()
    return a + b
end, 3)
test("nil fill", function()
    local a, b, c = 1, nil, 3
    return tostring(b) .. c
end, "nil3")

-- =========================================================================
-- SUMMARY
-- =========================================================================
print("")
print(string.rep("=", 64))
print("  LUAU OBFUSCATOR TEST SUMMARY")
print(string.rep("=", 64))

local names = {}
for name in pairs(SECTIONS) do names[#names + 1] = name end
table.sort(names)

for _, name in ipairs(names) do
    local s = SECTIONS[name]
    local status = s.failed == 0 and "OK  " or "FAIL"
    print(string.format("  [%s] %-42s %3d pass / %d fail", status, name, s.passed, s.failed))
end

print(string.rep("-", 64))
print(string.format("  TOTAL:  %d passed, %d failed, %d ran",
    PASSED, FAILED, PASSED + FAILED))
print(string.rep("=", 64))

if FAILED > 0 then
    print("\nFAILURE DETAILS:\n")
    for i, f in ipairs(FAILURES) do
        print(string.format("  %2d) [%s] %s", i, f.section, f.name))
        print(string.format("      expected: %s", fmt(f.expected)))
        print(string.format("      got:      %s", fmt(f.got)))
    end
    print("")
    print(string.rep("=", 64))
    print(string.format("  RESULT: %d TEST(S) FAILED  --  obfuscator is BROKEN", FAILED))
    print(string.rep("=", 64))
else
    print("")
    print(string.rep("=", 64))
    print("  RESULT: ALL TESTS PASSED  --  obfuscator looks good")
    print(string.rep("=", 64))
end
