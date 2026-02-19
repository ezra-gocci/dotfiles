# FastForward: API Gateway Platform — Complete Learning Path

## Context

We are building **FastForward** — a bidirectional API gateway subsystem with an eight-stage transactional processing pipeline, a unified gRPC/protobuf internal protocol, CQRS support, saga orchestration via Temporal, and integration hooks for data warehouse, workflow orchestration, CDN, and AI/LLM subsystems.

The subsystem has **14 workloads** across three language stacks:
- **Rust** (5 gateway/ingress): EntryPoint (tokio, tonic, tower), REST (axum), GraphQL (async-graphql), WebSocket (tokio-tungstenite), gRPC (tonic)
- **Go / GoFr** (6 engine): Auth, Normalizer, Shield, Coordinator, Resolver, Routing
- **Python** (3 domain/auxiliary): Accounts (DRF), Audit (DRF), TestHarness (FastAPI)

Three client applications: React (web), React Native / Expo (mobile), Tauri (desktop).

Project directory: `/Users/Ezra/Code/FastForward`

Each tutorial step: **10-15 sentences theory → 5-7 examples → 4 tasks**. We advance only after tasks are solved and approved.

**7 Sections. 21 Phases. 101 Steps.**

---

## Architectural Principles

1. **Eight-Stage Inbound Pipeline** — Protocol Ingress → Admission Control → Authentication → Normalization → Authorization → Routing → Transaction Tracking → Dispatch & Event Hooks. Each stage owned by a dedicated workload. Shield wraps every hop in resilience (Go library for engine workloads; tower middleware natively in EntryPoint).

2. **Five-Stage Outbound Pipeline** — Transaction Tracking → Authorization → Normalization → Resolution → Protocol Egress. Admission, Authentication, and Routing skipped on the way out.

3. **Unified Internal Protocol** — One protobuf envelope for all communication. gRPC for synchronous calls, RabbitMQ for commands, Kafka for events. grpc-gateway for JSON transcoding. buf generates Go, Rust, and Python code from shared schemas.

4. **CQRS** — Commands via RabbitMQ to single consumer. Events via Kafka to multiple consumers. Separated write path (PostgreSQL source of truth) and read path (projections, Redis cache). Applied per use case, not globally imposed.

5. **Saga via Temporal** — Coordinator defines business rules, workflow sequences, and compensation policies. Temporal handles execution, retry, persistence, and replay. No custom saga state machines.

6. **Domain Modeling** — Entities, Value Objects, Aggregates, Invariants, Repository Pattern, Unit of Work. Domain workloads own business logic and nothing else. Storage stays outside the domain layer.

7. **Three-Tier Data Storage** — Platform-wide (shared config, identity), shard-scoped (tenant-partitioned), service-owned (private). Resolver manages access to all three tiers.

8. **Service Mesh** — Consul for service registry, Envoy sidecars for mTLS, traffic policies, and load balancing between workloads.

9. **Observability (LGTM)** — Grafana dashboards, Loki (logs), Tempo (traces), Prometheus (metrics), OpenTelemetry instrumentation at every pipeline stage.

10. **Component Taxonomy** — Application (Web, Mobile, Desktop), Workload (Domain, Engine, Gateway, Adapter, Supplement), Backing (Runtime, Platform, Development), Integration, Partner.

11. **Deployment Strategy (Two-Phase)** — Phase A: Tailscale mesh VPN connects GitHub Actions runners to the local OrbStack Kubernetes cluster. The `tailscale/github-action` joins each CI runner as an ephemeral node on the tailnet; the runner then has direct access to `kubectl` and the cluster API via Tailscale IP. No inbound ports, no self-hosted runner maintenance. All workflows from Phase 2 through Phase 17 use this approach. Phase B: ArgoCD GitOps (Phase 18) takes over deployment. GitHub Actions becomes CI-only (lint → test → build → push GHCR → update manifest tag). ArgoCD running inside the cluster watches the repo, pulls changes, and applies them. Git becomes the single source of truth for cluster state. Tailscale remains available for ad-hoc `kubectl` access and debugging but is no longer in the deployment path.

---

## Developer Tooling

| Tool | Purpose |
|------|---------|
| **mise** | Universal version manager (Go 1.24+, Python 3.13+, Rust 1.84+, Node 22+, buf, protoc) |
| **uv** (Astral) | Python package/project manager |
| **ruff** (Astral) | Python linter + formatter |
| **ty** (Astral) | Python type checker |
| **golangci-lint** | Go linter aggregator |
| **clippy + rustfmt** | Rust linter + formatter |
| **buf** | Protobuf linting, breaking change detection, codegen (Go, Rust, Python) |
| **Zed** | Primary editor with Claude Code integration |
| **JetBrains** | GoLand, PyCharm, RustRover, DataGrip |
| **neovim** | Quick edits |
| **Claude Code** | AI assistant (Web, Desktop, CLI) |
| **GitHub + gh** | VCS, PRs, issues, CI/CD + MCP |
| **OrbStack** | Docker/K8s on macOS |
| **Tailscale** | Mesh VPN connecting GitHub Actions runners to local OrbStack K8s (Phase A deployment) |
| **Security scanning** | gosec, bandit, govulncheck, cargo-audit, pip-audit, npm audit |
| **Documentation** | MkDocs Material, D2, Mermaid, LikeC4 (C4 model), Scalar (API exploration), mike (versioning) |

---

## Project Structure

