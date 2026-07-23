# gpg

GnuPG configuration and key-management workflows.

## What's here

| File | Symlinked to | Purpose |
|------|--------------|---------|
| `gnupg.symlink/gpg.conf` | `~/.gnupg/gpg.conf` | General hardening: long key IDs, UID validity display, cross-cert, SHA512/AES256 preferences. No `default-key` — identity stays out (see below). |
| `gnupg.symlink/gpg-agent.conf` | `~/.gnupg/gpg-agent.conf` | 24h passphrase/SSH cache, loopback pinentry. |
| `install.sh` | — | Installs `gnupg` + `pinentry-curses` (apt) / `pinentry-mac` (brew), sets `~/.gnupg` to mode 700, reloads the agent. |

Only config files are symlinked into `~/.gnupg`; keyrings and secret material stay as real files.

## Install

`script/bootstrap` links the configs (the `.symlink` directory is linked
recursively into `~/.gnupg`). Then run the installer for dependencies:

```bash
bash gpg/install.sh          # or: script/install-tools
gpgconf --reload gpg-agent   # pick up config without re-login
```

**Identity stays out of the repo.** The default signing key is *not* set in
`gpg.conf`; it lives with your identity in the gitignored `~/.gitconfig.local`
(`user.signingkey`), the same way the rest of the dotfiles separate machine
identity from shared config. For standalone `gpg` use, add `default-key <KEYID>`
to a local, un-committed `gpg.conf` override if you want one.

## Pinentry

Uses **`pinentry-curses`** — an in-terminal prompt, not a GUI window. It works
in plain terminals, over SSH, and headless/CI, so it's the portable default.
`GPG_TTY` is exported in `bash/bashrc.symlink`, which curses pinentry needs to
find the terminal.

To use a GUI prompt instead, install a GUI pinentry and set `pinentry-program`
in `gpg-agent.conf` (commented examples are in the file), then
`gpgconf --reload gpg-agent`.

### Why the GUI pin can't be shared

`pinentry-program` takes an absolute path, and `gpg-agent.conf` supports neither
conditionals nor includes — so a GUI pinentry cannot be declared in the managed
config without breaking every other OS. The correct path differs three ways
(`/usr/bin/pinentry-curses` on WSL, `/opt/homebrew/bin/pinentry-mac` on Apple
Silicon, `/usr/local/bin/pinentry-mac` on Intel). Hence the commented menu above:
the pin is a deliberate per-machine opt-in.

A machine that opts in keeps `~/.gnupg/gpg-agent.conf` as a **real file, not
symlinked** to `gnupg.symlink/gpg-agent.conf`, and sets `pinentry-program` there.
Worth doing on macOS: curses pinentry needs a controlling TTY, so without a GUI
pin, signing fails with `gpg: signing failed: Timeout` from any non-interactive
context — editors, hooks, and tooling — not just at a bare prompt.

The tradeoff is drift: that machine stops tracking changes to the managed
`gpg-agent.conf`, and a later `script/bootstrap` run will try to link over the
local file. Reconcile the two by hand when that happens.

---

# Key-management workflows

Throughout, `$KEYID` is your key's ID or fingerprint
(`gpg --list-secret-keys --keyid-format=long`).

## Combine keys added on another machine

`gpg --import` **merges** — importing a key that has subkeys your keyring lacks
adds the missing subkeys; it never overwrites what you already have.

```bash
# On the machine that has the new subkeys — exports primary + ALL subkeys:
gpg --export-secret-keys --armor $KEYID > secret-full.asc

# Transfer securely (encrypted USB / scp), then on the other machine:
gpg --import secret-full.asc
gpg --list-secret-keys --keyid-format=long $KEYID   # every subkey shows ssb (no #)
```

`ssb` = secret present; `ssb#` = secret *not* available for that subkey.
Ownertrust isn't carried by import — sync separately if needed:
`gpg --export-ownertrust` / `--import-ownertrust`.

## Renew / set an expiry

Expiration is **not** revocation — an expired key is renewable at any time (even
after it lapses) as long as you hold the primary secret. It's a dead-man's
switch, not a shelf life. Past signatures made while valid stay valid.

```bash
gpg --edit-key $KEYID
  expire            # primary key — enter e.g. 2y, confirm y (passphrase prompt)
  key 1             # select a subkey
  key 2             # select another subkey (repeat as needed)
  expire            # same expiry on the selected subkeys
  save
```

Renewing later is the identical sequence with a fresh date. If the key was ever
published, re-distribute the public key afterward so others see the new expiry.

## Per-device subkeys (offline primary)

Keep the **primary key offline** and give each machine only **subkeys**. Lose a
device → revoke just that device's subkeys with the offline primary; every other
device keeps working. A device that holds no primary secret shows `sec#`.

### 1. Secure the master offline (do the backup first — losing the primary secret is permanent)

```bash
gpg --export-secret-keys --armor $KEYID > /media/OFFLINE/master-secret.asc
gpg --gen-revoke        --armor $KEYID > /media/OFFLINE/revoke.asc
```

### 2. Create a subkey set per device

```bash
gpg --expert --edit-key $KEYID
  addkey     # RSA (sign only)
  addkey     # RSA (encrypt only)
  addkey     # RSA (authenticate only) — for SSH, optional
  save
```

### 3. Put only subkeys on the device

```bash
# All subkeys, master secret stripped:
gpg --export-secret-subkeys $KEYID > device-subkeys.asc
# …or only specific subkeys (note the trailing ! on each keyid):
gpg --export-secret-subkeys 0xSUBKEY1! 0xSUBKEY2! > device-subkeys.asc

# On the device:
gpg --import device-subkeys.asc
gpg --list-secret-keys      # primary shows sec#  ← master secret absent
```

### 4. Strip the master from a machine that currently holds everything

After the offline backup in step 1:

```bash
gpg --export-secret-subkeys $KEYID > subs.asc
gpg --delete-secret-keys    $KEYID          # removes master + subs (backup exists!)
gpg --import subs.asc                        # re-import subkeys only
gpg --list-secret-keys                       # now sec#
```

### 5. Revoke a lost device

Bring the offline master into a temporary/air-gapped session:

```bash
gpg --edit-key $KEYID
  key 3        # select the lost device's subkey(s) by index
  revkey
  save
gpg --export --armor $KEYID > pubkey.asc     # redistribute where the key is used
```

---

## Secure deletion of exported secret material

`shred` (Linux) / `gshred` (macOS via `brew install coreutils`) / `rm -P` (BSD)
overwrite before unlinking, **but none reliably erase on SSD/APFS** — wear
leveling and copy-on-write leave remnants. The real protections:

- **Full-disk encryption** (FileVault on macOS, LUKS on Linux) is what actually
  guards remnants — with it on, `rm -f` is effectively sufficient.
- Exported secret keys are **passphrase-encrypted** by `gpg`, so a strong
  passphrase protects the file even if a copy survives.
- **Avoid writing secret exports to disk at all**, especially on a managed/work
  machine where backup/EDR tooling may capture the file the moment it's written.
  Pipe straight to the destination instead:

  ```bash
  gpg --export-secret-keys $KEYID | ssh you@other 'gpg --import'
  ```
