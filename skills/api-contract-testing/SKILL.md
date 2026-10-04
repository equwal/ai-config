---
name: api-contract-testing
description: Property-based testing of HTTP APIs against an OpenAPI or GraphQL specification using Schemathesis. Use when the project has an openapi.json, openapi.yaml, swagger.json, or an auto-generated spec (FastAPI /openapi.json, Django REST, Go/Java annotation-based specs); when adding or modifying an HTTP endpoint; when the spec and implementation may have drifted; or when a client reports a response shape the docs do not describe.
---

# API contract testing

Schemathesis reads an OpenAPI spec, generates requests from the declared
schemas, and checks that responses conform. It finds the two failure modes
example tests never catch: inputs nobody thought to try, and drift between the
spec and the implementation.

## Preflight

```bash
command -v schemathesis || uvx schemathesis --help
schemathesis --version
```

The CLI has changed across major versions (option names and defaults differ
between v3 and v4). **Run `schemathesis run --help` and use what that reports**
rather than relying on remembered flags. Report the version in the output.

Install: `uv tool install schemathesis`, or run ad hoc with `uvx schemathesis`.

## Locating the spec

```bash
fd -e json -e yaml . | rg -i 'openapi|swagger'
curl -s localhost:8000/openapi.json | head -c 200      # FastAPI, Litestar
curl -s localhost:8080/v3/api-docs | head -c 200       # springdoc
```

If the spec is generated at runtime, point Schemathesis at the live URL so it
always tests the current contract. A stale checked-in spec tests nothing useful.

## Baseline run

Start the service, then:

```bash
schemathesis run http://localhost:8000/openapi.json --url http://localhost:8000
```

Default checks cover: undocumented status codes, response bodies that violate
the declared schema, wrong content types, malformed headers, and server errors
(any 500 is a failure). Consult `--help` for the current check list and for how
to select or exclude individual checks.

Useful controls (verify names against `--help`):

- Limit scope while iterating: filter by path or method rather than running the
  whole surface on every change.
- `--max-examples` — raise for a thorough run, lower for a fast inner loop.
- Authentication: `-H "Authorization: Bearer $TOKEN"`, or `--auth user:pass`.
- `--report` / cassette output — records failing interactions for replay.

## Interpreting failures

Schemathesis reports a minimised failing case plus a `curl` command that
reproduces it. Triage into three buckets — the classification matters more than
the fix:

1. **The implementation is wrong.** Fix the code. Add the minimised case as a
   unit test first, and show it failing.
2. **The spec is wrong.** Fix the spec. This is common and valuable: the spec is
   what clients and codegen consume, so a wrong spec is a live bug even when the
   server behaves correctly. Do not loosen the spec merely to silence a failure
   — that discards the signal.
3. **The generated input is genuinely invalid** and the spec failed to say so.
   Tighten the schema (`minLength`, `pattern`, `format`, `enum`, `minimum`).
   This is the best outcome: the spec becomes more precise, and downstream
   codegen and validation improve for free.

A 500 on any generated input is always bucket 1. Malformed input must produce a
4xx, never an unhandled exception.

## Stateful testing

Schemathesis can chain requests using OpenAPI `links` to test sequences
(create → read → update → delete), catching bugs that single-request tests miss.
This requires `links` to be declared in the spec. Check current syntax with
`--help`; if links are absent, adding them improves both the docs and the tests.

## In the test suite

Prefer running Schemathesis in-process against the ASGI/WSGI app rather than
over the network — faster, no port juggling, works in CI without a service
container. The Python API for this has changed between major versions; consult
the installed version's documentation rather than assuming the decorator name.

Whichever form is used, drive it against the app object, seed any required auth
via fixtures, and commit every discovered failing case as an ordinary example
test so it stays covered after the fuzzing budget moves on.

## CI

Run a bounded pass on every PR (low `--max-examples`, fail on any error) and a
longer scheduled run nightly. Treat spec changes as API changes: if a PR alters
the spec, say so in the summary, and check whether the change is
backwards-compatible for existing clients.

## Not an OpenAPI project?

- GraphQL: Schemathesis supports GraphQL schemas directly.
- gRPC/protobuf: use `buf breaking` for compatibility checks plus property
  tests over the generated types.
- No spec at all: consider whether one is warranted. If the API is internal and
  small, plain property tests over the handler functions are cheaper and give
  most of the benefit.