```
FastForward/
├── services/
│   ├── core/           entrypoint (Rust), auth, normalizer, shield, coordinator, resolver, routing (Go/GoFr)
│   ├── ingress/        rest, graphql, websocket, grpc (Rust)
│   ├── domain/         accounts (Python/DRF), audit (Python/DRF)
│   └── aux/            testharness (Python/FastAPI)
├── proto/              Shared protobuf definitions (common, per-workload)
├── apps/
│   ├── web/            React web application
│   ├── mobile/         React Native / Expo mobile application
│   └── desktop/        Tauri desktop application
├── infra/
│   ├── build/          Docker Compose, Dockerfiles
│   └── deploy/         Pulumi, K8s manifests, Traefik, ArgoCD, Vault, cert-manager
├── scripts/
│   ├── pm/             PM CLI, sync scripts, seed
│   └── run/            run, debug, test, deploy scripts
├── dataseed/           Test data and fixtures
└── docs/
    ├── path/           Learning path documents
    ├── pm/             Project management (epics, stories, tasks)
    └── project/        Architecture, ADRs, API docs, deployment, runbooks
```

---

## Current Progress

### What Exists

**Phase 1 — Introduction & Vision: COMPLETE (Steps 1–3)**
- `README.md` — Full project overview, services table, tech stack, PM section
- `docs/project/architecture/overview.md` — Gateway pattern, pipeline overview, workloads, stacks
- `docs/project/architecture/full-reference.md` — 790-line comprehensive reference (taxonomy, all 14 workloads, pipelines, patterns, compliance)
- `docs/project/architecture/context-diagram.d2` — Complete D2 system context diagram (246 lines)
- `docs/project/adrs/005-rust-gateway-workload.md` — ADR: EntryPoint in Rust (accepted)
- `docs/path/curriculum.md` — Full 21-phase curriculum (already reflects EntryPoint→Rust change)
- `docs/path/phase-01-introduction-and-vision.md` — Phase 1 theory, examples, tasks (all 4 marked done)
- `docs/path/developer_setup.md` — Developer setup guide
- `docs/path/mitigation-methods.md` — Threat mitigation methods
- `docs/path/threat-mitigation-catalog.md` — Threat mitigation catalog

**Project Management System: COMPLETE**
- `docs/pm/` — 7 milestones, 21 epics, 101 stories, 404 tasks (all with YAML frontmatter)
- `docs/pm/README.md` — PM conventions and usage
- `scripts/pm/pm.sh` — CLI for listing, filtering, status updates, reporting
- `scripts/pm/seed.py` — Initial file generator
- `scripts/pm/parse-frontmatter.py` — Shared YAML parser
- `scripts/pm/sync-to-github.py` — Files → GitHub Issues
- `scripts/pm/sync-from-github.py` — GitHub Issues → files
- `scripts/pm/link-pr.py` — PR → task linking on merge
- `.github/workflows/pm-sync-push.yml` — Action: files → issues on push
- `.github/workflows/pm-sync-pull.yml` — Action: issues → files on events
- `.github/workflows/pm-pr-link.yml` — Action: link PRs to work items
- `.github/pull_request_template.md` — PR template with work item references
- `.github/ISSUE_TEMPLATE/` — story.md, task.md, bug.md

**Git & Tooling Infrastructure:**
- `.gitmessage` — Commit template (types, scopes, learning path refs)
- `.gitignore` — Comprehensive (OS, editors, Go, Rust, Python, Node, Docker, K8s, IaC, secrets)
- All directories scaffolded per project structure

**Open Follow-ups:**
- `docs/project/TODO.md` — Verify `full-reference.md#inbound-processing-pipeline` anchor (tracked in T-001-2)
- ADRs 001–004 not yet written (planned in Steps 2–3, Phase 1 stories S-002 and S-003)

### What's Next

Phase 1 stories S-002 and S-003 are `ready` status — their deliverables (workloads.md, pipeline.md, tech-stack.md, ADRs 001–003) have not been created yet. However, the content they describe already exists in `full-reference.md`. The decision on whether to create separate files or reference full-reference.md should be made when presenting Steps 2 and 3.

Phase 2 (Steps 4–9: Developer Environment & Tooling) is the next implementation phase.

---

## Curriculum: 7 Sections, 21 Phases, 101 Steps

---

### SECTION 1 — Foundation & Vision

### PHASE 1 — Introduction & Vision (Steps 1–3) ✅

| # | Title | Description |
|---|-------|-------------|
| 1 | **What is an API Gateway?** | Gateway pattern, request lifecycle, cross-cutting concerns, north-south vs east-west traffic, bidirectional gateway. Component taxonomy (Application, Workload, Backing, Integration, Partner). Creates `README.md`, `docs/project/architecture/overview.md`. |
| 2 | **FastForward Architecture Blueprint** | Map all 14 workloads across 3 language stacks. Eight-stage inbound pipeline + five-stage outbound pipeline. Unified internal protocol. CQRS, saga via Temporal, domain modeling patterns. Three-tier storage, shard model. Integration points (DWH, BPM, CDN/DNS, AI/LLM). Creates `docs/project/architecture/workloads.md`, `docs/project/architecture/pipeline.md`, `docs/project/adrs/001-grpc-internal-protocol.md`. |
| 3 | **Technology Stack & Tooling Rationale** | Why Go/GoFr, Rust for gateway + ingress adapters, Python/DRF+FastAPI, Temporal (not custom saga), LGTM (not ELK), Consul+Envoy (service mesh), RabbitMQ+Kafka (commands vs events), Traefik. Creates `docs/project/architecture/tech-stack.md`, `docs/project/adrs/002-traefik-ingress.md`, `docs/project/adrs/003-rust-ingress-adapters.md`. |

**Status:** Step 1 fully complete (all 4 tasks done). Steps 2–3 content exists in `full-reference.md` but individual deliverable files not yet created. Phase assessed as conceptually complete.

---

### SECTION 2 — Developer Environment & Language Stacks

