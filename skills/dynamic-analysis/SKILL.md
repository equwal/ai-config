---
name: dynamic-analysis
description: Find memory errors, undefined behaviour, data races, and parser crashes using sanitizers (ASan, UBSan, TSan, MSan, Miri) and coverage-guided fuzzing (libFuzzer, cargo-fuzz, Go native fuzzing, AFL++). Use when working in C, C++, Rust unsafe, Go, or Zig; when writing or modifying code that parses untrusted input; when debugging a segfault, heap corruption, use-after-free, flaky crash, or suspected data race; or when adding a new parser, decoder, deserialiser, or protocol handler.
---

# Dynamic analysis

Static analysis proves absence of some bugs. Sanitizers and fuzzing find the
bugs that are actually there. If the code parses input you did not generate,
this is not optional.

## Preflight

Check availability before writing anything; report clearly if missing.

```bash
clang --version; command -v cargo-fuzz; go version; command -v afl-fuzz
rustup component list --toolchain nightly 2>/dev/null | grep -i miri
```

Sanitizers ship with clang and gcc. libFuzzer ships with clang. `cargo-fuzz`
needs `cargo install cargo-fuzz` and a nightly toolchain. Go fuzzing is built
into `go test`.

## Sanitizers

Rebuild with instrumentation and run the existing test suite. This alone finds
real bugs in most untested C/C++ codebases.

```bash
# ASan + UBSan together — the default pairing
clang -fsanitize=address,undefined -fno-omit-frame-pointer \
      -fno-sanitize-recover=all -g -O1 ...
```

`-fno-sanitize-recover=all` makes UBSan abort instead of printing and
continuing. Without it, UBSan findings scroll past in CI and get ignored.

**ASan and TSan cannot be combined.** They use incompatible shadow memory
layouts. Use separate build directories:

```bash
cmake -B build-asan -DCMAKE_C_FLAGS="-fsanitize=address,undefined -g -O1"
cmake -B build-tsan -DCMAKE_C_FLAGS="-fsanitize=thread -g -O1"
```

| Sanitizer | Flag | Finds | Slowdown |
|---|---|---|---|
| ASan | `-fsanitize=address` | use-after-free, buffer overflow, double free, leaks | ~2x |
| UBSan | `-fsanitize=undefined` | signed overflow, misaligned access, invalid shifts, bad casts | ~1.2x |
| TSan | `-fsanitize=thread` | data races, lock-order inversion | ~5–15x |
| MSan | `-fsanitize=memory` | reads of uninitialised memory | ~3x |

MSan requires **every** linked library to be instrumented, including libc++.
Uninstrumented dependencies produce false positives. Skip it unless the whole
dependency tree can be rebuilt.

Useful runtime options:

```bash
export ASAN_OPTIONS=detect_leaks=1:abort_on_error=1:strict_string_checks=1
export UBSAN_OPTIONS=print_stacktrace=1:halt_on_error=1
export TSAN_OPTIONS=halt_on_error=1:second_deadlock_stack=1
```

Other languages:

- **Rust**: `cargo +nightly miri test` for UB in `unsafe` blocks. Sanitizers via
  `RUSTFLAGS="-Zsanitizer=address" cargo +nightly test`.
- **Go**: `go test -race ./...` — cheap, run it by default in CI.

TSan and the Go race detector only find races on code paths that actually
execute concurrently during the run. A clean run is weak evidence. Run the
concurrent tests repeatedly (`go test -race -count=50 -run TestConcurrent`).

## Fuzzing

Fuzz any function that takes bytes, a string, or a file from outside the
process. Target the parse/decode boundary, not the whole application.

### libFuzzer (C/C++)

```c
// fuzz/fuzz_parse.c
#include <stdint.h>
#include <stddef.h>
#include "parser.h"

int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    if (size > 64 * 1024) return -1;       // reject oversized inputs
    parser_ctx *ctx = parser_new();
    parser_feed(ctx, data, size);          // must not crash on any input
    parser_free(ctx);                      // ASan catches leaks here
    return 0;
}
```

```bash
clang -fsanitize=fuzzer,address,undefined -fno-sanitize-recover=all \
      -g -O1 fuzz/fuzz_parse.c parser.c -o fuzz_parse

mkdir -p corpus
./fuzz_parse corpus/ -max_total_time=120 -print_final_stats=1
```

Useful flags: `-jobs=$(nproc)` for parallel runs, `-max_len=` to bound input
size, `-dict=file.dict` to supply format keywords, `-runs=N` for a bounded
deterministic run in CI.

### cargo-fuzz (Rust)

```bash
cargo fuzz init
cargo fuzz add parse_target
cargo fuzz run parse_target -- -max_total_time=120
```

```rust
// fuzz_targets/parse_target.rs
#![no_main]
use libfuzzer_sys::fuzz_target;

fuzz_target!(|data: &[u8]| {
    let _ = my_crate::parse(data);   // must not panic
});
```

For structured input, use the `arbitrary` crate:
`fuzz_target!(|input: MyStruct| { ... })`.

### Go native fuzzing

```go
func FuzzParse(f *testing.F) {
    f.Add([]byte(`{"a":1}`))              // seed corpus
    f.Fuzz(func(t *testing.T, data []byte) {
        v, err := Parse(data)
        if err != nil {
            return                         // errors are fine; panics are not
        }
        out, err := Marshal(v)             // round-trip property
        if err != nil {
            t.Fatalf("marshal failed on parsed input: %v", err)
        }
        if v2, _ := Parse(out); !reflect.DeepEqual(v, v2) {
            t.Fatalf("round trip mismatch")
        }
    })
}
```

```bash
go test -fuzz=FuzzParse -fuzztime=120s ./pkg/parser
```

Failing inputs are written to `testdata/fuzz/FuzzParse/` and **become
permanent regression tests** on subsequent `go test` runs. Commit them.

### Seed corpus

Fuzzing without seeds wastes most of its budget rediscovering valid syntax.
Seed from existing test fixtures:

```bash
mkdir -p corpus && cp tests/fixtures/*.json corpus/
```

Minimise the corpus periodically: `./fuzz_target -merge=1 corpus_min/ corpus/`.

## Triage of a crash

1. **Reproduce deterministically**: `./fuzz_parse crash-<sha1>` — libFuzzer
   writes the failing input to a `crash-*` file in the working directory.
   Go writes to `testdata/fuzz/`.
2. **Minimise**: `./fuzz_parse -minimize_crash=1 -runs=10000 crash-<sha1>`.
   Go: `go test -run=FuzzParse/<hash>`.
3. **Commit the minimised input as a unit test before fixing.** It must fail
   on unfixed code — show that run.
4. Read the sanitizer stack trace to identify the mechanism. ASan reports both
   the faulting access and the allocation/free sites; all three matter.
5. Fix, then re-run the fuzzer for at least the original duration to confirm
   the crash is gone and no new one surfaced.

## CI integration

Fuzzing in CI is a bounded regression run, not a discovery campaign:

```bash
./fuzz_parse corpus/ -runs=100000 -max_total_time=60
go test -fuzz=FuzzParse -fuzztime=60s ./...
```

Long campaigns belong on a schedule (nightly, hours) or on OSS-Fuzz, which is
free for open-source projects and runs continuously. Always run the committed
corpus as plain tests on every PR — that is the regression suite.
