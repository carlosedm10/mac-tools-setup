#!/usr/bin/env bash
# Developer dependencies: Homebrew, dev tools, direnv

step_dev_deps_run() {
  step_homebrew_run || return 1
  step_dev_tools_run || return 1
  step_direnv_run || return 1
  step_ghostty_run || return 1
}
