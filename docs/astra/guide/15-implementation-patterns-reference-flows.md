# 15. Implementation patterns (reference flows)
- **Trust‑aware discovery & orchestration**: prefer high‑trust agents; decay on violations
- **Zero‑trust time‑boxed permissions**: ephemeral scopes per request/session
- **Causal chain auditing**: lineage IDs across calls; reconstructable graphs
- **Threat‑informed policies**: exfiltration throttles, escalation blocks, behavior gates
- Each pattern: context, sequence diagram pointer, policy hooks, observable evidence

  #### 15a. SAG Implementation Pattern
  #### 15b. Policy Development Pattern
  #### 15c. A2A Communication Pattern
  #### 15d. Anti‑patterns (what not to do)
  - Deploying agents without access controls (“we’ll add security later”)
  - Using shared service accounts instead of agent‑specific identities
  - Manual audit processes that do not scale or meet evidence requirements

