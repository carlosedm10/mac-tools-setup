# Architecture

## Overview

This repo is a thin orchestration layer for macOS machine setup. Each setup phase lives in its own module under `steps/`. `install` delegates to those modules and adds cross-cutting concerns: dependency bootstrap, completion tracking, gum-based group selection, and status reporting.

```
┌─────────────────────────────────────────────────────────────────┐
│  install  (mac-tools-setup)                                     │
│  Flags: --fresh · --dry-run · --status                          │
└────────────┬────────────────────────────────────────────────────┘
             │
    ┌────────┴────────┐
    │                 │
┌───▼──────────┐  ┌───▼──────────────────────────────────────────┐
│  lib/        │  │  steps/                                       │
│  deps.sh     │  │  dev_deps.sh  → homebrew + colima + dev_tools + direnv │
│  ui.sh       │  │  apps.sh      → GUI casks by category         │
│  helpers.sh  │  │  ide.sh       → Cursor + extensions           │
│  settings.sh │  │  github.sh    → git config + SSH              │
│  apps_catalog│  │  skills.sh    → agent-skills-template (bunx)  │
│  github_ssh.sh│ │  (homebrew, colima, dev_tools, direnv, ghostty) │
└──────────────┘  └──────────────────────────────────────────────┘
```

## Entry Points

| Script | Role |
|--------|------|
| `install` | Interactive setup: gum group picker, optional app category picker, run phases, track completion |

## Picker Groups

| Group | Resolves to |
|-------|-------------|
| **All** | Every tracked step |
| **Dev deps** | `dev-deps` (Homebrew, Xcode CLT, Oh My Zsh, languages, direnv) |
| **GitHub** | `github` (Git config + SSH) |
| **Apps** | Second gum picker → one or more app categories |
| **IDE** | `ide` (Cursor cask + extensions) |
| **Agent skills** | `skills` (`bunx agent-skills-template` install; runs last) |

## App Categories

Defined in `lib/apps_catalog.sh`:

| Category | Casks | Formulae |
|----------|-------|----------|
| Internet | Arc, Tailscale | — |
| Messaging | Slack, Telegram, WhatsApp | — |
| Video | Blender, VLC, Zoom, Fathom | — |
| Coding & tools | DBeaver, Docker, MongoDB Compass, Postman, Wireshark, UTM, Ghostty, Claude Code | OpenCode |

Each category is tracked separately as `apps-internet`, `apps-messaging`, `apps-video`, `apps-coding`.

## Bootstrap Sequence

When you run `./install`:

1. **Re-execs with Bash 4+** — `lib/deps.sh` finds or installs Homebrew bash and re-execs.
2. **Bootstraps Homebrew** — if `brew` is missing, runs homebrew before gum/deps.
3. **Sources modules** — `ui.sh` → `helpers.sh` → `apps_catalog.sh` → `settings.sh` → all `steps/*.sh`.
4. **Installs orchestration deps** — `install_mac_setup_dependencies` (bash, gum, jq).
5. **Prints status table** — each tracked step shows `done` or `pending`.
6. **Top-level gum multi-select** — All, Dev deps, GitHub, Apps, IDE, Agent skills.
7. **App category picker** — shown when Apps is selected (skipped when All is selected).
8. **Confirms** — `gum confirm` before mutations.
9. **Dispatches** — runs steps in registry order; marks each successful step completed.

## Step Registry

Execution order (always preserved):

1. `dev-deps`
2. `github`
3. `apps-internet`, `apps-messaging`, `apps-video`, `apps-coding` (as selected)
4. `ide`
5. `skills`

| Step | Module | Key mechanism |
|------|--------|---------------|
| `dev-deps` | `steps/dev_deps.sh` | Chains homebrew, colima config, dev_tools, direnv, ghostty config |
| `apps-*` | `steps/apps.sh` | Casks + optional formulae per category; coding syncs Ghostty config |
| `ide` | `steps/ide.sh` | Cursor cask + `cursor --install-extension` |
| `skills` | `steps/skills.sh` | `bunx agent-skills-template@latest install -y` (gum platform picker) |
| `github` | `steps/github.sh` + `lib/github_ssh.sh` | `gum input` + SSH key setup |

## Module Responsibilities

**`lib/deps.sh`** — Bash 4+, `gum`, `jq` bootstrap via Homebrew.

**`lib/ui.sh`** — Terminal output and gum wrappers (`gum_select_multi_defaults`, status table).

**`lib/helpers.sh`** — `backup_file`, `ensure_brew_shellenv`, nvm install/load.

**`lib/apps_catalog.sh`** — App category labels and cask lists.

**`lib/settings.sh`** — Completion persistence at `~/.config/mac-setup/settings.json`.

**`lib/github_ssh.sh`** — GitHub SSH key, agent, config, connectivity test.

## Completion Tracking

```json
{
  "completed_steps": ["dev-deps", "apps-internet", "ide"],
  "last_run": "2026-05-28T12:00:00Z"
}
```

- First run or `--fresh`: **All** is pre-selected in the top-level picker.
- Later runs: pending groups/categories are pre-selected.
- Re-select a completed item manually to run it again.

## Command Flow

**`./install` (default)**

```
install → bootstrap Homebrew (if missing)
        → top-level gum picker
        → [if Apps] app category gum picker
        → resolve groups → ordered steps
        → gum confirm
        → _run_step (each step) → settings_mark_completed
        → summary + status table
```

## Files & Structure

```
mac-tools-setup/
├── install
├── lib/
│   ├── deps.sh
│   ├── ui.sh
│   ├── helpers.sh
│   ├── apps_catalog.sh
│   ├── settings.sh
│   └── github_ssh.sh
├── config/
│   ├── colima/          # bundled colima.yaml → ~/.colima/default/colima.yaml
│   ├── ghostty/         # bundled config + themes/ayu → ~/.config/ghostty
│   └── zsh/
│       └── zshrc        # bundled shell config → ~/.zshrc (dev-deps)
├── steps/
│   ├── homebrew.sh      # internal (dev-deps)
│   ├── colima.sh        # internal (dev-deps)
│   ├── dev_tools.sh     # internal (dev-deps)
│   ├── direnv.sh        # internal (dev-deps)
│   ├── ghostty.sh       # internal (dev-deps, apps-coding)
│   ├── dev_deps.sh
│   ├── apps.sh
│   ├── ide.sh
│   ├── skills.sh
│   └── github.sh
├── docs/
│   └── ARCHITECTURE.md
└── README.md
```
