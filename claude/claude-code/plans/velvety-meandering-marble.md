# Plan: Move EntryPoint (Gateway) from Go/GoFr to Rust

## Context

EntryPoint is the single chokepoint through which every message passes — inbound and outbound. The user wants "top level performance and reliability" at the gateway, which motivates moving it from Go/GoFr to Rust. This is a documentation-only change (no code exists yet beyond `.gitkeep` placeholders). It touches 7 files across architecture docs, learning path, and curriculum.

## Key Decisions

- **EntryPoint stays at `services/core/entrypoint/`** — it's a pipeline orchestrator, not a protocol adapter
- **Shield stays Go** — serves engine workloads; EntryPoint uses Rust-native resilience via tower middleware
- **Engine workloads stay Go/GoFr** — Auth, Normalizer, Shield, Coordinator, Resolver, Routing
- **"Core services" label splits** into "Gateway workload" (Rust) + "Engine workloads" (Go) in all tables
- **Workload counts**: 5 Rust (1 gateway + 4 adapters), 6 Go (engine), 3 Python

## EntryPoint Rust Stack

`Rust / tokio, tonic, tower` — orchestrator, not a web framework app:
- **tokio** — async runtime (shared with ingress adapters)
- **tonic + prost** — gRPC server (receives from adapters) and client (calls engine workloads)
- **tower** — resilience middleware: timeouts, concurrency limits (bulkhead), retry, circuit breaking
- **lapin** — RabbitMQ client for command dispatch
- **rdkafka** — Kafka producer for event hooks
- **redis-rs** — rate limiting, session checks, distributed locks
- **axum** — minimal, health/metrics HTTP endpoints only
- **tracing + opentelemetry** — observability

## Files Changed (7 files, ~25 edits)

### 1. `docs/project/architecture/full-reference.md` — 8 edits
- Gateway workload table: `Go / GoFr` → `Rust / tokio, tonic, tower` with expanded description
- Shield section: clarify it serves Go engine workloads; EntryPoint uses tower equivalents
- Shield subsections (Bulkhead, Timeouts): add Rust implementation details alongside Go
- Tech stack summary: split "Core services" → "Gateway workload" + "Engine workloads"
- Full stack detail: rename "Core Services" → "Engine Services", add Gateway rows (libraries + dev deps)
- Stack rationale: split "Why Go for core engine workloads" into "Why Rust for gateway" + "Why Go for engine"
- Ingress adapter rationale: note shared ecosystem with EntryPoint

### 2. `docs/project/architecture/overview.md` — 3 edits
- Workloads table: Gateway row → `Rust / tokio, tonic, tower`
- Language Stacks: insert new Rust gateway paragraph before Go, narrow Go to "engine workloads"
- Shield description: clarify dual-stack resilience (tower for EntryPoint, gobreaker for Go workloads)

### 3. `README.md` — 2 edits
- Services table: EntryPoint row → `Rust / tokio, tonic, tower`
- Tech stack table: split "Core services" → "Gateway workload" + "Engine workloads"

### 4. `docs/project/architecture/context-diagram.d2` — 1 edit
- Add comment noting EntryPoint is Rust, separate from Go engine workloads

### 5. `docs/path/phase-01-introduction-and-vision.md` — 6 edits
- Step 2 theory: rewrite workload listing (EntryPoint = Rust, 6 engine = Go)
- Step 3 theory: narrow Go paragraph to 6 engine workloads, add new Rust gateway paragraph
- Step 3 theory: update Rust ingress paragraph to note shared ecosystem with EntryPoint
- Step 3 Example 1: rewrite "Go vs Rust for core services" → "Rust for the gateway, Go for the engine"
- Step 3 Task 1: update tech stack layer description

### 6. `docs/path/curriculum.md` — 4 edits
- Phase 3 Step 10: change scaffold from EntryPoint → Auth (Go learning vehicle)
- Phase 5: rename to "Rust Fundamentals, Gateway & Ingress Concepts", add EntryPoint scaffold step
- Phase 6 Step 26: use Auth instead of EntryPoint for GoFr gRPC example
- Summary table: update Phase 5 title

### 7. New: `docs/project/adrs/004-rust-gateway-workload.md`
- ADR documenting the decision: context, rationale (performance + reliability at chokepoint), consequences

## Execution Order

1. full-reference.md (authoritative source)
2. overview.md (summarizes full-reference)
3. README.md (summarizes overview)
4. context-diagram.d2
5. phase-01-introduction-and-vision.md
6. curriculum.md
7. Create ADR

## Verification

After all edits, confirm:
- `grep -ri "EntryPoint.*Go\|GoFr.*EntryPoint" docs/` returns zero matches
- No file says "Core services" as a single combined row
- Workload counts correct everywhere: 5 Rust, 6 Go, 3 Python
- Shield docs clarify dual-stack resilience
- Curriculum Phase 3 uses Auth (not EntryPoint) as Go scaffold
- Curriculum Phase 5 includes EntryPoint Rust scaffold
