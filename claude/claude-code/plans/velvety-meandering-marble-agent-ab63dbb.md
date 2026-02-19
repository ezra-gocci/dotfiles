# Plan: Update FastForward Documentation -- EntryPoint from Go/GoFr to Rust

## Overview

Move all documentation references for the EntryPoint (Gateway) workload from Go/GoFr to Rust. EntryPoint stays at `services/core/entrypoint/`. Shield stays Go. Engine workloads (Auth, Normalizer, Coordinator, Resolver, Routing) stay Go/GoFr. EntryPoint uses Rust-native resilience (tower middleware) instead of Shield's Go library.

---

## 1. The Rust Stack for EntryPoint

EntryPoint is an **orchestrator**, not a web server. It receives protobuf envelopes from ingress adapters via gRPC, calls engine workloads via gRPC, dispatches commands to RabbitMQ, fires event hooks to Kafka, and checks Redis for rate limiting. It may optionally expose health/metrics HTTP endpoints.

### Runtime & Async
- **tokio** -- async runtime (same as ingress adapters)

### gRPC
- **tonic** -- gRPC server (receives from adapters) and client (calls engine workloads)
- **prost** -- protobuf serialization

### Messaging
- **lapin** -- RabbitMQ client (AMQP 0-9-1) for command dispatch
- **rdkafka** (rust-rdkafka) -- Kafka producer for event hooks

### Data
- **redis** (redis-rs) -- Redis client for rate limiting, session checks, distributed locks

### Resilience (replaces Shield's Go library)
- **tower** -- middleware framework: timeout, rate limit, concurrency limit (bulkhead), retry
- **tower-http** -- HTTP-specific middleware (for health/metrics endpoints only)

### HTTP (minimal, health/metrics only)
- **axum** -- lightweight HTTP server for `/health`, `/ready`, `/metrics` endpoints only

### Observability
- **tracing** -- structured logging and span instrumentation
- **tracing-subscriber** -- log formatting and export
- **opentelemetry** + **opentelemetry-otlp** -- metrics and trace export to LGTM stack
- **tracing-opentelemetry** -- bridge between tracing crate and OpenTelemetry

### Serialization
- **serde** + **serde_json** -- for configuration, health responses, non-protobuf serialization

### Dev Dependencies
- **clippy** -- linting
- **rustfmt** -- formatting
- **cargo-audit** -- vulnerability scanning

### Summary Label for Tables
**Stack:** `Rust / tokio, tonic, tower`
**Full libraries line:** `tokio, tonic, prost, tower, lapin, rdkafka, redis, axum (health only), tracing, serde`

---

## 2. Taxonomy & Grouping Decisions

### Key Decision: Split "Core services" into "Gateway" and "Engine"

The current tables have a single "Core services" row covering all Go workloads. With EntryPoint moving to Rust, the cleanest approach is:

- **Gateway workload** gets its own row in tech stack tables: `Rust, tokio, tonic, tower, gRPC, Protocol Buffers, buf`
- **Engine workloads** row remains: `Go, GoFr, gRPC, Protocol Buffers, buf`
- The term "Core services" is retired from the summary table and replaced with the two specific rows

This avoids the awkward "Core services = Go + Rust" phrasing and reflects the architectural separation that already exists in the component taxonomy (Gateway vs Engine are distinct subtypes).

### Workload Count Changes
- Current: "Seven core engine workloads are written in Go" -- this was always slightly imprecise (EntryPoint is Gateway subtype, not Engine subtype)
- New: "Six engine workloads are written in Go" (Auth, Normalizer, Shield, Coordinator, Resolver, Routing) + "The gateway workload (EntryPoint) is written in Rust"
- Total Rust workloads: 5 (4 adapters + 1 gateway)
- Total Go workloads: 6 (engine only)

### Shield Interaction
- Shield remains a Go/GoFr workload providing resilience as a library for Go engine workloads
- EntryPoint no longer consumes Shield's Go library
- EntryPoint implements equivalent resilience using tower middleware natively in Rust: `tower::timeout::Timeout`, `tower::limit::ConcurrencyLimit` (bulkhead), `tower::retry::Retry`, plus custom circuit breaker middleware
- Shield's documentation must clarify it serves engine workloads and other Go callers; EntryPoint uses Rust-native equivalents

---

## 3. File-by-File Edit Plan

---

### File 1: `/Users/Ezra/Code/FastForward/README.md`

