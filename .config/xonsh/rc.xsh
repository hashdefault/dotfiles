#!/usr/bin/env xonsh
# ~/.config/xonsh/rc.xsh
# Feature-rich xonsh configuration.

import os
import shutil
import subprocess
import datetime
from pathlib import Path

# =============================================================================
# Environment
# =============================================================================

$EDITOR = "nvim" if shutil.which("nvim") else ("vim" if shutil.which("vim") else "nano")
$VISUAL = $EDITOR
$PAGER = "bat --paging=always --style=plain" if shutil.which("bat") else "less -R"
$MANPAGER = "bat --paging=always --style=plain --language=man" if shutil.which("bat") else "less -R"
$LESS = "-R"

# Keep eza readable on transparent/dark terminals. The inherited LS_COLORS on
# this system makes directories/executables bold black, which hides names.
$EZA_COLORS = "di=1;34:ex=1;32:fi=37:ln=36:*.php=38;5;141:*.js=38;5;178:*.ts=38;5;74"

$XONSH_COLOR_STYLE = "gruvbox-dark"
$XONSH_HISTORY_SIZE = "1000000 commands"
$XONSH_HISTORY_BACKEND = "sqlite"
$XONSH_HISTORY_MATCH_ANYWHERE = True
$XONSH_HISTORY_SAVE_CWD = True
$XONSH_SHOW_TRACEBACK = False
$XONSH_STORE_STDOUT = True

# Behave more like a "normal" interactive shell.
$AUTO_CD = True
$AUTO_PUSHD = True
$CDPATH = [$HOME]

# Completion / suggestion niceties.
# XONSH_PROMPT_AUTO_SUGGEST is the fish-style feature: a single greyed-out
# inline suggestion from history, accepted with -> / End. That's the good
# part. The rest (subsequence/fuzzy matching + auto-popup on every keypress)
# is what turns Tab-completion into a wall of unrelated matches -- keep it
# off, and let completions show a plain single-column list on Tab only.
$XONSH_PROMPT_AUTO_SUGGEST = True
$AUTO_SUGGEST_IN_COMPLETIONS = True
$COMPLETIONS_CONFIRM = True
$COMPLETIONS_DISPLAY = "single"
$COMPLETION_QUERY_LIMIT = 100
$UPDATE_COMPLETIONS_ON_KEYPRESS = False
$SUBSEQUENCE_PATH_COMPLETION = False
$FUZZY_PATH_COMPLETION = False
$MOUSE_SUPPORT = True
$SUGGEST_COMMANDS = True
$XONSH_AUTOPAIR = True

# Keep the terminal title informative.
$TITLE = "{current_job:{} | }{user}@{hostname}: {cwd}"

# Make sure user-local binaries are reachable.
for _p in (f"{$HOME}/.local/bin", f"{$HOME}/bin"):
    if os.path.isdir(_p) and _p not in $PATH:
        $PATH.insert(0, _p)
del _p

# =============================================================================
# Prompt: native xonsh, without an external prompt renderer.
# =============================================================================

from xonsh.prompt.vc import current_branch, dirty_working_directory


def _native_powerline_prompt():
    # Build the transitions from the segments actually present.
    branch = current_branch()
    segments = [
        ("#ffb454", "#161616", " 󰣇 {user} "),
        ("#d85c47", "#ffffff", " 󰉋 {cwd} "),
    ]
    if branch:
        $PROMPT_FIELDS["powerline_branch"] = branch
        dirty = " *" if dirty_working_directory() else ""
        segments.append(("#367d77", "#ffffff", " 󰘬 {powerline_branch}" + dirty + " "))
    if __xonsh__.env.get("VIRTUAL_ENV"):
        $PROMPT_FIELDS["powerline_venv"] = Path($VIRTUAL_ENV).name
        segments.append(("#655b85", "#ffffff", "  {powerline_venv} "))

    parts = ["\n"]
    for i, (background, foreground, label) in enumerate(segments):
        parts.append("{BACKGROUND_" + background + "}{" + foreground + "}" + label)
        parts.append("{RESET}{" + background + "}")
        if i + 1 < len(segments):
            parts.append("{BACKGROUND_" + segments[i + 1][0] + "}")
        parts.append("")
    parts.append(
        "{RESET}\n"
        "{#ff5f4d}{last_return_code_if_nonzero:[{}] }{RESET}"
        "{BOLD_#ffb454}❯{RESET} "
    )
    return "".join(parts)


$PROMPT = _native_powerline_prompt
$RIGHT_PROMPT = ""
$MULTILINE_PROMPT = "{#6b5636}·{RESET}"

