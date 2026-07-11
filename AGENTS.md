# Repository Guidelines

## Project Structure & Module Organization
This repository stores personal dotfiles managed by Tuckr. Most changes belong under `Configs/`, where each top-level directory maps to one application or tool, for example `Configs/neovim/.config/nvim`, `Configs/hyprland/.config/hypr`, and `Configs/yazi/.config/yazi`. Keep new files inside the target app's existing subtree rather than creating parallel layouts.

Top-level support files are minimal: `README.md` covers installation, `font-test.sh` is a quick terminal font smoke test, `pkglist.txt` tracks packages, and `Hooks/` is reserved for repo hooks.

## Build, Test, and Development Commands
Use Tuckr to install and verify the dotfiles:

- `tuckr add '*'` installs all managed configs into the home directory.
- `tuckr status` shows whether installed links match the repository state.
- `bash font-test.sh` prints glyph and style samples for terminal/font verification.
- `bash -n Configs/bash/.bashrc Configs/hyprland/.config/hypr/scripts/*.sh` checks shell syntax before commit.
- `python3 -m py_compile Configs/hyprland/.config/hypr/scripts/uptime.py` validates the Python helper script.

## Coding Style & Naming Conventions
Match the style of the file you are editing. Shell code in this repo uses Bash with four-space indentation and snake_case function names such as `clean_old_tasks`. Lua config files use tabs and lower-case module filenames like `lua/plugins/telescope.lua`. Keep TOML, KDL, INI, and Hyprland config filenames descriptive and lowercase.

Use the formatter implied by the Neovim setup when possible: `shfmt` for shell, `stylua` for Lua, `taplo` for TOML, `prettier` for JSON/SCSS/Markdown, and `kdlfmt` for KDL.

## Testing Guidelines
There is no centralized automated test suite, so validate only what you touched. Re-run syntax checks for edited scripts, run `tuckr status`, and manually verify UI-facing changes in the relevant app. For Hyprland, Wayle, Kitty, or Yazi changes, include a short note on what was exercised; screenshots are useful when appearance or layout changed.

## Commit & Pull Request Guidelines
Recent history follows short, scoped subjects such as `hyprland: integrate hyprscratch scratchpads` and `fix(wayle): stop expanding bash aliases in scripts`. A scope is mandatory for every commit message. Use one of these patterns: `<scope>: imperative summary`, `feat(<scope>): imperative summary` for new functionality, or `fix(<scope>): imperative summary` for bug fixes.

Keep commits focused on one tool or subsystem. Pull requests should explain affected paths, describe manual verification, and link related issues or task IDs when applicable.

## Yazi Plugins
When installing a Yazi plugin under `Configs/yazi/.config/yazi/plugins/`, add its directory to `Configs/yazi/.config/yazi/.gitignore`. Installed plugin sources are not tracked; commit only the Yazi configuration that enables or configures the plugin (such as `init.lua`, `keymap.toml`, `theme.toml`, or `package.toml`).