#### Edit 1A -- Services table, EntryPoint row (line 36)

**Old:**
```
| **EntryPoint** | Go / GoFr | Gateway orchestrator — runs the processing pipeline, dispatches to domain workloads, fires event hooks |
```

**New:**
```
| **EntryPoint** | Rust / tokio, tonic, tower | Gateway orchestrator — runs the processing pipeline, dispatches to domain workloads, fires event hooks |
```

#### Edit 1B -- Tech stack table, replace "Core services" row (line 71)

**Old:**
```
| **Core services** | Go, GoFr, gRPC, Protocol Buffers, buf |
```

**New:**
```
| **Gateway workload** | Rust, tokio, tonic, tower, gRPC, Protocol Buffers, buf |
| **Engine workloads** | Go, GoFr, gRPC, Protocol Buffers, buf |
```

---

### File 2: `/Users/Ezra/Code/FastForward/docs/project/architecture/overview.md`

#### Edit 2A -- Workloads table, Gateway row (line 102)

**Old:**
```
| **Gateway** | EntryPoint | Go / GoFr |
```

**New:**
```
| **Gateway** | EntryPoint | Rust / tokio, tonic, tower |
```

Note: Line 103 (Engine row) stays unchanged -- it already says `Go / GoFr` and lists the correct workloads.

#### Edit 2B -- Language Stacks section, Go paragraph (line 112)

**Old:**
```
**Go** for core engine workloads — fast compilation, low memory, built-in concurrency via goroutines, and single-binary deployment. GoFr provides batteries-included HTTP/gRPC serving, database drivers, middleware, and pub/sub. The engine workloads are I/O-bound (gRPC calls between pipeline stages), not CPU-bound.
```

**New:**
```
**Rust** for the gateway workload (EntryPoint) — the pipeline orchestrator demands top-level performance and reliability. Rust's ownership model eliminates garbage collection pauses. tokio provides the async runtime, tonic handles gRPC communication with both ingress adapters and engine workloads, and tower middleware provides Rust-native resilience (timeouts, concurrency limits, retry, circuit breaking) without depending on Shield's Go library. lapin and rdkafka handle RabbitMQ command dispatch and Kafka event hooks respectively.

**Go** for engine workloads (Auth, Normalizer, Shield, Coordinator, Resolver, Routing) — fast compilation, low memory, built-in concurrency via goroutines, and single-binary deployment. GoFr provides batteries-included HTTP/gRPC serving, database drivers, middleware, and pub/sub. The engine workloads are I/O-bound (gRPC calls between pipeline stages), not CPU-bound.
```

Note: The existing Rust paragraph (for ingress adapters) and Python paragraph remain unchanged.

#### Edit 2C -- Shield description in Pipeline section (line 92)

**Old:**
```
**Shield** is not a pipeline stage — it is a cross-cutting resilience layer that wraps every hop. Circuit breakers (gobreaker) fail fast when a target is unhealthy. Exponential backoff with jitter (failsafe-go) prevents retry storms. Bulkhead isolation gives each target its own resource pool. Context-based timeouts cascade from the request-level deadline down to each individual call.
```

**New:**
```
**Shield** is not a pipeline stage — it is a cross-cutting resilience layer that wraps every hop. For Go engine workloads, Shield provides circuit breakers (gobreaker), exponential backoff with jitter (failsafe-go), bulkhead isolation, and context-based timeouts as a shared library. EntryPoint implements equivalent resilience natively in Rust via tower middleware — timeouts, concurrency limits, retry, and circuit breaking — without depending on Shield's Go library. The net effect is the same: every hop is protected regardless of language stack.
```

---

### File 3: `/Users/Ezra/Code/FastForward/docs/project/architecture/full-reference.md`

#### Edit 3A -- Gateway workload table (line 71)

**Old:**
```
| **EntryPoint** | Go / GoFr | The front door. Orchestrates the processing pipeline, chains to specialized engine workloads for each stage, dispatches to domain workloads, and fires hooks for subscribed observers. Owns Admission Control and Dispatch stages directly. |
```

**New:**
```
| **EntryPoint** | Rust / tokio, tonic, tower | The front door. Orchestrates the processing pipeline, chains to specialized engine workloads for each stage via gRPC (tonic), dispatches commands to domain workloads via RabbitMQ (lapin), fires event hooks via Kafka (rdkafka), and checks Redis (redis-rs) for rate limiting. Owns Admission Control and Dispatch stages directly. Implements Rust-native resilience via tower middleware instead of Shield's Go library. |
```