# =============================================================================
# Smarter navigation: zoxide ("z" / "zi") if installed.
# =============================================================================

if shutil.which("zoxide"):
    execx($(zoxide init xonsh))
    # Mirrors this user's fish config (`alias cd='z'`): plain "cd" now goes
    # through zoxide's frecency jumping, falling back to a normal cd for an
    # exact existing path.
    aliases["cd"] = aliases["z"]

# =============================================================================
# Aliases
# =============================================================================

aliases["reload"] = f"source {$XONSH_CONFIG_DIR}/rc.xsh"
aliases["edit-config"] = f"{$EDITOR} {$XONSH_CONFIG_DIR}/rc.xsh"

# --- Modern replacements for classic tools, when present -------------------

if shutil.which("eza"):
    aliases["ls"] = "eza --group-directories-first --icons=always --color=always"
    aliases["l"] = "eza -l --icons=always --color=always"
    aliases["ll"] = "eza -l --group-directories-first --icons=always --color=always --git"
    aliases["la"] = "eza -la --group-directories-first --icons=always --color=always --git"
    aliases["lt"] = "eza --tree --level=2 --icons=always --color=always"
else:
    aliases["ll"] = "ls -lh --color=auto"
    aliases["la"] = "ls -lAh --color=auto"

if shutil.which("bat"):
    aliases["cat"] = "bat --style=plain --paging=never"

if shutil.which("rg"):
    aliases["grep"] = "rg"

if shutil.which("fd"):
    aliases["find"] = "fd"

aliases["cls"] = "clear"
aliases[".."] = "cd .."
aliases["..."] = "cd ../.."
aliases["...."] = "cd ../../.."
aliases["-"] = "cd -"

# --- git shortcuts -----------------------------------------------------------

aliases["g"] = "git"
aliases["gs"] = "git status -sb"
aliases["ga"] = "git add"
aliases["gaa"] = "git add -A"
aliases["gc"] = "git commit -v"
aliases["gcm"] = "git commit -m"
aliases["gp"] = "git push"
aliases["gpl"] = "git pull --ff-only"
aliases["gl"] = "git log --oneline --graph --decorate -20"
aliases["gla"] = "git log --oneline --graph --decorate --all"
aliases["gd"] = "git diff"
aliases["gds"] = "git diff --staged"
aliases["gco"] = "git checkout"
aliases["gb"] = "git branch"
aliases["gsw"] = "git switch"
aliases["gstash"] = "git stash"

# --- ported from ~/.config/fish/config.fish ---------------------------------
# (DEEPSEEK_API_KEY from that file is intentionally NOT ported here -- it's a
# live secret sitting in plaintext; see the chat for a note about that.)

aliases["vim"] = "nvim"
if shutil.which("zeditor"):
    aliases["zed"] = "zeditor"
if shutil.which("lazygit"):
    aliases["lg"] = "lazygit"
aliases["mkdir"] = "mkdir -pv"
if shutil.which("qs"):
    aliases["q"] = "qs -c ii"

aliases["update"] = "sudo pacman -Syu"
aliases["updatelist"] = "sudo pacman -Syyu"
if shutil.which("yay"):
    aliases["yaysua"] = "yay -Sua --noconfirm"
    aliases["yaysyu"] = "yay -Syu --noconfirm"
aliases["unlock"] = "sudo rm /var/lib/pacman/db.lck"


def _cleanup(args):
    """cleanup: remove orphaned pacman packages (DANGEROUS, matches fish alias)."""
    try:
        orphans = $(pacman -Qtdq).split()
    except Exception:
        orphans = []
    if not orphans:
        print("cleanup: no orphaned packages")
        return
    sudo pacman -Rns @(orphans)


aliases["cleanup"] = _cleanup


def _dockerphp8(args):
    if ![docker container stop php7_mariadb php7_phpmyadmin php7_apache].rtn == 0:
        docker container start php8_mariadb php8_phpmyadmin php8_apache


aliases["dockerphp8"] = _dockerphp8


def _dockerphp7(args):
    if ![docker container stop php8_mariadb php8_phpmyadmin php8_apache].rtn == 0:
        docker container start php7_mariadb php7_phpmyadmin php7_apache


aliases["dockerphp7"] = _dockerphp7

# --- small helper functions ---------------------------------------------------


def _mkcd(args):
    """mkcd <dir>: create a directory (with parents) and cd into it."""
    if not args:
        print("usage: mkcd <dir>")
        return 1
    path = args[0]
    os.makedirs(path, exist_ok=True)
    cd @(path)


aliases["mkcd"] = _mkcd


def _up(args):
    """up [n]: cd up n directories (default 1)."""
    n = int(args[0]) if args else 1
    target = "/".join([".."] * n) or ".."
    cd @(target)


