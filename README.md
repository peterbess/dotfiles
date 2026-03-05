# Dotfiles

Reproducible, minimal macOS development environment for Apple Silicon Macs. Takes a fresh machine from first boot to "ready to work" with one script and a few manual steps.

## Fresh Mac setup

Start here on a brand new macOS install. If you already have Homebrew and 1Password, skip to [Quick start](#quick-start).

### 1. Set the hostname

macOS defaults to something like "Peter's MacBook Air" which shows up in your terminal prompt, Bonjour, and Finder. Fix it early:

```bash
sudo scutil --set ComputerName "your-hostname"
sudo scutil --set HostName "your-hostname"
sudo scutil --set LocalHostName "your-hostname"
```

LocalHostName must be alphanumeric and hyphens only (no spaces). Close Terminal entirely and reopen it to see the change in your prompt.

### 2. Install Xcode Command Line Tools

```bash
xcode-select --install
```

This provides `git`, `clang`, and other basics. Follow the dialog prompt.

### 3. Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

After it finishes, run the `eval` command it prints to add Homebrew to your PATH for the current session. (The dotfiles zshrc handles this permanently once installed.)

**Note:** If Homebrew's post-install instructions led you to create a `~/.zprofile`, the install script detects and removes it automatically — the dotfiles zshrc handles Homebrew's PATH.

### 4. Install and configure 1Password

```bash
brew install --cask 1password
```

Open 1Password, sign in to your account, then enable the SSH agent:

1. 1Password > Settings > Developer
2. Enable **Set up SSH Agent**
3. Enable **Integrate with 1Password CLI** (optional but useful)

Then point your current shell at the 1Password agent so SSH works before the dotfiles are installed:

```bash
export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
```

This is a temporary one-session export. The dotfiles `zshenv` sets it permanently once installed.

### 5. Add your SSH key to GitHub

In 1Password, find your SSH key and copy the public key. Add it to GitHub in two places:

1. [github.com/settings/ssh/new](https://github.com/settings/ssh/new) — as an **Authentication key**
2. Same page — as a **Signing key**

Verify it works:

```bash
ssh -T git@github.com
```

You should see "Hi [username]! You've successfully authenticated."

### 6. Clone and install

```bash
git clone git@github.com:peterbess/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh --dry-run    # preview first
./install.sh              # run for real
```

Homebrew cask installs will prompt for your admin password.

If you have existing config files (e.g., from Migration Assistant), use `./install.sh --force` to back them up to `~/.dotfiles-backup/` and replace them with symlinks.

### 7. Open a new terminal tab

Your new shell configuration takes effect in new sessions. Open a new tab and confirm:

```bash
which uv               # should resolve to /opt/homebrew/bin/uv
git config user.name   # should show your name
echo $SSH_AUTH_SOCK    # should show the 1Password agent path
cd ~/dotfiles && git log --show-signature -1   # should show "Good signature"
```

**Note:** The install script will show a warning that `~/.local/bin` is not on your PATH. This is expected — it's referring to the old shell session. The new tab picks up the correct PATH from zshrc.

### 8. iTerm2 (optional)

The Brewfile installs iTerm2. Font and color preferences are not managed by dotfiles — configure them in iTerm2 > Settings > Profiles. The repo uses Monaspace Argon as the coding font.

---

## Quick start

```bash
# Clone the repo
git clone git@github.com:peterbess/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Preview what will happen
./install.sh --dry-run

# Run for real
./install.sh

# If existing config files conflict, back them up and replace
./install.sh --force
```

`--force` moves conflicting files to `~/.dotfiles-backup/<timestamp>/` before creating symlinks. Without it, conflicts produce a warning and skip.

To update an existing install, pull and re-run:

```bash
cd ~/dotfiles && git pull && ./install.sh
```

**Important:** Scripts expect the repo cloned to `~/dotfiles`. Do not rename or move it. Open a new terminal tab after installing for changes to take effect.

## What it does

The installer runs three steps in order:

1. **Symlinks** — Links config files from this repo to their expected locations (`~/.gitconfig`, `~/.zshrc`, etc.). Idempotent: re-running skips links that already point to the right place.

2. **Homebrew packages** — Runs `brew bundle` against the Brewfile, then installs Python 3.12 via uv (not Homebrew, to avoid venv breakage on upgrades).

3. **macOS defaults** — Prompted interactively. Applies Finder, Dock, keyboard, and other `defaults write` settings, each verified after write. Skipped in dry-run mode.

## What's managed

| File | Symlinked to | Purpose |
|------|-------------|---------|
| `gitconfig` | `~/.gitconfig` | Git defaults, SSH commit signing via 1Password |
| `zshenv` | `~/.zshenv` | Environment vars for all shell contexts (SSH agent, EDITOR) |
| `zshrc` | `~/.zshrc` | PATH, history, aliases, git-aware prompt |
| `ssh_config` | `~/.ssh/config` | 1Password agent, `Include config.d/*` for host entries |
| `allowed_signers` | `~/.ssh/allowed_signers` | Maps email to public key for local signature verification |
| `Brewfile` | *(not symlinked)* | Declarative package list: git, gh, uv, 1Password, iTerm2, fonts |

### Scripts

| Script | Purpose |
|--------|---------|
| `scripts/symlinks.sh` | Creates symlinks, sets SSH permissions (700/600) |
| `scripts/brew.sh` | Runs brew bundle, installs Python via uv |
| `scripts/macos.sh` | Applies macOS defaults with verify-after-write |

Each script is independently runnable with `--dry-run`.

### SSH host entries

Private host configs (IPs, usernames) go in `~/.ssh/config.d/hosts.local`, which is gitignored. See `ssh_config.d/hosts.example` for the template.

## Design philosophy

Every line in every config file should be explainable. No cargo-culting, no plugin frameworks, no features added "just in case." Start minimal, add when it hurts. See `SPEC.md` for the full specification.

## Uninstall

Symlinks can be removed individually (e.g., `rm ~/.gitconfig ~/.zshrc ~/.zshenv ~/.ssh/config ~/.ssh/allowed_signers`). Backups from `--force` runs are in `~/.dotfiles-backup/`. To remove Homebrew packages not in the Brewfile: `brew bundle cleanup --file=Brewfile`. To remove uv-managed Python: `uv python uninstall 3.12`.

## Prerequisites

- macOS on Apple Silicon (see [Fresh Mac setup](#fresh-mac-setup) for full walkthrough)
- [Homebrew](https://brew.sh)
- [1Password](https://1password.com) with SSH agent enabled