Note: Engine workloads table (lines 77-82) stays unchanged -- all still Go/GoFr.

#### Edit 3B -- Shield section (line 314)

**Old:**
```
Shield is not a pipeline stage — it is a resilience layer that wraps every hop between stages. Every call, inbound or outbound or internal, runs inside Shield's protection. Shield is a dedicated Go/GoFr workload at `services/core/shield/` that provides a library used by EntryPoint and every other workload that makes inter-service calls.
```

**New:**
```
Shield is not a pipeline stage — it is a resilience layer that wraps every hop between stages. Every call, inbound or outbound or internal, runs inside resilience protection. Shield is a dedicated Go/GoFr workload at `services/core/shield/` that provides a library used by Go engine workloads (Auth, Normalizer, Coordinator, Resolver, Routing) for inter-service calls. EntryPoint, written in Rust, implements equivalent resilience natively via tower middleware — tower timeouts, concurrency limits (bulkhead), retry with backoff, and a circuit breaker layer — without depending on Shield's Go library. The resilience guarantees are identical across both stacks; only the implementation differs.
```

#### Edit 3C -- Shield: Bulkhead Isolation paragraph (line 320)

**Old:**
```
**Bulkhead Isolation.** Isolated resource pools (goroutine pools, connection pools) per target workload. If Normalizer is slow and its pool fills up, calls to Auth, Routing, and Coordinator use their own separate pools and are unaffected.
```

**New:**
```
**Bulkhead Isolation.** Isolated resource pools per target workload. In Go engine workloads, these are goroutine pools and connection pools. In EntryPoint (Rust), tower's `ConcurrencyLimit` layer provides equivalent isolation per target — if Normalizer is slow and its concurrency slot fills up, calls to Auth, Routing, and Coordinator use their own separate limits and are unaffected.
```

#### Edit 3D -- Shield: Context-Based Timeouts paragraph (line 322)

**Old:**
```
**Context-Based Timeouts.** EntryPoint creates a context with a request-level deadline. Every stage call passes this context. Shield enforces per-call timeouts that are always less than the remaining request deadline. If any call exceeds its timeout, the context is cancelled and all downstream calls on that context are also cancelled.
```

**New:**
```
**Context-Based Timeouts.** EntryPoint creates a request-level deadline and propagates it via gRPC metadata. Every stage call carries this deadline. In Go engine workloads, Shield enforces per-call timeouts via Go's `context.Context`. In EntryPoint (Rust), tower's `Timeout` layer enforces per-call timeouts, and tokio's `CancellationToken` cascades cancellation to all downstream calls. If any call exceeds its timeout, all downstream calls on that request are also cancelled.
```

#### Edit 3E -- Tech stack Summary table, replace "Core services" row (line 504)

**Old:**
```
| **Core services** | Go, GoFr, gRPC, Protocol Buffers, buf |
```

**New:**
```
| **Gateway workload** | Rust, tokio, tonic, tower, gRPC, Protocol Buffers, buf |
| **Engine workloads** | Go, GoFr, gRPC, Protocol Buffers, buf |
```

#### Edit 3F -- Full Stack Detail table: add Gateway rows after the Go rows (after line 523)

Insert two new rows between the Go Dev Dependencies row and the existing "Ingress Services" row.

**Old (lines 520-524):**
```
| **Core Services** | Go 1.24+ |
| **Go Frameworks & Libraries** | GoFr 1.54+, pgx, go-redis, grpc-go, grpc-gateway, golang-jwt, gobreaker, failsafe-go, amqp091-go, kafka-go, temporal-sdk-go |
| **Go Dev Dependencies** | golangci-lint, govulncheck, gosec, buf, protoc-gen-go, protoc-gen-go-grpc |
| **Ingress Services** | Rust 1.84+ |
```

**New:**
```
| **Engine Services** | Go 1.24+ |
| **Go Frameworks & Libraries** | GoFr 1.54+, pgx, go-redis, grpc-go, grpc-gateway, golang-jwt, gobreaker, failsafe-go, amqp091-go, kafka-go, temporal-sdk-go |
| **Go Dev Dependencies** | golangci-lint, govulncheck, gosec, buf, protoc-gen-go, protoc-gen-go-grpc |
| **Gateway Service** | Rust 1.84+ |
| **Rust Gateway Frameworks & Libraries** | tokio, tonic, prost, tower, lapin, rdkafka, redis, axum (health/metrics only), tracing, opentelemetry, serde |
| **Rust Gateway Dev Dependencies** | clippy, rustfmt, cargo-audit |
| **Ingress Services** | Rust 1.84+ |
```

