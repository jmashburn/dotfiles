#!/usr/bin/env bash
#
# Install or update Google Cloud SDK
# macOS: official installer script
# Linux: apt (Debian/Ubuntu) or official installer script
#

set -euo pipefail

GCLOUD_BIN="${HOME}/google-cloud-sdk/bin/gcloud"

# ── Helpers ───────────────────────────────────────────────────────────────────

already_installed() {
  command -v gcloud &>/dev/null || [[ -x "${GCLOUD_BIN}" ]]
}

install_via_script() {
  echo "> Downloading Google Cloud SDK installer"
  curl -fsSL https://sdk.cloud.google.com | bash -s -- --disable-prompts --install-dir="${HOME}"
  echo "> Installed. Restart your shell or run: source \${HOME}/google-cloud-sdk/path.bash.inc"
}

install_linux_apt() {
  echo "> Installing Google Cloud SDK via apt"
  curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
  echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
    | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
  sudo apt-get update -q
  sudo apt-get install -y google-cloud-cli google-cloud-cli-gke-gcloud-auth-plugin
}

# ── Update path for current session if SDK is installed locally ───────────────
add_to_path() {
  if [[ -f "${HOME}/google-cloud-sdk/path.bash.inc" ]]; then
    # shellcheck source=/dev/null
    source "${HOME}/google-cloud-sdk/path.bash.inc"
  fi
}

# ── Update: detect install method and use the right updater ──────────────────

update_gcloud() {
  # When installed via apt/brew/snap, gcloud components update is disabled.
  # Detect by checking if the component manager reports it's disabled.
  if gcloud components update --quiet 2>&1 | grep -q "disabled\|not available\|package manager"; then
    echo "> Component manager disabled — updating via package manager"
    if command -v apt-get &>/dev/null && apt-cache show google-cloud-cli &>/dev/null 2>&1; then
      sudo apt-get update -q && sudo apt-get install -y --only-upgrade google-cloud-cli
    elif command -v brew &>/dev/null && brew list google-cloud-sdk &>/dev/null 2>&1; then
      brew upgrade google-cloud-sdk || true
    else
      echo "> Could not determine package manager. Update gcloud manually." >&2
    fi
  fi
  echo "> $(gcloud version | head -1)"
}

# ── Main ──────────────────────────────────────────────────────────────────────

if already_installed; then
  echo "> Updating Google Cloud SDK"
  update_gcloud
  exit 0
fi

case "$(uname -s)" in
  Darwin)
    install_via_script
    ;;
  Linux)
    if command -v apt-get &>/dev/null; then
      install_linux_apt
    else
      install_via_script
    fi
    ;;
  *)
    echo "Unsupported OS: $(uname -s)" >&2
    exit 1
    ;;
esac

add_to_path

echo "> Run 'gcloud auth login' to authenticate"
echo "> Run 'gcloud auth application-default login' for application credentials"
