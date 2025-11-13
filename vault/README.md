# Vault browser

This folder contains a small helper script that provides an interactive
fzf-based browser for Vault KV (v2) secrets.

Usage
-----

- Source your dotfiles as you normally do, which will create the `vaultbrowser`
  alias pointing to the `_browse_vault` function.

- Optionally set `VAULT_ROOT` to the mount path (without the trailing slash):

```bash
export VAULT_ROOT=secret
```

If `VAULT_ROOT` is not set, the script will attempt to detect a KV v2 mount
by running `vault secrets list` and picking the first mount that is a `kv` with
`version=2`. If none is found it falls back to `secret`.

Requirements
------------

- HashiCorp Vault CLI (`vault`) available on PATH
- `jq` for JSON processing
- `fzf` for the interactive selector

Notes
-----

This script tries to be conservative and will prompt for a username when
`VAULT_USER` is unset. Authentication uses the `VAULT_METHOD` environment
variable (default: `oidc`) for `vault login` if a valid token is not found.
