# Plan: Rewrite README Prose for an Engaged, Curious Voice

**Context:** The README is technically complete and internally consistent. The user wants the prose rewritten — same structure, same terms, same diagrams, same tables, same technical content — but in a voice that reads like a clever, curious person explaining a complex system to a smart reader who hasn't built such projects. Think popular science magazine: confident, direct, occasionally vivid, never condescending.

**File:** `/Users/Ezra/Code/FastForward/README.md`

## What changes

**Only prose paragraphs and sentences.** Specifically:

### Intro (4 paragraphs, lines 3-12)
- Rewrite all four paragraphs. Make the opening grab attention. Use concrete imagery where the current text is abstract. The "learning project" paragraph should feel like an invitation, not a disclaimer.

### Feature section intros (3 one-liners)
- "What the pipeline does to every message passing through:" — give it personality
- "Infrastructure capabilities that support the gateway and the broader platform:" — same
- "Tooling for building, testing, and documenting the subsystem:" — same

### Feature bullet prose (Gateway, Operational, Development)
- Rewrite the dash-separated descriptions. Keep bold labels and technical terms intact. Make each bullet land with more clarity and less passive construction.

### Multilayered Message Processing
- Rewrite the intro paragraph ("Every inbound message...")
- Rewrite each stage description (the text after the bold label and italic workload name). Keep stage numbers, bold names, italic workload attributions.
- Rewrite Shield paragraph and outbound pipeline intro sentence
- Rewrite the "Admission Control, Authentication, and Routing are skipped..." paragraph
- Rewrite the forward-reference sentence to Internal Protocol

### Internal Protocol (3 paragraphs)
- Rewrite all three. Make the "single envelope" concept click immediately.

### Architectural Patterns
- Rewrite the section intro paragraph
- For each pattern (CQRS, Saga, Commands and Events, Domain Modeling, Repository, Unit of Work):
  - Rewrite the opening explanation paragraph(s)
  - Rewrite "Why it matters" paragraphs
  - Rewrite "How FastForward applies it" bullet prose (keep bold sub-labels)
  - Rewrite closing paragraphs (e.g., "When a simple synchronous read-write cycle...")
  - Keep all bold labels, italic labels, technical terms, tool names, examples

### External Infrastructure Integration
- Rewrite section intro paragraph
- Rewrite Load Balancer intro sentence
- Rewrite all bullet prose under LB, CDN, DNS, DDoS (keep bold sub-labels)
- Rewrite topology description paragraph (including the context/topology diagram clarification sentence)

### Component Taxonomy
- Rewrite the intro paragraph

### Cloud-Native Factor Compliance
- Rewrite the intro paragraph

### Compliance Readiness
- Rewrite section intro paragraph
- Rewrite PCI DSS intro + "Where the architecture already aligns" paragraph
- Rewrite SOC 2 intro + alignment paragraph
- Rewrite OWASP intro + alignment paragraph
- Rewrite table cell prose in all three compliance tables (keep bold requirement/criteria labels)

## What does NOT change

- `# FastForward` heading
- All `##` and `###` section headings
- All Mermaid diagrams (zero changes)
- All tables' structure and column headers
- Tech Stack table content (tool names, versions, parentheticals)
- Workloads table structure (but Description column prose gets rewritten)
- Component Taxonomy table (Description and Examples columns get rewritten)
- Factor Compliance table (How FastForward supports it column gets rewritten)
- Project Structure code block
- Bold labels in feature bullets (e.g., **Admission, Authentication & Authorization**)
- Stage numbers and bold stage names in pipeline
- Italic workload attributions (e.g., _(EntryPoint)_)
- All technical terms: workload names, tool names, protocol names, pattern names
- License section

## Voice guidelines

- **Confident, not hedging.** "The pipeline splits reads from writes" not "The pipeline is designed to split reads from writes."
- **Concrete, not abstract.** Use specific verbs. "Shield wraps every hop in circuit breakers" not "Shield provides resilience capabilities."
- **Curious, not dry.** Occasionally show why something is interesting. "The same protobuf envelope travels by gRPC call and by Kafka message — consumers can't tell the difference."
- **Short sentences mixed with longer ones.** Vary rhythm. Don't make every sentence the same length.
- **No emojis, no exclamation marks, no rhetorical questions.** Stay sharp and clear.
- **No dumbing down.** The reader is smart. Don't over-explain basic concepts. Do make complex interactions vivid.
- **Keep existing sentence-level technical precision.** If the current text says "annotates messages with routing metadata," the rewrite should preserve that exact semantic — just say it better.

## Implementation approach

Work section by section, top to bottom. Each edit replaces only prose — old_string/new_string pairs targeting paragraph-level or bullet-level text. Never touch anything inside ``` fences (diagrams, code blocks). Never touch table structure or bold/italic markup patterns.

## Verification

- Read the full file after all edits to verify no diagrams, tables, or technical terms were altered
- Check that all bold labels, stage numbers, and italic attributions survived intact
- Regenerate preview.html and review rendered output
