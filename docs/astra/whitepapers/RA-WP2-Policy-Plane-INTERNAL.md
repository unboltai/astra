# Agent Security and Trust Reference Architecture (ASTRA) — Policy Plane

Version 0.1 (INTERNAL Draft) | Target publish: September 4, 2025

---

## Executive Summary
The ASTRA Policy Plane is the intelligence center of the Agent Security Control Plane. It converts organizational governance into real‑time decisions for every agent‑to‑tool interaction, using policy‑as‑code with explainability, low latency, and enterprise integration. This paper specifies the Policy Decision Point (PDP), Policy Information Point (PIP), canonical policy input schema, decision caching, and operational guardrails.

---

## Scope and Non‑Goals
- In Scope: PDP design, PIP context assembly, canonical input schema and validators, decision caching, explain‑deny, policy lifecycle (versioning, tests, rollouts), interfaces (CLI/REST/SDK), performance targets, observability, and security.
- Non‑Goals: Gateway mechanics (RA‑WP3), audit pipeline internals (RA‑WP4), identity/secrets (RA‑WP5), A2A governance (RA‑WP6).

---

## Design Principles
- Policy‑as‑Code: Rego policies with version control, golden tests, and code review flows [[7]](#7)
  The Policy Plane treats governance as software. Policies live alongside code, benefit from reviews and tests, and can be rolled out or rolled back like any other artifact. This creates a predictable, auditable change process and eliminates configuration drift.

- Low‑Latency First: Sub‑50ms uncached, sub‑5ms cached decisions
  Decision latency must never block agent workflows. We achieve this with an OPA server (long‑lived evaluator), Redis caching for hot paths, and careful schema design to minimize evaluation complexity while preserving expressiveness.

- Deterministic Inputs: Canonical, validated schema; no nested input.input
  Policies are only as reliable as their inputs. A single, versioned schema—with strict validation and field-level semantics—ensures evaluations are deterministic and safe to optimize. Unknown or malformed fields lead to default‑deny and clear errors.

- Context‑Rich: Agent, tool, environment, history, and intent signals
  Real‑world decisions require more than who and what. We incorporate when, where, and why: environmental conditions, prior violations, and declared vs. inferred intent. This enables nuanced allow/deny/escalate outcomes that match enterprise risk posture.

- Explainability: Always return decision + reason + remediation hint
  Developers and auditors must understand why a call was allowed or denied. The PDP returns concise reasons (e.g., missing scope) and hints (e.g., required capability) to speed remediation and build trust in the system.

- Safety: Deny by default; escalate with human approval under uncertainty
  When confidence is low—ambiguous intent, unusual access patterns, or missing context—the system chooses safety. Escalation paths are built‑in, preserving velocity without compromising control.

---

## Architecture Overview

```mermaid
flowchart LR
  PIP[Policy Information Point<br/>Context Assembly] --> PDP[Policy Decision Point<br/>Policy Evaluator (e.g., OPA) + Cache]
  PDP -->|decision + reason| SAG[Secure Agent Gateway]
  POLICY_REPO[(Policy Repo<br/>Policy Packages (e.g., bundles)]] --> PDP
  REDIS[(Redis Cache)] <--> PDP
  OBS[Observability Pipeline<br/>(e.g., OTel) Traces/Logs] <--> PDP
```

The PDP is a long‑running policy evaluator (e.g., OPA) with decision caching layered in front to absorb repeated evaluations. The PIP assembles context from the gateway and supporting sources, normalizes it to the canonical schema, and attaches correlation identifiers for observability. Policies are distributed as signed packages (e.g., OPA bundles), enabling safe hot‑reloads and blue/green deployments. All evaluations emit structured telemetry via an observability pipeline (e.g., OpenTelemetry), avoiding raw sensitive data while preserving end‑to‑end traceability.

---

## Canonical Policy Input Schema (v1)

```json
{
  "agent": {
    "id": "string",
    "type": "string",
    "trust_level": "number",
    "capabilities": ["string"],
    "metadata": {}
  },
  "tool": {
    "id": "string",
    "name": "string",
    "type": "string",
    "operation": "string",
    "intended_effect": "string",
    "data_classification": "string"
  },
  "context": {
    "timestamp": "string",
    "business_hours": "boolean",
    "source_ip": "string",
    "session_age": "number",
    "declared_intent": "string",
    "inferred_intent": "string",
    "intent_confidence": "number"
  }
}
```

Validators: JSON Schema + SDK codegen (Py/TS). Clients validate before sending; the PDP re‑validates on receipt. Unknown fields are rejected to prevent silent policy bypass. Invalid or missing required fields produce a default‑deny with a clear error reason to aid debugging.

---

## Responsibilities

### Policy Decision Point (PDP)
- Evaluate Rego policies on OPA server (not subprocess) with Redis decision cache [[7]](#7)
  A persistent OPA instance avoids process spawn overhead and supports bundle‑based policy delivery. Redis holds recent decisions keyed by salient inputs, yielding sub‑5ms responses on hot paths.

- Return: allow|deny|escalate, reason, conditions, audit_level
  Every decision is explicit and machine‑consumable. Conditions (e.g., "audit_level:detailed") inform downstream logging. Reasons are concise strings designed for UI/CLI display.

- Explainability: rule trace and remediation hint (e.g., missing scope)
  The PDP exposes the rule path responsible for the outcome and provides actionable next steps, reducing friction for developers and auditors alike.

- Hot‑reload via bundles; blue/green policy rollouts; fast rollback
  Policies ship as signed bundles. We stage and verify them before activation, enabling predictable changes and instant rollback if metrics regress.

### Policy Information Point (PIP)
- Assemble context from SAG: agent, tool, environment, history, and intent signals
  The PIP gathers a complete picture of the request—who is acting, what they want to do, where and when, with what history—and enriches it with intent signals (declared and inferred).

- Normalize inputs to canonical schema; attach correlation ids
  Normalization prevents policy fragility. Correlation IDs connect decisions to audit/logs for end‑to‑end traceability across services.

- Guard invalid/ambiguous context → escalate or deny
  If required fields are absent, or intent confidence is low for a sensitive operation, the PIP triggers escalation paths rather than guessing.

---

## Decision Outcomes
- allow: proceed; include audit_level
  The gateway executes the call and the audit pipeline records the event at the prescribed level.

- deny: include reason + remediation hint
  Denials are informative. The response explains the cause and suggests the minimal change to achieve compliance (e.g., add "read_finance" scope).

- escalate: require human approval; attach context packet (minimal PII)
  For higher‑risk actions, the PDP signals an approval workflow. The context packet includes just enough information for a reviewer, respecting PII minimization.

---

## Caching and Performance
- Redis decision cache keyed by (agent_id, tool_id, operation, intent hash, time bucket)
  Keys capture the essence of the decision while avoiding over‑specificity. Including an intent hash differentiates read vs. write paths with similar parameters.

- TTL tuned to risk; purge on policy or context model change
  Low‑risk paths cache longer; sensitive paths expire quickly. Any policy publish or schema change invalidates affected keys.

- Targets: P95 < 5ms cached, < 50ms uncached; >95% cache hit for steady traffic
  These targets ensure policies do not become a bottleneck as adoption scales.

---

## Interfaces
- REST: POST /evaluate → decision, reason, conditions, audit_level, eval_ms
  The authoritative interface for services. Responses are stable and versioned; clients negotiate features via headers.

- CLI: local evaluation for tests and CI
  Enables developers to iterate on policies quickly with reproducible inputs and golden outputs.

- SDKs: typed client with schema validators and error taxonomy
  SDKs reduce client‑side boilerplate and ensure consistent error handling across languages.

---

## Explainability (Explain‑Deny)
- Provide rule pathway and minimal hints: missing capability/scope, off‑hours access, data_classification violation
  Hints are intentionally narrow—enough to fix the issue without exposing sensitive policy internals. Rule pathways map to documentation for faster self‑service.

- Developer‑friendly strings + machine fields for UI
  Human‑readable messages come with structured codes so UIs can render consistent toasts, badges, and remediation links.

---

## Observability & Security
- OTel (or equivalent) traces around evaluate; structured logs (inputs hashed, not raw)
  We trace the full evaluation path, but only log hashed snapshots of inputs to prevent leakage while preserving debuggability.

- Deny by default; rate‑limit evaluations under abuse; input size caps
  Back‑pressure protects the PDP under abnormal loads, and size caps prevent resource exhaustion.

- Policy repo signed packages/bundles; integrity checks at load time
  Prevents tampering and ensures only verified policies are active in production.

---

## Related Work & Standards
- OPA documentation and bundles [[7]](#7)
- OAuth resource indicators and metadata (for token mediation alignment) [[10]](#10), [[11]](#11), [[12]](#12)
- Intent verification, drift assurance, and formalization [[17]](#17), [[18]](#18), [[19]](#19)

---

## Roadmap Alignment
- NorthStar: OPA server + Redis, canonical input, explainability, bundles
- Publication plan: RA‑WP2 on Sep 4; RA‑WP3 (SAG) on Sep 11; RA‑WP4 (Audit) on Sep 25
- IGs: IG‑1 quickstart (Sep 6) shows basic decisions; IG‑3 (Oct 14) covers policy packs + explain‑deny

---

## Glossary
- PDP: Policy Decision Point
- PIP: Policy Information Point
- Explain‑Deny: returning reason and remediation hints for denied/escalated decisions

---

## References
- Reuse anchors from RA‑WP1 INTERNAL for [7], [10], [11], [12], [17], [18], [19].