### PHASE 2 — Developer Environment & Tooling (Steps 4–9)

| # | Title | Description |
|---|-------|-------------|
| 4 | **mise, uv, Rust & Go Toolchains** | Install mise. `.mise.toml` with Go 1.24+, Python 3.13+, Rust 1.84+, Node 22+, buf, protoc, golangci-lint. uv globally. `cargo` + `rustup`. Verify all. Creates `.mise.toml`, `scripts/run/check-prerequisites.sh`. |
| 5 | **Editors, IDEs & Claude Code** | Zed workspace config (Go+Rust+Python+Proto). JetBrains (GoLand, RustRover, PyCharm, DataGrip). Neovim. Claude Code settings. Creates `.editorconfig`, workspace files. |
| 6 | **Monorepo, Git & Quality Hooks** | Pre-commit hooks: golangci-lint, clippy, ruff, buf lint, gosec, bandit. Makefile with targets: lint, test, build, run, docker-up, proto-gen. Creates `Makefile`, `.pre-commit-config.yaml`, `.golangci.yml`. |
| 7 | **Protobuf Workspace & buf** | Shared `proto/` with buf workspace. Common types (Envelope, header with identity/auth/routing/trace context, typed payload). `buf.yaml` + `buf.gen.yaml` for Go + Rust + Python codegen. Creates `proto/`, `buf.yaml`, `buf.gen.yaml`, `proto/common/v1/*.proto`. |
| 8 | **Docker & Backing Services** | Compose for PostgreSQL, Redis, RabbitMQ, Kafka (KRaft), Temporal, Consul, Envoy, Traefik, LGTM stack (Grafana, Prometheus, Tempo, Loki). Health checks. Traefik dashboard. Creates `infra/build/docker-compose.infra.yml`, `infra/deploy/traefik/`. |
| 9 | **GitHub Repository & CI Skeleton** | Push structure. GitHub Actions skeleton (lint/test/build stubs with security scanning: gosec, bandit, govulncheck, cargo-audit, pip-audit). Branch protection. Tailscale mesh VPN: install on local Mac, configure OAuth client, add `tailscale/github-action` to workflows so CI runners join the tailnet as ephemeral nodes and can reach OrbStack K8s API directly. Creates `.github/workflows/ci.yml`, `.github/CODEOWNERS`. |

**Note:** Step 6 — `.gitignore` and `.gitmessage` already exist from Phase 1 work. Step 6 adds Makefile and pre-commit hooks on top.

**Note:** Step 9 — Tailscale is set up here as the deployment bridge (Phase A). GitHub-hosted runners connect to the local OrbStack cluster via Tailscale mesh VPN. No self-hosted runners, no exposed ports. This approach carries through Phase 17. In Phase 18, ArgoCD takes over deployment (Phase B) and Tailscale shifts to ad-hoc access only.

---

### PHASE 3 — Go Fundamentals with GoFr (Steps 10–15)

| # | Title | Description |
|---|-------|-------------|
| 10 | **GoFr Hello World — Auth Scaffold** | Init `services/core/auth/` Go module. GoFr. `main.go` with health check. `.env` config. Multi-stage Dockerfile. Verify with curl. |
| 11 | **Request Handling & Context** | GoFr Context: PathParam, Param, Bind, Header. CRUD for a service registry stub. JSON patterns. |
| 12 | **Database Integration** | Postgres via `ctx.SQL`. Redis via `ctx.Redis`. GoFr migrations. Cache-aside pattern. |
| 13 | **Middleware Patterns** | `func() gofrHTTP.Middleware`. Request-ID, logging, timing middleware. LIFO ordering. Pipeline stage concept. |
| 14 | **Error Handling & Validation** | Custom errors (ValidationError, NotFound, ServiceUnavailable). Error codes. Validation middleware. Early-fired errors in pipeline context. |
| 15 | **Go Testing** | Table-driven tests. Mock GoFr context. testcontainers-go. golangci-lint + gosec config. Coverage. |

**Note:** EntryPoint moved to Rust (Phase 5). Go fundamentals are learned through the Auth engine workload instead.

---

### PHASE 4 — Python Fundamentals with Django DRF (Steps 16–19)

| # | Title | Description |
|---|-------|-------------|
| 16 | **Django DRF Hello World — Accounts Scaffold** | `uv init` in `services/domain/accounts/`. Django + DRF. Health endpoint. Dockerfile with uv. ruff + ty + bandit config. |
| 17 | **Models, Serializers & Views** | Django ORM. DRF ModelSerializer. ViewSets + DefaultRouter. Pagination, filtering. |
| 18 | **Permissions & Testing** | Custom DRF permissions. pytest-django. Factory Boy. ruff + bandit in CI. pip-audit. |
| 19 | **Docker Compose Full Stack** | Wire Auth + Accounts into `infra/build/docker-compose.yml`. Docker networking. Inter-service HTTP verification. |

**Note:** Step 19 wires Auth (Go) + Accounts (Python) — EntryPoint is not yet scaffolded at this point.

---

### PHASE 5 — Rust Fundamentals, Gateway & Ingress Concepts (Steps 20–24)

| # | Title | Description |
|---|-------|-------------|
| 20 | **Rust Toolchain & Cargo Workspace** | Rust 1.84+ via mise. Cargo workspace covering `services/core/entrypoint/` (gateway) and `services/ingress/` (adapters). Shared `Cargo.toml`. clippy + rustfmt config. Multi-stage Dockerfile for Rust. |
| 21 | **Tokio & Async Runtime** | Tokio fundamentals: async/await, tasks, select, channels. A simple TCP echo server. Error handling with `thiserror` and `anyhow`. |
| 22 | **Tonic & gRPC in Rust — EntryPoint Scaffold** | `services/core/entrypoint/` with tonic gRPC server (receives from adapters) and client (calls engine workloads). Health check. tower middleware for resilience (timeouts, concurrency limits, retry, circuit breaking). prost for protobuf. |
| 23 | **Axum Hello World — REST Adapter Scaffold** | `services/ingress/rest/`. axum with routing, extractors, tower middleware. Health endpoint. Request→internal format concept. |
| 24 | **Rust Testing & CI** | Unit + integration tests. `cargo test`. clippy as CI blocker. cargo-audit. Docker Compose integration with EntryPoint + REST adapter. |

