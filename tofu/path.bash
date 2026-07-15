# Linux standalone install path; brew on macOS manages its own PATH
[[ -d "$HOME/.bin/opentofu" ]] && export PATH="$HOME/.bin/opentofu:$PATH"