Note: "Core Services" label changes to "Engine Services". "Ingress Services" row and its sub-rows remain unchanged.

#### Edit 3G -- Stack Rationale: rewrite "Why Go for core engine workloads" and add new Rust rationale (line 555)

**Old:**
```
**Why Go for core engine workloads.** Go offers fast compilation, low memory footprint, built-in concurrency via goroutines, and straightforward deployment as a single static binary. GoFr provides batteries-included HTTP and gRPC serving, built-in database drivers, middleware chaining, metrics, migrations, and pub/sub — all without the boilerplate that raw Go requires. The engine workloads are I/O-bound (making gRPC calls between pipeline stages), not CPU-bound — Go handles this efficiently with minimal complexity.
```

**New:**
```
**Why Rust for the gateway workload.** EntryPoint is the single chokepoint through which every message passes, inbound and outbound. Top-level performance and reliability are non-negotiable. Rust's ownership model eliminates garbage collection pauses, and tokio's async runtime handles high concurrency with minimal overhead. tonic provides native gRPC client and server capabilities for communicating with both ingress adapters (inbound) and Go engine workloads (outbound calls to Auth, Normalizer, Routing, Coordinator). tower middleware delivers Rust-native resilience — timeouts, concurrency limits (bulkhead), retry with backoff, and circuit breaking — without depending on Shield's Go library. lapin (RabbitMQ) and rdkafka (Kafka) handle command dispatch and event hooks. redis-rs handles rate limiting and session checks. EntryPoint shares the tokio/tower ecosystem with the ingress adapters, enabling shared middleware, connection management, and observability patterns across the entire Rust surface of the subsystem.

**Why Go for engine workloads.** The six engine workloads (Auth, Normalizer, Shield, Coordinator, Resolver, Routing) benefit from Go's fast compilation, low memory footprint, built-in concurrency via goroutines, and straightforward deployment as a single static binary. GoFr provides batteries-included HTTP and gRPC serving, built-in database drivers, middleware chaining, metrics, migrations, and pub/sub — all without the boilerplate that raw Go requires. The engine workloads are I/O-bound (making gRPC calls between pipeline stages), not CPU-bound — Go handles this efficiently with minimal complexity.
```

#### Edit 3H -- Stack Rationale: update "Why Rust for ingress adapters" (line 557)

**Old:**
```
**Why Rust for ingress adapters.** They sit at the system's edge and must handle high connection counts with minimal latency and memory overhead. Rust's ownership model eliminates garbage collection pauses. The tokio async runtime provides efficient handling of thousands of concurrent connections. axum, tonic, async-graphql, and tokio-tungstenite are all built on the tokio/tower ecosystem, sharing middleware and connection management infrastructure.
```

**New:**
```
**Why Rust for ingress adapters.** They sit at the system's edge and must handle high connection counts with minimal latency and memory overhead. Rust's ownership model eliminates garbage collection pauses. The tokio async runtime provides efficient handling of thousands of concurrent connections. axum, tonic, async-graphql, and tokio-tungstenite are all built on the tokio/tower ecosystem, sharing middleware and connection management infrastructure with EntryPoint.
```

Only change: add "with EntryPoint" at the end to acknowledge the shared ecosystem.

---

### File 4: `/Users/Ezra/Code/FastForward/docs/project/architecture/context-diagram.d2`

#### Edit 4A -- Section comment for Engine Workloads (line 62)

**Old:**
```
# --- Engine Workloads (Go / GoFr) ---
```

**New:**
```
# --- Engine Workloads (Go / GoFr) ---
# Note: EntryPoint (Gateway) is Rust / tokio, tonic, tower — shown separately above
```

No other changes needed in this file. The diagram already shows EntryPoint as a separate node from Engine Workloads with its own styling, and the diagram does not display language labels on the nodes themselves (only in comments). The existing structure correctly separates Gateway from Engine.

---

### File 5: `/Users/Ezra/Code/FastForward/docs/path/phase-01-introduction-and-vision.md`