**Note:** EntryPoint lives at `services/core/entrypoint/` (it's a pipeline orchestrator, not a protocol adapter). See ADR 005. Shield's Go library is not used by EntryPoint — resilience is native via tower middleware.

---

### SECTION 3 — Internal Protocol & Ingress Layer

### PHASE 6 — Internal Protocol: gRPC & Protobuf (Steps 25–29)

| # | Title | Description |
|---|-------|-------------|
| 25 | **Protobuf Envelope Design** | Internal unified envelope: header (identity, authorization, routing metadata, trace context) + typed payload. Common types. buf lint. Backward compatibility enforcement. |
| 26 | **gRPC Server in GoFr** | GoFr `RegisterServiceServerWithGofr`. Port 9000. Reflection. Unary interceptors. Auth workload as gRPC server. |
| 27 | **gRPC-Gateway: JSON Transcoding** | `google.api.http` annotations. grpc-gateway proxy. Per-workload binary↔JSON toggle for debugging. |
| 28 | **Async Messaging: RabbitMQ Commands & Kafka Events** | Same protobuf envelope serialized onto RabbitMQ (commands, single consumer) and Kafka (events, multi-consumer). Dead letter queues. CloudEvents schema. |
| 29 | **Python & Rust gRPC Integration** | Python stubs from shared proto (grpcio via uv). Rust stubs from shared proto (prost/tonic-build). All three language stacks sharing identical message structures. |

**Note:** Step 26 uses Auth (Go/GoFr) as the example gRPC server, not EntryPoint (which is Rust/tonic).

---

### PHASE 7 — Ingress Adapters (Steps 30–33)

| # | Title | Description |
|---|-------|-------------|
| 30 | **REST Adapter — Full Build** | axum: parse HTTP requests, translate to internal protobuf envelope, forward to EntryPoint via gRPC. Response path: internal format → HTTP response. Rate headers. |
| 31 | **GraphQL Adapter** | async-graphql: schema definition, query/mutation handling. Translate GraphQL operations into internal envelope. Depth/complexity limiting. Introspection toggle. |
| 32 | **WebSocket Adapter** | tokio-tungstenite: persistent connection management. Frame→envelope translation. Auth on handshake. Connection registry. Bidirectional message flow. |
| 33 | **gRPC Adapter** | tonic: accept external gRPC calls, translate to internal envelope, forward to EntryPoint. Public API protos distinct from internal protos. Reflection. |

---

### SECTION 4 — Pipeline Engine & Security

### PHASE 8 — Pipeline Engine Workloads (Steps 34–39)

| # | Title | Description |
|---|-------|-------------|
| 34 | **Normalizer Workload** | Go/GoFr at `services/core/normalizer/`. gRPC API. Parse message body + metadata, validate against schemas, convert to canonical internal format. Schema registry. Structural checkpoint — anything invalid stops here. |
| 35 | **Shield Workload** | Go/GoFr at `services/core/shield/`. Resilience library wrapping every Go engine hop: configurable circuit breakers (gobreaker), exponential backoff + jitter (failsafe-go), bulkhead isolation, context-based timeouts. EntryPoint implements equivalent resilience natively via tower middleware. |
| 36 | **EntryPoint — Pipeline Orchestration** | Wire EntryPoint (Rust/tonic) as the pipeline orchestrator: receive from ingress adapters, chain through Admission Control (own) → Auth → Normalizer → Auth → Routing → Coordinator → Dispatch. Event hooks after dispatch. EntryPoint calls engine workloads via gRPC. |
| 37 | **Outbound Pipeline** | EntryPoint orchestrates the reverse: Transaction Tracking → Authorization → Normalization → Resolution → Protocol Egress. Shield wraps every outbound hop (Go engine side); tower middleware wraps EntryPoint's own hops. |
| 38 | **Admission Control** | EntryPoint's own first filter (Rust): source identity, address fingerprint, request rate, target path, content checks. Malformed/oversized/policy-violating messages rejected on the spot. |
| 39 | **Rate Limiting** | Token bucket + Redis (redis-rs in EntryPoint). Per-IP, per-key, per-tenant, per-endpoint, global. X-RateLimit-* headers. Atomic Redis ops. Integrated into Admission Control. |

---

### PHASE 9 — Authentication & Security (Steps 40–45)

| # | Title | Description |
|---|-------|-------------|
| 40 | **Auth Workload — Email/Password & JWT** | Go/GoFr at `services/core/auth/`. bcrypt. JWT access + refresh token rotation. gRPC token validation API. User context binding to message envelope. |
| 41 | **Pipeline Authentication Stage** | Auth as pipeline stage 3: extract credentials, verify identity, bind user context object to envelope. Identity-based rate limits. Protected vs public routes. |
| 42 | **OAuth 2.0 (Google, GitHub)** | Authorization Code flow. Provider interface. Account linking. Callbacks via REST adapter. |
| 43 | **SSO (SAML) & 2FA (TOTP)** | SAML 2.0 SP-initiated. Per-tenant IdP. TOTP generation/verification. QR enrollment. Backup codes. |
| 44 | **Pipeline Authorization Stage & RBAC** | Auth as pipeline stage 5: decide allowed operations based on identity, role, request context. Signed authorization attached to message. Roles, permissions, groups. Multi-tenant isolation at authorization level. |
| 45 | **Certificate Management & Security Headers** | Auth owns TLS certificate management for subsystem endpoints and external integrations. API key generation/rotation/scoping/revocation. CORS, HSTS, CSP headers. |

---

### SECTION 5 — Routing, Transactions & Service Mesh

### PHASE 10 — Routing & Sharding (Steps 46–50)

| # | Title | Description |
|---|-------|-------------|
| 46 | **Routing Workload — Context-Based Engine** | Go/GoFr at `services/core/routing/`. gRPC API. Rules: tenant, role, region, feature flags, API version, path. Declarative config. Hot-reload. Priority matching. Message annotation (destination workload, shard, delivery method). |
| 47 | **Multi-Shard Routing** | Consistent hashing. Shard map (tenant→shard). Scatter-gather for cross-shard queries. Transaction affinity — in-flight transactions pinned to owning shard. |
| 48 | **Shard Migration & Version-Aware Routing** | Phased dual-write migration. Version map. Drain period + timeout. Canary shard rollout. Version-aware routing during migration. |
| 49 | **Dispatch Strategies** | EntryPoint (Rust) reads routing metadata and dispatches: synchronous gRPC call vs RabbitMQ command queue (via lapin). Strategy selection based on message type and routing annotation. |
| 50 | **Load Balancing & Connection Management** | Round-robin, weighted, least-conn, random. Strategy pattern. Health checks. Connection draining. Integration with Consul service catalog. |

---

### PHASE 11 — Transactional Processing & CQRS (Steps 51–57)

| # | Title | Description |
|---|-------|-------------|
| 51 | **Coordinator Workload — Temporal Integration** | Go/GoFr at `services/core/coordinator/`. Temporal SDK. Coordinator as thin domain policy layer: defines workflow sequences, compensation rules, transaction policies. Temporal handles execution, retry, persistence, replay. |
| 52 | **Saga Workflows** | Temporal workflows: multi-step transactions across workloads. Activity definitions. Compensation on failure (LIFO reversal). Idempotency requirements. Deduplication. |
| 53 | **Pipeline Transaction Tracking Stage** | Coordinator as pipeline stage 7: create or link transactional entity, check message relevance for current state, detect duplicates, resolve state dependencies. Messages outside transactions pass through untouched. |
| 54 | **CQRS — Command Side** | Command handlers in domain workloads. Commands via RabbitMQ to single consumer. Validate business rules, mutate state, write to PostgreSQL (source of truth), publish domain events to Kafka. |
| 55 | **CQRS — Query Side** | Kafka consumers build read-optimized projections (denormalized PostgreSQL views, Redis cache). Queries routed to read services that serve projections directly. Eventual consistency. |
| 56 | **Domain Modeling — Aggregates, Repositories & Unit of Work** | Entities, Value Objects, Aggregates (root entity as only entry point), Invariants. Repository pattern (collection-like API hiding storage). Unit of Work (atomic commit of multiple repo operations). Applied in Accounts and Audit workloads. |
| 57 | **Commands vs Events — Broker Design** | RabbitMQ for commands (ordered, single-consumer, backpressure). Kafka for events (high-throughput, multi-consumer, replay). CloudEvents schema. Error propagation on commands. Independent consumer handling on events. |

---

### PHASE 12 — Service Discovery, Health & Data Tiers (Steps 58–62)

| # | Title | Description |
|---|-------|-------------|
| 58 | **Resolver Workload** | Go/GoFr at `services/core/resolver/`. gRPC API. Resolves logical name + options → concrete address, port, credentials. Pluggable backends: Consul, K8s DNS, static config. Watch-based updates. |
| 59 | **Consul & Envoy Service Mesh** | Consul as service registry. Envoy sidecars for mTLS between workloads. Traffic policies. Health check integration. Resolver reads from Consul. |
| 60 | **Health Control** | Resolver owns continuous heartbeat monitoring and availability tracking across all workloads and backing services. Readiness/liveness probes. Health-aware DNS failover endpoint. |
| 61 | **Three-Tier Data Storage** | Platform-wide (shared config, identity, event bus), shard-scoped (tenant-partitioned), service-owned (private). Unified config schema. Resolver manages access to all three tiers. Storage resolver API. |
| 62 | **Callback & Async Response Management** | 202 Accepted + callback URL. Webhook receiver. Status polling. Callback state machine. Coordinator integration for async transaction steps. |

---

### SECTION 6 — Domain Workloads, Testing & Observability

### PHASE 13 — Python Domain Workloads: Full Build (Steps 63–69)

| # | Title | Description |
|---|-------|-------------|
| 63 | **Accounts — Multi-Tenant Domain Model** | Django ORM: Account (aggregate root), Profile, TenantMembership, Role, Group. Abstract base with tenant_id. Invariants enforced at aggregate level. Custom managers. Migrations. |
| 64 | **Accounts — Repository & Unit of Work** | AccountRepository interface (get, add, list, delete). Django ORM implementation. Unit of Work wrapping Django transaction management. In-memory repository for tests. |
| 65 | **Accounts — Full API** | DRF ViewSets + actions: invite, activate/deactivate, roles/groups, activity timeline. Plans (free/pro/enterprise). Loyalty points. Celery for local async tasks (email dispatch, report generation). |
| 66 | **Accounts — gRPC Integration** | Python gRPC server + client. Shared proto stubs via buf. Resolver SDK integration. Commands via RabbitMQ, events to Kafka. |
| 67 | **Audit Workload** | `services/domain/audit/`. Kafka consumer. Turns raw technical events into domain-meaningful statistics. Searchable audit log storage. Query API. Retention policies. gRPC server. |
| 68 | **Python Testing (Full)** | pytest-django + APITestCase. Factory Boy. gRPC mocks. In-memory repositories. pytest-cov. bandit + pip-audit in CI. |
| 69 | **Contract Testing (Pact + buf)** | Consumer-driven contracts. Pact broker. Proto breaking changes via `buf breaking`. CI pipeline integration. |

---

### PHASE 14 — Testing Framework & Mocking (Steps 70–75)

| # | Title | Description |
|---|-------|-------------|
| 70 | **TestHarness Scaffold** | Python/FastAPI at `services/aux/testharness/`. REST API for mocks, test suites, test runs. PostgreSQL storage. Dockerfile with uv. |
| 71 | **Service Mocking Engine** | Mock definitions: request pattern → response. REST, gRPC, GraphQL protocol support. Stateful sequences. Dynamic injection replacing real workloads during testing. |
| 72 | **API Testing Framework** | Test suites: request sequences + assertions. Variable extraction/chaining. Environment-aware execution. Parallel execution. Scalar for API exploration. |
| 73 | **CI/CD Test Integration** | GitHub Actions: run suites on PR. Publish results to TestHarness. History tracking. Flaky test detection. |
| 74 | **Async & Transaction Testing** | Test async flows: command → callback/event → assert. Webhook receiver. Temporal workflow verification. Saga compensation testing. |
| 75 | **Test Dashboard Backend** | API: current errors, statistics, trends, root cause analysis. GitHub source links. Run comparison. Visualization data for web client. |

---

### PHASE 15 — Observability & Monitoring (Steps 76–81)

| # | Title | Description |
|---|-------|-------------|
| 76 | **Structured Logging** | GoFr slog config. Rust tracing crate. Python structlog. Correlation IDs (request_id, transaction_id, tenant_id) in every log line. Log sampling. All logs shipped to Loki. |
| 77 | **Prometheus Metrics** | GoFr `/.well-known/metrics`. Custom metrics (histograms, counters, gauges) per pipeline stage. Rust metrics via prometheus crate. Python prometheus_client. Scrape config. |
| 78 | **Distributed Tracing (Tempo)** | GoFr OpenTelemetry (TRACE_EXPORTER=otlp → Tempo). Rust opentelemetry-otlp. Custom spans per pipeline stage. W3C Trace Context across gRPC/RabbitMQ/Kafka. Python opentelemetry. |
| 79 | **Grafana Dashboards** | Dashboard-as-code JSON. Gateway traffic. Pipeline stage latencies. Transaction states. Service health. Per-tenant views. PromQL + LogQL + TraceQL. Alerts. |
| 80 | **Observability Correlation & SLOs** | Trace IDs in audit. Logs↔metrics↔traces↔audit cross-linking. SLI/SLO definitions. Alert rules. Runbooks. |
| 81 | **Data Warehouse Integration Hooks** | Debezium CDC → Kafka. Structured access logs. DWH-ready schemas. Webhook hooks for external data pipeline consumers. |

---

### SECTION 7 — Infrastructure, Clients & Launch

### PHASE 16 — Local Kubernetes & Traefik (Steps 82–86)

| # | Title | Description |
|---|-------|-------------|
| 82 | **Local K8s Cluster (kind)** | kind config: 1 control plane + 2 workers. Port mappings. Local registry. kubeconfig. OrbStack integration. |
| 83 | **Kubernetes Manifests** | Deployments, Services, ConfigMaps, Secrets for all 14 workloads. Probes. Resource limits. Namespaces (core, ingress, domain, aux, backing). |
| 84 | **Traefik Ingress on K8s** | Traefik as ingress controller. IngressRoute CRDs. Per-protocol subdomains (rest.api.*, ws.api.*, graphql.api.*, grpc.api.*). Middleware. Dashboard. CDN/DNS integration points. |
| 85 | **Certificate Management** | cert-manager. Self-signed CA (dev). Let's Encrypt ACME DNS-01 challenges (staging). Traefik TLS termination. mTLS via Consul + Envoy. |
| 86 | **Deploy All Workloads to K8s** | Build → push local registry → apply manifests → verify. All 14 workloads running. Consul mesh verified. Observability stack connected. |

---

### PHASE 17 — Pulumi IaC (Steps 87–90)

| # | Title | Description |
|---|-------|-------------|
| 87 | **Pulumi Project Init** | TypeScript project at `infra/deploy/pulumi/`. Stack config (dev). K8s provider. Local state. GCP provider stub for future cloud deployment. |
| 88 | **Pulumi Workload Deployments** | All 14 workloads as Pulumi resources. Component resources. Parameterized replicas/resources. `pulumi up`. |
| 89 | **Pulumi Observability & Mesh** | Helm charts via Pulumi: LGTM stack (Grafana, Prometheus, Tempo, Loki), Consul, Envoy, Temporal. ServiceMonitors. |
| 90 | **Pulumi Networking** | Traefik via Pulumi. NetworkPolicies (deny-by-default, explicit allow between workload tiers). Ingress TLS. cert-manager. |

---

### PHASE 18 — GitOps with ArgoCD (Steps 91–93)

| # | Title | Description |
|---|-------|-------------|
| 91 | **ArgoCD Installation** | Deploy ArgoCD to K8s. Git repo source. UI access. Sync policies. GHCR image registry. |
| 92 | **Application Definitions** | App-of-apps pattern. Per-workload Application CRDs. Kustomize overlays (dev). Sync waves (backing → core → ingress → domain → aux). |
| 93 | **GitOps Workflow & Rollbacks** | Commit → push → sync. Immutable image tag management. Rollback via git revert. Health gates. ArgoCD notifications. Migrate CI workflows from Tailscale-based `kubectl apply` (Phase A) to CI-only mode: build → push GHCR → update manifest tag. ArgoCD handles all deployment (Phase B). Tailscale remains for ad-hoc `kubectl` access and debugging. |

**Note:** Phase 18 completes the deployment strategy migration. Before this phase, GitHub Actions deploys via Tailscale mesh VPN (runners join tailnet, run `kubectl apply` directly). After this phase, GitHub Actions is CI-only — ArgoCD watches the repo and pulls changes autonomously. No inbound connections at any point.

---

### PHASE 19 — Vault & Secrets (Steps 94–96)

| # | Title | Description |
|---|-------|-------------|
| 94 | **Vault Installation** | Vault on K8s (Helm). K8s auth method. KV v2. Policies per workload. Secrets never in environment variables, code, or images. |
| 95 | **Secret Injection** | Vault Agent Injector. Pod annotations. DB creds, JWT keys, API keys, Consul tokens from Vault. Integration with Resolver for credential resolution. |
| 96 | **Rotation & Dynamic Credentials** | Rotation policies. Dynamic PostgreSQL creds. Audit of secret access. Supply chain security: govulncheck, cargo-audit, pip-audit results stored and tracked. |

---

### PHASE 20 — Web & Desktop Clients (Steps 97–100)

| # | Title | Description |
|---|-------|-------------|
| 97 | **React Web App Setup** | Vite + React + TypeScript in `apps/web/`. TanStack Router, TanStack Query, Zustand, React Hook Form, Zod, Tailwind CSS 4, shadcn/ui. ESLint + Prettier + Vitest. Auth context. MkDocs Material for project docs setup. |
| 98 | **Web — Auth, Accounts & Admin** | Login, register, OAuth, 2FA. Account management (invite, activate/deactivate, roles, groups, activity timeline). Gateway admin: route config, rate limits, workload health. Transaction monitor. Test dashboard (suites, results, error drill-down). |
| 99 | **Tauri Desktop App** | Tauri 2.10+ in `apps/desktop/`. Rust shell + React frontend (shared web components via Vite + Tailwind + shadcn/ui). Workload monitoring dashboard. Real-time pipeline metrics. System tray integration. |
| 100 | **React Native Mobile App** | Expo SDK 54+ in `apps/mobile/`. Expo Router, TanStack Query, Zustand, NativeWind. Auth (email, OAuth, biometric). Account management. Workload health cards. Push notifications. Offline queue sync. |

---

### PHASE 21 — Capstone: Integration, CI/CD & Launch (Step 101)

| # | Title | Description |
|---|-------|-------------|
| 101 | **Full Platform Integration & Production Readiness** | E2E cross-workload tests via TestHarness. Contract tests (Pact) + proto compat (buf breaking). k6 load tests (pipeline throughput, transaction latency, shard migration under load). GitHub Actions full pipeline: lint → security scan → test → build → push GHCR → deploy → ArgoCD sync. MkDocs Material documentation (architecture, pipeline, ADRs, API docs via Scalar + neoteroi-mkdocs, deployment guides, runbooks). D2 architecture diagrams + LikeC4 C4 models. Multi-tenant demo scenario: create tenant → onboard accounts → route traffic (all 4 protocols) → observe transactions → view dashboards → run tests → verify audit. Shard migration scenario. Compliance readiness review (PCI DSS 4.0, SOC 2 Type II, OWASP API Security Top 10). Cloud-native 14-factor verification. Production readiness checklist. |

---

## How We Work

1. I present each step: **theory (10-15 sentences) → examples (5-7) → 4 tasks**
2. You work on tasks, ask questions as needed
3. When tasks are complete, you confirm → we advance
4. We start at **Step 1** and progress linearly
5. Architecture Decision Records (ADRs) created at key decision points
6. Every workload gets its own Dockerfile from the start
7. Tests written alongside implementation (not deferred)
8. Protobuf definitions always written before implementation
9. Full architecture documentation lives in `docs/project/` (referenced from README)
10. PM system tracks all work — `scripts/pm/pm.sh start T-XXX-N` before work, `scripts/pm/pm.sh done T-XXX-N` after
11. Commits follow `.gitmessage` conventions with `Refs:` footer linking to PM items
12. Deployment via Tailscale mesh VPN (Phases 2–17), then ArgoCD GitOps (Phase 18+)

## Verification Strategy

- **After coding steps:** run workload, verify with curl/grpcurl/httpie
- **After proto steps:** `buf lint`, `buf generate`, verify generated code compiles in Go, Rust, and Python
- **After Rust steps:** `cargo test`, `cargo clippy`, `cargo audit`
- **After infra steps:** `kubectl get pods` (via Tailscale or local), `pulumi preview`, ArgoCD UI (Phase 18+)
- **After client steps:** verify in browser (React), simulator (React Native), or desktop app (Tauri)
- **After test framework steps:** run test suites through TestHarness API
- **Periodic checkpoints:** full `docker compose up` with all workloads communicating
- **PM verification:** `scripts/pm/pm.sh status` after each step to confirm task completion tracking

---

## Implementation Plan: Add Milestones as Top-Level PM Entity

### Context

The PM system currently has 3 entity levels: Epic → Story → Task (mapping to Phase → Step → Task in the curriculum). The 21 phases naturally group into larger thematic sections. Adding a **Milestone** entity above Epics creates a 4-level hierarchy that mirrors Sections in the curriculum:

**Section → Phase → Step → Task == Milestone → Epic → Story → Task**

### Milestone Groupings (7 Milestones)

| ID | Section Title | Phases | Epics | Steps |
|----|--------------|--------|-------|-------|
| M-01 | Foundation & Vision | 1 | E-01 | 1–3 |
| M-02 | Developer Environment & Language Stacks | 2–5 | E-02..E-05 | 4–24 |
| M-03 | Internal Protocol & Ingress Layer | 6–7 | E-06..E-07 | 25–33 |
| M-04 | Pipeline Engine & Security | 8–9 | E-08..E-09 | 34–45 |
| M-05 | Routing, Transactions & Service Mesh | 10–12 | E-10..E-12 | 46–62 |
| M-06 | Domain Workloads, Testing & Observability | 13–15 | E-13..E-15 | 63–81 |
| M-07 | Infrastructure, Clients & Launch | 16–21 | E-16..E-21 | 82–101 |

### Milestone YAML Schema

```yaml
---
id: M-01
title: "Foundation & Vision"
type: milestone
status: active
epics: [E-01]
domain: [architecture, documentation]
started: 2025-02-10
completed: null
github_issue: null
---

# M-01 — Foundation & Vision

Section 1 of 7. Phases 1. Steps 1–3.
```

Statuses: `planned`, `active`, `done` (same as Epics).

### Files to Modify (12 files)

#### 1. `scripts/pm/seed.py`
- Add `MILESTONES` data structure (list of 7 dicts with id, title, phases, epics, domain, status)
- Add `generate_milestones()` function producing `docs/pm/milestones/M-01.md` through `M-07.md`
- Update `generate_epics()` to add `milestone: M-XX` field to each epic's YAML frontmatter
- Update `main()` to call `generate_milestones()` and include count in output

#### 2. `scripts/pm/pm.sh`
- Update usage comment header to include `milestones` entity
- Add `milestones` case to `cmd_list()` entity switch → `dir="$PM/milestones"`
- Add `--milestone` filter option to `cmd_list()` (filter epics/stories/tasks by parent milestone)
- Add milestone counting block to `cmd_status()` (total, done, active)
- Add milestone header line to status output
- Update `cmd_report()` to loop milestones → epics (two-level nesting) with progress bars for both
- Update usage help text

#### 3. `scripts/pm/link-pr.py`
- Change `ITEM_RE` regex from `r"\b([EST]-\d{2,3}(?:-\d+)?)\b"` to `r"\b([ESTM]-\d{2,3}(?:-\d+)?)\b"`
- Add `"milestones"` to `find_pm_file()` subdirs list

#### 4. `scripts/pm/sync-to-github.py`
- Add `"milestones"` to `dirs` list (line 121) — order: `["milestones", "epics", "stories", "tasks"]`
- Add `milestone` field to `issue_body` construction in `sync_file()`

#### 5. `scripts/pm/sync-from-github.py`
- Add `"milestones"` to `find_pm_file()` subdirs list

#### 6. `.github/workflows/pm-sync-pull.yml`
- Add `|| startsWith(github.event.issue.title, '[M-')` to the `if` condition (line 15)

#### 7. `.github/ISSUE_TEMPLATE/milestone.md` (NEW)
- Create new issue template following the pattern of `story.md`

#### 8. `docs/pm/README.md`
- Add Milestone row to Entity Hierarchy table (before Epic)
- Add Milestone statuses to Statuses table
- Update "Tasks reference their parent story..." text to include milestone→epic link
- Add `milestones/` to Directory Layout
- Add `--milestone` filter to CLI examples

#### 9. `docs/pm/milestones/` (NEW DIRECTORY)
- Create 7 milestone files: `M-01.md` through `M-07.md`

#### 10. `docs/pm/epics/E-01.md` through `E-21.md` (21 files)
- Add `milestone: M-XX` field to YAML frontmatter of each epic

#### 11. `docs/path/curriculum.md`
- Add Section headings above Phase groupings
- Update the Summary table to include a Section column

#### 12. Plan file (this file)
- Update the Context section to reference "7 Sections. 21 Phases. 101 Steps."
- Add Section headings to the phase listing in the curriculum section

### Implementation Order

1. **seed.py** — Add `MILESTONES` data and `generate_milestones()`. Update epic generation to include `milestone` field. This is the source of truth for all data.
2. **Create milestone files** — Run seed.py or create 7 `M-XX.md` files manually. Also update all 21 `E-XX.md` files to add `milestone` field.
3. **pm.sh** — Add `milestones` entity support, `--milestone` filter, status counts, report nesting.
4. **link-pr.py** — Update regex and `find_pm_file()`.
5. **sync-to-github.py** — Add `"milestones"` to dirs, update body builder.
6. **sync-from-github.py** — Add `"milestones"` to `find_pm_file()`.
7. **pm-sync-pull.yml** — Add `[M-` prefix check.
8. **ISSUE_TEMPLATE/milestone.md** — Create template.
9. **docs/pm/README.md** — Update documentation.
10. **docs/path/curriculum.md** — Add Section headings and update summary.
11. **Plan file** — Update phase headings with section groupings.

### Verification

1. `ls docs/pm/milestones/` — 7 files (M-01.md through M-07.md)
2. `grep "^milestone:" docs/pm/epics/E-*.md | wc -l` — 21 epics all have milestone field
3. `scripts/pm/pm.sh list milestones` — lists all 7 milestones with status
4. `scripts/pm/pm.sh list epics --milestone M-02` — filters epics by milestone
5. `scripts/pm/pm.sh status` — shows milestone counts alongside epic/story/task counts
6. `scripts/pm/pm.sh report` — shows milestone→epic nested progress
7. `python scripts/pm/sync-to-github.py --dry-run` — includes milestones in sync
8. Verify `link-pr.py` regex matches `M-01` in a test string
9. Verify curriculum.md has Section headings above phase groups
