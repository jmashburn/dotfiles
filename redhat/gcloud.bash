# Google Cloud / Vertex AI environment configuration
# Project: itpc-gcp-it-all-claude
# Account: jmashbur@redhat.com

# ── Core project / account ────────────────────────────────────────────────────
export GOOGLE_CLOUD_PROJECT="itpc-gcp-it-all-claude"   # standard GCP SDK
export CLOUDSDK_CORE_PROJECT="itpc-gcp-it-all-claude"  # mirrors gcloud config
export CLOUDSDK_CORE_ACCOUNT="jmashbur@redhat.com"

# ── Region ────────────────────────────────────────────────────────────────────
export CLOUDSDK_COMPUTE_REGION="us-east5"

# ── Vertex AI ─────────────────────────────────────────────────────────────────
export CLOUD_ML_PROJECT_ID="itpc-gcp-it-all-claude"    # legacy AI Platform
export CLOUD_ML_REGION="us-east5"
export VERTEXAI_PROJECT="itpc-gcp-it-all-claude"       # Vertex AI Python SDK
export VERTEXAI_LOCATION="us-east5"

# ── Claude Code via Vertex AI ─────────────────────────────────────────────────
export CLAUDE_CODE_USE_VERTEX=1
export ANTHROPIC_VERTEX_PROJECT_ID="itpc-gcp-it-all-claude"

# ── Application Default Credentials ───────────────────────────────────────────
# Used by all Google Cloud client libraries (Python, Go, Node, etc.)
export GOOGLE_APPLICATION_CREDENTIALS="${HOME}/.config/gcloud/application_default_credentials.json"