#### Edit 5A -- Step 2 theory, first paragraph (line 65)

**Old:**
```
FastForward is built from 14 workloads spread across three language stacks. Seven core engine workloads are written in Go with the GoFr framework: EntryPoint (the gateway orchestrator), Auth (authentication and authorization), Normalizer (schema validation), Shield (resilience), Coordinator (saga orchestration via Temporal), Resolver (service discovery and health), and Routing (contextual routing and sharding). Four ingress adapter workloads are written in Rust: REST (axum), GraphQL (async-graphql), WebSocket (tokio-tungstenite), and gRPC (tonic). Three workloads are written in Python: Accounts and Audit as domain workloads using Django REST Framework, and TestHarness as a supplement workload using FastAPI.
```

**New:**
```
FastForward is built from 14 workloads spread across three language stacks. The gateway workload — EntryPoint — is written in Rust with tokio, tonic (gRPC), and tower (resilience middleware). It orchestrates the processing pipeline, calling engine workloads via gRPC, dispatching commands via RabbitMQ (lapin), and firing event hooks via Kafka (rdkafka). Six engine workloads are written in Go with the GoFr framework: Auth (authentication and authorization), Normalizer (schema validation), Shield (resilience for Go workloads), Coordinator (saga orchestration via Temporal), Resolver (service discovery and health), and Routing (contextual routing and sharding). Four ingress adapter workloads are also written in Rust: REST (axum), GraphQL (async-graphql), WebSocket (tokio-tungstenite), and gRPC (tonic). Three workloads are written in Python: Accounts and Audit as domain workloads using Django REST Framework, and TestHarness as a supplement workload using FastAPI.
```

#### Edit 5B -- Step 3 theory, Go paragraph (line 130)

**Old:**
```
Go was chosen for the seven core engine workloads because it offers fast compilation, low memory footprint, built-in concurrency via goroutines, a strong standard library for networking and HTTP, and straightforward deployment as a single static binary. GoFr was selected as the framework because it provides batteries-included HTTP and gRPC serving, built-in database drivers (PostgreSQL, Redis), middleware chaining, metrics endpoints, migration support, and pub/sub integration — all without the boilerplate that raw Go requires.
```

**New:**
```
Go was chosen for the six engine workloads (Auth, Normalizer, Shield, Coordinator, Resolver, Routing) because it offers fast compilation, low memory footprint, built-in concurrency via goroutines, a strong standard library for networking and HTTP, and straightforward deployment as a single static binary. GoFr was selected as the framework because it provides batteries-included HTTP and gRPC serving, built-in database drivers (PostgreSQL, Redis), middleware chaining, metrics endpoints, migration support, and pub/sub integration — all without the boilerplate that raw Go requires.
```

#### Edit 5C -- Step 3 theory, after the Go paragraph -- add new Rust gateway paragraph

Insert a new paragraph after the Go paragraph (after line ~131) and before the existing Rust ingress paragraph:

**Insert:**
```
Rust was chosen for the gateway workload (EntryPoint) because it is the single chokepoint through which every message passes. Top-level performance and reliability are non-negotiable at the pipeline orchestrator. Rust's ownership model eliminates garbage collection pauses, and tokio's async runtime handles high concurrency with minimal overhead. tonic provides gRPC client and server capabilities for communicating with ingress adapters and Go engine workloads. tower middleware delivers Rust-native resilience — timeouts, concurrency limits, retry, and circuit breaking — replacing Shield's Go library with equivalent guarantees. lapin (RabbitMQ) and rdkafka (Kafka) handle command dispatch and event hooks. EntryPoint shares the tokio/tower ecosystem with the ingress adapters.
```

#### Edit 5D -- Step 3 theory, existing Rust paragraph for ingress adapters (line ~133)

**Old:**
```
Rust was chosen for the four ingress adapters because they sit at the system's edge and must handle high connection counts with minimal latency and memory overhead. Rust's ownership model eliminates garbage collection pauses. The tokio async runtime provides efficient handling of thousands of concurrent connections. axum (for REST), tonic (for gRPC), async-graphql (for GraphQL), and tokio-tungstenite (for WebSocket) are all built on the tokio/tower ecosystem, sharing middleware and connection management infrastructure.
```

