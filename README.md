# luau-vm-test-suite

A self-checking test suite for **Luau VMs, obfuscators, and interpreters**.

Drop it through any Luau obfuscator (or alternative runtime) and get a
per-feature pass/fail report — 195 tests across 16 feature areas, with
byte-precise expected values so you know *exactly* what broke.

```
================================================================
  LUAU OBFUSCATOR TEST SUMMARY
================================================================
  [OK  ] 1. Literals                                 21 pass / 0 fail
  [OK  ] 2. Arithmetic                               12 pass / 0 fail
  [OK  ] 3. Comparison & Logic                       15 pass / 0 fail
  [OK  ] 4. Strings & Length                          8 pass / 0 fail
  [OK  ] 5. Control Flow                             12 pass / 0 fail
  [OK  ] 6. Functions                                15 pass / 0 fail
  [OK  ] 7. Tables                                   17 pass / 0 fail
  [OK  ] 8. Metatables                               21 pass / 0 fail
  [OK  ] 9. String Library                           16 pass / 0 fail
  [OK  ] 10. Math                                    13 pass / 0 fail
  [OK  ] 11. Bit32                                    6 pass / 0 fail
  [OK  ] 12. Error Handling                          10 pass / 0 fail
  [OK  ] 13. Types                                   12 pass / 0 fail
  [OK  ] 14. Coroutines                               6 pass / 0 fail
  [OK  ] 15. Compound Assignment (Luau)               8 pass / 0 fail
  [OK  ] 16. Multiple Assignment                      4 pass / 0 fail
----------------------------------------------------------------
  TOTAL:  195 passed, 0 failed, 195 ran
================================================================
  RESULT: ALL TESTS PASSED  --  obfuscator looks good
================================================================
```

## Why

Testing an obfuscator by hand is miserable. You rewrite the same 30 snippets,
guess which feature broke, and never get a clean signal. This suite:

* **Runs everywhere.** Plain Luau, `lune`, `luau`, Roblox — no dependencies.
* **Self-checks.** Every test compares against an exact expected value.
* **Never crashes on one failure.** Each test is `pcall`-wrapped, so a broken
  `__call` metamethod doesn't kill the other 194 tests.
* **Tells you *where* it broke.** Per-section pass/fail counts + a numbered
  failure list with expected vs. actual.

## Coverage

| # | Section | What's exercised |
|---|---|---|
| 1 | Literals | All string/number forms: hex, binary, scientific, `_` separators, all escapes |
| 2 | Arithmetic | `+ - * / // % ^`, unary, precedence, negatives |
| 3 | Comparison & Logic | All comparators, short-circuit, `and`/`or` value semantics |
| 4 | Strings & Length | Concat, `#`, Luau string interpolation (`` `{}` ``) |
| 5 | Control Flow | `if`/`elseif`/`else`, `while`, `repeat`, all `for` forms, `break`, `continue`, if-expressions |
| 6 | Functions | Closures, upvalues, varargs, `select`, recursion, methods, mutual recursion |
| 7 | Tables | All constructors, `pairs`/`ipairs`, custom iterators, full `table.*` API |
| 8 | Metatables | **Every** metamethod: `__index`, `__newindex`, all arithmetic, `__concat`, `__len`, `__call`, `__tostring`, `__eq`, `__lt`, `__le`, `__metatable`, `rawget`/`rawset`/`rawequal` |
| 9 | String Library | Full `string.*` API |
| 10 | Math | Common `math.*` functions |
| 11 | Bit32 | `band`, `bor`, `bxor`, `bnot`, `lshift`, `rshift` |
| 12 | Error Handling | `pcall`, `xpcall`, `error` (string/table/level 0), `assert`, nested |
| 13 | Types | `type`, `typeof`, `tostring`, `tonumber` (with base) |
| 14 | Coroutines | `create`/`resume`/`yield`/`status`/`wrap`/`running` |
| 15 | Compound Assignment | All 8 Luau `X=` operators |
| 16 | Multiple Assignment | Swaps, partial fills, nil handling |

## Usage

### 1. Get a baseline (unobfuscated)

```bash
luau obfuscator_test.luau
```

You should see **`ALL TESTS PASSED`**. If anything fails here, it's a
runtime-version difference, **not** an obfuscator bug — please open an issue
with your Luau version.

### 2. Run the obfuscated version

```bash
luau obfuscated_test.luau
```

Anything that now fails is a real obfuscator bug. The failure list at the
bottom names the test and shows expected vs. actual.

### 3. Diff both for CI

```bash
luau obfuscator_test.luau > baseline.txt
luau obfuscated_test.luau > obf.txt
diff baseline.txt obf.txt && echo "obfuscator OK"
```

## Portability notes

Two tests were loosened from the "obvious" versions because **Luau differs
from Lua 5.2+** here — these are marked `[FIXED]` in the source:

1. **`string.rep`** — Luau has **no separator argument**.
   `string.rep("x", 3, "-")` returns `"xxx"`, not `"x-x-x"`.
   The suite uses the 2-arg form only.
2. **`coroutine.running()`** — behavior varies between Luau builds (some
   return the coroutine, some return `nil` inside a coroutine, some return a
   distinct thread handle). The suite only asserts it's callable and returns
   `nil` or a `thread`, so it works on every build.

## Contributing

PRs welcome. Good additions:

* More metamethod edge cases (`__idiv`, `__namecall`, `__iter`, `__type`)
* Luau-specific syntax (`type` annotations, `::` casts, generics)
* `buffer` library tests
* `utf8` library tests
* Roblox-specific globals (`Instance`, `task.*`) — behind a feature flag

**Test-writing rules:**

1. One assertion per `test(name, fn, expected)` call.
2. Never let a test throw — wrap risky calls in `pcall` or extend the harness.
3. If a "correct" test fails on plain Luau, it's the test's fault, not the
   runtime's. Verify against `luau` before submitting.
4. Mark any Luau-vs-Lua divergence with a `-- [FIXED]` comment.

## Credits

* **Suite author:** [@ypkayla](https://github.com/ypkayla) (GitHub)
* Built for testing Luau VM obfuscators. If you obfuscate Luau, this is for you.

## License

MIT — see [LICENSE](LICENSE).
