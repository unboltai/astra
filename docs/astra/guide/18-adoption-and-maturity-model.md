# 18. Adoption and maturity model
- **Phased rollout**: observe→enforce‑non‑blocking→enforce‑blocking→optimize
- **Readiness checklist**: identity, policy, telemetry, lineage, incident response
- **Change management**: policy staging, shadow evaluation, safe rollbacks

#### 18a. Pilot‑to‑production checklist
- **Security baseline**: per‑agent identities; least‑privilege scopes; policy‑as‑code gate at control points; authenticated MCP/tool access; audit enabled
- **Compliance readiness**: evidence model defined; retention and privacy controls; access reviews; segregation of duties where applicable
- **Risk assessment**: threat model documented; compensating controls; incident response playbooks; rollback procedures

#### 18b. Foundation‑to‑Scale path
- **Foundation Phase**: first agent deployment with SAG; basic policy, audit, and lineage in place
- **Scale Phase**: multiple agents; enterprise IAM/OAuth integration; decision/evidence SLAs; policy library expansion
- **Orchestration Phase**: multi‑agent workflows with A2A security; trust‑aware discovery; workflow‑level policies; advanced observability