**New:**
```
Rust was also chosen for the four ingress adapters because they sit at the system's edge and must handle high connection counts with minimal latency and memory overhead. The tokio async runtime provides efficient handling of thousands of concurrent connections. axum (for REST), tonic (for gRPC), async-graphql (for GraphQL), and tokio-tungstenite (for WebSocket) are all built on the tokio/tower ecosystem, sharing middleware and connection management infrastructure with EntryPoint.
```

Changes: "also chosen" (since Rust is now mentioned in the preceding paragraph), removed redundant ownership-model sentence (already stated in gateway paragraph), added "with EntryPoint" at end.

#### Edit 5E -- Step 3 examples, Example 1 (line 153)

**Old:**
```
**1. Go vs Rust for core services.**
EntryPoint orchestrates the pipeline — it calls Auth, Normalizer, Routing, Coordinator, and Shield in sequence. The work is I/O-bound (making gRPC calls) not CPU-bound. Go's goroutines handle this efficiently with low complexity. The ingress adapters, by contrast, hold thousands of open connections and parse raw protocol bytes — Rust's zero-cost abstractions and lack of GC pauses make it the better fit at the edge.
```

**New:**
```
**1. Rust for the gateway, Go for the engine.**
EntryPoint orchestrates the pipeline — it calls Auth, Normalizer, Routing, and Coordinator in sequence via gRPC, dispatches commands to RabbitMQ, and fires event hooks to Kafka. As the single chokepoint for all traffic, it demands top-level performance and reliability. Rust's ownership model eliminates GC pauses, tokio handles high concurrency, and tower middleware provides Rust-native resilience (replacing Shield's Go library). The engine workloads behind it are I/O-bound gRPC services where Go's goroutines and GoFr's batteries-included framework handle the work efficiently with low complexity. The ingress adapters share Rust's tokio/tower ecosystem with EntryPoint, giving the entire request-facing surface a unified high-performance stack.
```

#### Edit 5F -- Step 3 Tasks, Task 1 description (line 176)

**Old:**
```
Document the full technology stack organized by layer: core services (Go/GoFr), ingress adapters (Rust ecosystem), ...
```

**New:**
```
Document the full technology stack organized by layer: gateway workload (Rust/tokio/tonic/tower), engine workloads (Go/GoFr), ingress adapters (Rust ecosystem), ...
```

---

### File 6: `/Users/Ezra/Code/FastForward/docs/path/curriculum.md`

#### Edit 6A -- Phase 3 title and description (lines 34-45)

**Old:**
```
## Phase 3 — Go Fundamentals with GoFr

| Step | Title | What You Build |
|------|-------|----------------|
| 10 | GoFr Hello World — EntryPoint Scaffold | `services/core/entrypoint/` with health check and Dockerfile |
| 11 | Request Handling & Context | CRUD handlers using GoFr Context |
| 12 | Database Integration | PostgreSQL + Redis integration, migrations, cache-aside |
| 13 | Middleware Patterns | Request-ID, logging, timing middleware; pipeline stage concept |
| 14 | Error Handling & Validation | Custom errors, error codes, validation middleware |
| 15 | Go Testing | Table-driven tests, mock context, testcontainers-go, coverage |

Learn Go through the EntryPoint workload scaffold. GoFr framework: context, routing, database integration, middleware chains, error handling, and testing patterns.
```

**New:**
```
## Phase 3 — Go Fundamentals with GoFr

| Step | Title | What You Build |
|------|-------|----------------|
| 10 | GoFr Hello World — Auth Scaffold | `services/core/auth/` with health check and Dockerfile |
| 11 | Request Handling & Context | CRUD handlers using GoFr Context |
| 12 | Database Integration | PostgreSQL + Redis integration, migrations, cache-aside |
| 13 | Middleware Patterns | Request-ID, logging, timing middleware; pipeline stage concept |
| 14 | Error Handling & Validation | Custom errors, error codes, validation middleware |
| 15 | Go Testing | Table-driven tests, mock context, testcontainers-go, coverage |

Learn Go through the Auth engine workload scaffold. GoFr framework: context, routing, database integration, middleware chains, error handling, and testing patterns.
```

Changes: Step 10 changes from "GoFr Hello World -- EntryPoint Scaffold" to "GoFr Hello World -- Auth Scaffold" with the build output changing from `services/core/entrypoint/` to `services/core/auth/`. The closing paragraph changes "EntryPoint workload scaffold" to "Auth engine workload scaffold". This moves the Go learning vehicle from EntryPoint (now Rust) to Auth (still Go).

