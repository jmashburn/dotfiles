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

# ── Main ──────────────────────────────────────────────────────────────────────

if already_installed; then
  echo "> Updating Google Cloud SDK"
  gcloud components update --quiet
  echo "> $(gcloud version | head -1)"
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
