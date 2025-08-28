# 21. Appendices
- **A. Glossary**
- **B. Metrics definitions (CSS, TUE, latency buckets)**
- **C. Lineage schema and evidence formats**
- **D. Threat→control mapping tables**
- **E. Bibliography (academic and standards)**: Trust Fabric; Zero‑Trust for agentic systems; ATFAA/SHIELD; TRiSM; relevant standards
- **F. Detailed layered architecture model and control points**
  - Layered model details by plane
    - Control Plane: policy engine, trust registry, identity/IAM integrations, decision and evidence interfaces
    - Data Plane: agents, tools, sessions, workflows, messages, MCP gateway boundaries
    - Observability Plane: audit logs, OpenTelemetry traces and metrics, data lineage DAGs
  - Layer taxonomy (mapping to original Section 6)
    - Trust Fabric Layer: trust registry, scoring, delegation, attestations
    - Security Fabric Layer: policy engine, access matrix, context evaluators
    - Agent Fabric Layer: agent registration, discovery, messaging, orchestration
    - Compliance Fabric Layer: audit, lineage, evidence stores, compliance rules
    - Integration Fabric Layer: gateways (e.g., MCP), identity/IAM, event bus
    - Foundation Layer: database models, logging/telemetry, exceptions, common models
  - Control points (from original Section 7)
    - Gateway boundary
    - Message bus
    - Session manager
    - Workflow engine
  - Enforcement modes and constraints
    - Pre‑execution checks
    - In‑flight monitoring
    - Post‑action audits
    - Time‑bounded least privilege: ephemeral permissions, scoped tokens, session expiry
    - Causal controls: decisions tied to provenance and policy justifications
  - Diagrams and artifacts
    - Planes overview diagram
    - Detailed layered architecture diagram
    - Policy evaluation sequence
    - A2A communication sequence
    - Lineage capture points

### Companion documents (suggested)
- **ASTRA Controls & Policy Library**: reusable, parameterized policies and control narratives
- **ASTRA Validation Playbook**: test harness specs, workload definitions, KPI calculators
- **ASTRA Implementation Mapping Guide**: concept→capability mapping for adopters' platforms; crosswalks to layered designs in design/v2/
- **ASTRA Operator Runbook**: observability, incident response, compliance reporting
- **ASTRA ROI Calculator**: web‑based tool for cost avoidance, efficiency gains, and risk reduction calculations (updated annually)