#### Edit 6B -- Phase 5, add EntryPoint scaffold step (lines 58-70)

**Old:**
```
## Phase 5 — Rust Fundamentals & Ingress Concepts

| Step | Title | What You Build |
|------|-------|----------------|
| 20 | Rust Toolchain & Cargo Workspace | `services/ingress/` Cargo workspace, clippy + rustfmt, Dockerfile |
| 21 | Tokio & Async Runtime | Async/await, tasks, select, channels, TCP echo server |
| 22 | Axum Hello World — REST Adapter Scaffold | `services/ingress/rest/` with routing, extractors, tower middleware |
| 23 | Tonic & gRPC in Rust | tonic server + client, prost, shared proto definitions |
| 24 | Rust Testing & CI | Unit + integration tests, cargo test, clippy + cargo-audit in CI |

Learn Rust through the ingress adapter scaffold. Tokio async runtime, axum web framework, tonic gRPC framework, prost for protobuf, tower middleware.
```

**New:**
```
## Phase 5 — Rust Fundamentals, Gateway & Ingress Concepts

| Step | Title | What You Build |
|------|-------|----------------|
| 20 | Rust Toolchain & Cargo Workspace | `services/core/entrypoint/` and `services/ingress/` Cargo workspaces, clippy + rustfmt, Dockerfile |
| 21 | Tokio & Async Runtime | Async/await, tasks, select, channels, TCP echo server |
| 22 | Tonic & gRPC in Rust — EntryPoint Scaffold | `services/core/entrypoint/` with tonic gRPC server/client, health check, tower middleware |
| 23 | Axum Hello World — REST Adapter Scaffold | `services/ingress/rest/` with routing, extractors, tower middleware |
| 24 | Rust Testing & CI | Unit + integration tests, cargo test, clippy + cargo-audit in CI |

Learn Rust through the EntryPoint gateway scaffold and ingress adapter scaffold. Tokio async runtime, tonic gRPC framework (EntryPoint), axum web framework (adapters), prost for protobuf, tower middleware for resilience.
```

Changes: Phase title adds "Gateway". Step 20 adds EntryPoint workspace. Step 22 becomes the EntryPoint scaffold (tonic-first, since EntryPoint is a gRPC orchestrator, not a web server). Old step 23 (tonic) is absorbed into step 22; old step 22 (axum REST adapter) becomes step 23. Closing paragraph updated.

#### Edit 6C -- Phase 6, Step 26 (line 81)

**Old:**
```
| 26 | gRPC Server in GoFr | EntryPoint gRPC server, reflection, unary interceptors |
```

**New:**
```
| 26 | gRPC Server in GoFr | Auth gRPC server, reflection, unary interceptors |
```

EntryPoint's gRPC server is now built in Phase 5 (Rust/tonic). Phase 6 step 26 uses Auth as the Go/GoFr gRPC example instead.

#### Edit 6D -- Phase 8, Step 36 description (line 103)

**Old:**
```
| 36 | EntryPoint — Pipeline Orchestration | Wire the full 8-stage inbound pipeline |
```

No change needed here -- this step is about wiring the pipeline logic, which is still EntryPoint's responsibility. The implementation language changed but the step's purpose is the same. The step will naturally be implemented in Rust given the Phase 5 scaffold.

#### Edit 6E -- Phase 15, Step 76 (line 212)

**Old:**
```
| 76 | Structured Logging | GoFr slog, Rust tracing, Python structlog → Loki |
```

No change needed -- this already covers all three stacks. EntryPoint will use `Rust tracing` which is already listed.

#### Edit 6F -- Summary table, Phase 3 and Phase 5 labels (lines 303-305)

**Old:**
```
| 3 | 10–15 | Go Fundamentals with GoFr |
...
| 5 | 20–24 | Rust Fundamentals & Ingress Concepts |
```

**New:**
```
| 3 | 10–15 | Go Fundamentals with GoFr |
...
| 5 | 20–24 | Rust Fundamentals, Gateway & Ingress Concepts |
```

Only Phase 5 title changes (to match edit 6B). Phase 3 title stays the same -- it is still "Go Fundamentals with GoFr", just using Auth instead of EntryPoint as the learning vehicle.

---

### File 7: `/Users/Ezra/Code/FastForward/docs/path/mitigation-methods.md`

