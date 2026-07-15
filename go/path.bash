# Go path configuration
# Detects location from brew (macOS) or /usr/local/go (Linux)
# GOROOT is intentionally not set — Go finds it from its own binary

if command -v brew &>/dev/null && brew --prefix go &>/dev/null 2>&1; then
  # macOS: brew manages Go — its bin dir is already in PATH via brew
  export GOPATH="${HOME}/go"
  export PATH="${GOPATH}/bin:$(brew --prefix go)/bin:${PATH}"
elif [[ -d /usr/local/go ]]; then
  # Linux: official binary install
  export GOPATH="${HOME}/go"
  export PATH="${GOPATH}/bin:/usr/local/go/bin:${PATH}"
fi
