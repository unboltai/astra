# 5. Architecture overview (consolidated)
- **Planes model**: Control Plane (Policy + Trust + Identity), Data Plane (Agents + Tools + Messages), Observability Plane (Audit + Lineage + Metrics)
- **Interaction flows (narrative)**: agent→gateway→policy→tool; agent↔agent with policy gates
- **Control points (summary)**: gateway boundary, message bus, session manager, workflow engine
- **Enforcement modes (summary)**: pre‑execution checks, in‑flight monitoring, post‑action audits
- **Time‑bounded least privilege (summary)**: ephemeral permissions, scoped tokens, session expiry
- **Non‑goals**: what this RA intentionally does not prescribe (e.g., specific LLMs, vendors)
- See Appendix F for the detailed layered model and control point descriptions.

