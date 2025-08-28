#!/usr/bin/env bash
set -euo pipefail

BASE="$HOME/projects/unbolt/astra"
mkdir -p "$BASE"/docs/astra/reference "$BASE"/docs/astra/guide
cd "$BASE"

# Git + Python deps
[ -d .git ] || git init -b main
python3 -m venv .venv
. .venv/bin/activate
pip install -q --upgrade pip
pip install -q mkdocs-material mkdocs-git-revision-date-localized-plugin

# Ignore build/venv
cat > .gitignore <<'EOF'
.venv/
site/
__pycache__/
EOF

# MkDocs config (Material + MCP-like layout)
cat > mkdocs.yml <<'YAML'
site_name: ASTRA Documentation
theme:
  name: material
  features:
    - navigation.tabs
    - navigation.sections
    - toc.integrate
    - content.code.copy
    - search.suggest
    - search.highlight
plugins:
  - search
  - git-revision-date-localized:
      fallback_to_build_date: true
nav:
  - Introduction: index.md
  - Reference Architecture:
      - 1. Purpose, scope, positioning: astra/reference/01-purpose-scope-positioning.md
      - 2. Current state assessment: astra/reference/02-current-state.md
      - 5. Architecture overview: astra/reference/05-architecture-overview.md
      - 8. Identity, trust, attestation: astra/reference/08-identity-trust-attestation.md
      - 9. Policy and governance: astra/reference/09-policy-governance.md
      - 10. Data lineage & causal auditing: astra/reference/10-lineage-causal.md
      - 11. Threat model & controls: astra/reference/11-threat-controls.md
      - 13. Deployment & ops: astra/reference/13-deployment-ops.md
      - 14. Interop & standards: astra/reference/14-interop-standards.md
  - Implementation Guide:
      - 15. Implementation patterns: astra/guide/15-implementation-patterns.md
      - 15d. Anti-patterns: astra/guide/15d-anti-patterns.md
      - 16. Validation & benchmarks: astra/guide/16-validation.md
      - 17. Controls catalog: astra/guide/17-controls-catalog.md
      - 18a. Pilot-to-production: astra/guide/18a-pilot-to-production.md
      - 18b. Foundation-to-Scale path: astra/guide/18b-foundation-to-scale.md
  - FAQs: astra/faq.md
YAML

# Home with “Choose your path”, MCP-style
cat > docs/index.md <<'MD'
# ASTRA Documentation

- **Understand Concepts (RA)**: Start with Sections 1–2, then 5, 8–11, 14.
- **Use ASTRA (IG)**: Start with 15, then 18a checklist, 18b path, 16, 17.
- **Ready to Build?** See Implementation Patterns and Pilot-to-Production.

See Reference Architecture → 5. Architecture overview for the planes model.
MD

# RA stubs
cat > docs/astra/reference/01-purpose-scope-positioning.md <<'MD'
# 1. Purpose, scope, positioning
MD
cat > docs/astra/reference/02-current-state.md <<'MD'
# 2. Current state assessment
MD
cat > docs/astra/reference/05-architecture-overview.md <<'MD'
# 5. Architecture overview (consolidated)
MD
cat > docs/astra/reference/08-identity-trust-attestation.md <<'MD'
# 8. Identity, trust, and attestation
MD
cat > docs/astra/reference/09-policy-governance.md <<'MD'
# 9. Policy and governance
MD
cat > docs/astra/reference/10-lineage-causal.md <<'MD'
# 10. Data lineage and causal chain auditing
MD
cat > docs/astra/reference/11-threat-controls.md <<'MD'
# 11. Threat model and controls
MD
cat > docs/astra/reference/13-deployment-ops.md <<'MD'
# 13. Deployment and operational models
MD
cat > docs/astra/reference/14-interop-standards.md <<'MD'
# 14. Interoperability and standards
MD

# IG stubs
cat > docs/astra/guide/15-implementation-patterns.md <<'MD'
# 15. Implementation patterns
MD
cat > docs/astra/guide/15d-anti-patterns.md <<'MD'
# 15d. Anti-patterns
MD
cat > docs/astra/guide/16-validation.md <<'MD'
# 16. Validation and benchmarking methodology
MD
cat > docs/astra/guide/17-controls-catalog.md <<'MD'
# 17. Controls catalog
MD
cat > docs/astra/guide/18a-pilot-to-production.md <<'MD'
# 18a. Pilot-to-Production checklist
MD
cat > docs/astra/guide/18b-foundation-to-scale.md <<'MD'
# 18b. Foundation-to-Scale path
MD

# FAQ
mkdir -p docs/astra
cat > docs/astra/faq.md <<'MD'
# FAQs
MD

# Validate build
mkdocs build -q
echo "Scaffold complete. Activate with: source .venv/bin/activate && mkdocs serve -a 127.0.0.1:8000"