aliases["up"] = _up


def _extract(args):
    """extract <archive>: unpack common archive formats automatically."""
    if not args:
        print("usage: extract <file>")
        return 1
    target = Path(args[0])
    if not target.exists():
        print(f"extract: no such file: {target}")
        return 1
    name = target.name.lower()
    if name.endswith((".tar.gz", ".tgz")):
        tar xzf @(target)
    elif name.endswith((".tar.bz2", ".tbz2")):
        tar xjf @(target)
    elif name.endswith(".tar.xz"):
        tar xJf @(target)
    elif name.endswith(".tar"):
        tar xf @(target)
    elif name.endswith(".zip"):
        unzip @(target)
    elif name.endswith(".rar"):
        unrar x @(target)
    elif name.endswith(".gz"):
        gunzip @(target)
    elif name.endswith(".7z"):
        subprocess.run(["7z", "x", str(target)])
    else:
        print(f"extract: don't know how to extract '{target}'")
        return 1


aliases["extract"] = _extract


def _weather(args):
    """weather [location]: quick terminal weather report via wttr.in."""
    location = args[0] if args else ""
    curl -s @(f"https://wttr.in/{location}?format=3")


aliases["weather"] = _weather


def _backup(args):
    """backup <file>: copy file to file.bak.<timestamp>."""
    if not args:
        print("usage: backup <file>")
        return 1
    src = Path(args[0])
    if not src.exists():
        print(f"backup: no such file: {src}")
        return 1
    stamp = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
    dst = src.with_name(f"{src.name}.bak.{stamp}")
    shutil.copy2(src, dst)
    print(f"backup: {src} -> {dst}")


aliases["backup"] = _backup

# =============================================================================
# History / file / directory fuzzy widgets powered by fzf (if installed)
#   Ctrl+R  -> fuzzy-search command history
#   Ctrl+T  -> fuzzy-search files, insert path at cursor
#   Alt+C   -> fuzzy-search directories and cd into the chosen one
# =============================================================================

if shutil.which("fzf"):
    from prompt_toolkit.keys import Keys
    from prompt_toolkit.application import run_in_terminal

    @events.on_ptk_create
    def _fzf_bindings(bindings, prompter, history, completer, **kw):

        @bindings.add(Keys.ControlR)
        def _fzf_history(event):
            buf = event.current_buffer

            def _search():
                items = list(builtins.__xonsh__.history.items())
                lines, seen = [], set()
                for item in reversed(items):
                    cmd = str(item["inp"]).rstrip("\n")
                    if cmd and cmd not in seen:
                        seen.add(cmd)
                        lines.append(cmd)
                seed = "\n".join(lines)
                try:
                    chosen = subprocess.run(
                        ["fzf", "--height=40%", "--reverse", "--no-sort",
                         "--exact", "--prompt=history> "],
                        input=seed, capture_output=True, text=True,
                    ).stdout.strip()
                except Exception:
                    chosen = ""
                if chosen:
                    buf.text = chosen
                    buf.cursor_position = len(chosen)

            run_in_terminal(_search)

        @bindings.add(Keys.ControlT)
        def _fzf_files(event):
            buf = event.current_buffer

            def _search():
                find_cmd = (["fd", "--hidden", "--follow", "--exclude", ".git"]
                            if shutil.which("fd") else ["find", ".", "-type", "f"])
                try:
                    listing = subprocess.run(find_cmd, capture_output=True, text=True).stdout
                    chosen = subprocess.run(
                        ["fzf", "--height=40%", "--reverse", "--prompt=file> "],
                        input=listing, capture_output=True, text=True,
                    ).stdout.strip()
                except Exception:
                    chosen = ""
                if chosen:
                    buf.insert_text(chosen)

            run_in_terminal(_search)

        @bindings.add(Keys.Escape, "c")
        def _fzf_cd(event):
            buf = event.current_buffer

            def _search():
                find_cmd = (["fd", "--hidden", "--type", "d", "--follow", "--exclude", ".git"]
                            if shutil.which("fd") else ["find", ".", "-type", "d"])
                try:
                    listing = subprocess.run(find_cmd, capture_output=True, text=True).stdout
                    chosen = subprocess.run(
                        ["fzf", "--height=40%", "--reverse", "--prompt=cd> "],
                        input=listing, capture_output=True, text=True,
                    ).stdout.strip()
                except Exception:
                    chosen = ""
                if chosen:
                    buf.text = f"cd {chosen}"
                    buf.cursor_position = len(buf.text)

            run_in_terminal(_search)

# =============================================================================
# Xontribs
# =============================================================================

xontrib load coreutils