This file does NOT need language/stack changes. It references EntryPoint by behavior (Admission Control, pipeline orchestration, backpressure) not by implementation language. The references to "goroutines", "gobreaker", and "failsafe-go" are in the context of **Shield** (which stays Go), not EntryPoint specifically.

However, there are a few lines that imply EntryPoint uses goroutines specifically:

- Line 95: `"holding a goroutine, a connection, and potentially a database transaction open forever"` -- this is generic M-03 timeout description; "goroutine" is used as a generic term for "lightweight thread" and appears alongside "threads" in other contexts. Acceptable to leave as-is since the document uses "goroutine/thread" interchangeably throughout.
- Line 157: `"active goroutines"` as a capacity indicator -- this is system-wide, not EntryPoint-specific.

**Decision: No changes to mitigation-methods.md.** The document describes resilience patterns in terms of Shield (Go) behavior, and uses "goroutine" as a general distributed-systems term alongside "thread". Changing these would require touching dozens of lines for no material accuracy improvement, since the patterns themselves are language-agnostic.

---

## 4. New ADR to Create

A new ADR should be created to record this architectural decision:

**File:** `docs/project/adrs/004-rust-gateway-workload.md` (or next available number)

**Content outline:**
- **Title:** Rust for the Gateway Workload (EntryPoint)
- **Status:** Accepted
- **Context:** EntryPoint is the single chokepoint for all inbound and outbound traffic. It orchestrates the 8-stage inbound pipeline and 5-stage outbound pipeline, calling engine workloads via gRPC, dispatching commands to RabbitMQ, and firing event hooks to Kafka. Originally planned as Go/GoFr alongside engine workloads. Performance and reliability at the gateway boundary are critical.
- **Decision:** Implement EntryPoint in Rust using tokio (async runtime), tonic (gRPC), tower (resilience middleware), lapin (RabbitMQ), rdkafka (Kafka), and redis-rs (Redis). EntryPoint implements Rust-native resilience via tower middleware instead of consuming Shield's Go library. Shield remains Go and serves engine workloads. EntryPoint communicates with Go engine workloads via gRPC (same protocol ingress adapters already use). EntryPoint stays at `services/core/entrypoint/`.
- **Consequences:**
  - Positive: Zero GC pauses at the chokepoint. Shared tokio/tower ecosystem with ingress adapters. Rust-native resilience without cross-language library dependency. Single high-performance stack for the entire request-facing surface (adapters + gateway).
  - Negative: Two Rust workload categories to maintain (gateway + adapters). EntryPoint cannot use Shield's Go library directly -- resilience must be reimplemented in tower. Cross-language debugging between Rust gateway and Go engine workloads. Slightly more complex build pipeline.

---

## 5. Execution Sequence

Edits should be applied in this order to maintain consistency:

1. **full-reference.md** -- the authoritative reference document; all other docs derive from it
2. **overview.md** -- architectural overview that summarizes full-reference
3. **README.md** -- project entry point that summarizes overview
4. **context-diagram.d2** -- diagram comment update
5. **phase-01-introduction-and-vision.md** -- learning path theory and examples
6. **curriculum.md** -- learning path structure
7. **Create new ADR** -- `docs/project/adrs/004-rust-gateway-workload.md`

---

## 6. Verification Checklist

After all edits, verify:

- [ ] No file says EntryPoint is Go or GoFr
- [ ] Every "Core services" label has been replaced with "Gateway workload" + "Engine workloads" (or equivalent split)
- [ ] Shield documentation clarifies it serves Go engine workloads; EntryPoint uses tower
- [ ] Workload counts are correct: 5 Rust (1 gateway + 4 adapters), 6 Go (engine only), 3 Python
- [ ] The "seven core engine workloads" count is corrected to "six engine workloads" everywhere
- [ ] Tech stack tables have separate rows for Gateway (Rust) and Engine (Go)
- [ ] Stack rationale has a "Why Rust for the gateway workload" paragraph
- [ ] Curriculum Phase 3 uses Auth (not EntryPoint) as the Go scaffold
- [ ] Curriculum Phase 5 includes EntryPoint scaffold in Rust
- [ ] The new ADR exists and is consistent with all other documentation
- [ ] Ingress adapter Rust paragraphs mention shared ecosystem with EntryPoint
- [ ] `grep -ri "EntryPoint.*Go\|GoFr.*EntryPoint" docs/` returns zero matches
