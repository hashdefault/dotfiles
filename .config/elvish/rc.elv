# ~/.config/elvish/rc.elv
# Config for trying out Elvish as a daily-driver candidate. Mirrors the
# xonsh setup at ~/.config/xonsh/rc.xsh where it makes sense (same prompt,
# same tool replacements, same aliases ported from
# ~/.config/fish/config.fish) so the shells feel consistent while testing.
#
# Note on a real Elvish gotcha hit while writing this: `fn name { ... }`
# inside an `if { ... }` block only defines `name` *inside that block* --
# it does not leak out, even when the branch runs. So every alias that
# depends on whether a tool is installed is defined unconditionally at the
# top level, and branches *internally* on a precomputed `has-external`
# flag instead of being conditionally defined.

use str
use path
use platform

# =============================================================================
# Environment
# =============================================================================

if (path:is-dir ~/.local/bin) {
  set paths = [~/.local/bin $@paths]
}
if (path:is-dir ~/bin) {
  set paths = [~/bin $@paths]
}

if (has-external nvim) {
  set-env EDITOR nvim
} elif (has-external vim) {
  set-env EDITOR vim
} else {
  set-env EDITOR nano
}
set-env VISUAL $E:EDITOR

var has-bat = (has-external bat)
if $has-bat {
  set-env PAGER "bat --paging=always --style=plain"
  set-env MANPAGER "bat --paging=always --style=plain --language=man"
} else {
  set-env PAGER "less -R"
}

# =============================================================================
# Prompt: starship (same look as the xonsh setup, see ~/.config/starship.toml)
# =============================================================================

if (has-external starship) {
  set-env STARSHIP_SHELL elvish
  eval (e:starship init elvish --print-full-init | slurp)
}

# =============================================================================
# Smarter navigation: zoxide ("z" / "zi")
# =============================================================================
#
# Fish's config aliases `cd` itself to `z`; that doesn't translate cleanly
# here. zoxide's init script registers `z`/`zi` via `edit:add-var`, which
# only wires them into the *interactive* line editor's namespace -- typing
# `z foo` at the prompt works, but a `fn cd {...}` defined statically in
# this same file can't see `z` at all (elvish compiles the whole rc file as
# one static unit, before the dynamic `eval` below has run). Hacking around
# that would mean reimplementing zoxide's own matching/history logic here,
# so instead: use plain `cd` for exact paths, `z`/`zi` for jumps, as zoxide
# itself documents for elvish.

if (has-external zoxide) {
  eval (e:zoxide init elvish | slurp)
}

# =============================================================================
# Aliases (elvish has no `alias` builtin -- these are thin wrapper functions)
# =============================================================================

fn reload {
  eval (slurp < ~/.config/elvish/rc.elv)
}

fn edit-config { e:$E:EDITOR ~/.config/elvish/rc.elv }

# --- modern replacements for classic tools, when present --------------------

var has-eza = (has-external eza)
var has-rg = (has-external rg)
var has-fd = (has-external fd)

fn ls {|@a|
  if $has-eza { e:eza --group-directories-first --icons $@a } else { e:ls --color=auto $@a }
}
fn l {|@a|
  if $has-eza { e:eza -l --icons $@a } else { e:ls -lh --color=auto $@a }
}
fn ll {|@a|
  if $has-eza { e:eza -l --group-directories-first --icons --git $@a } else { e:ls -lh --color=auto $@a }
}
fn la {|@a|
  if $has-eza { e:eza -la --group-directories-first --icons --git $@a } else { e:ls -lAh --color=auto $@a }
}
fn lt {|@a|
  if $has-eza { e:eza --tree --level=2 --icons $@a } else { e:find $@a }
}

fn cat {|@a|
  if $has-bat { e:bat --style=plain --paging=never $@a } else { e:cat $@a }
}

fn grep {|@a|
  if $has-rg { e:rg $@a } else { e:grep $@a }
}

fn find {|@a|
  if $has-fd { e:fd $@a } else { e:find $@a }
}

fn cls { clear }

# --- git shortcuts ------------------------------------------------------------

fn g {|@a| e:git $@a }
fn gs {|@a| e:git status -sb $@a }
fn ga {|@a| e:git add $@a }
fn gaa { e:git add -A }
fn gc {|@a| e:git commit -v $@a }
fn gcm {|@a| e:git commit -m $@a }
fn gp {|@a| e:git push $@a }
fn gpl { e:git pull --ff-only }
fn gl { e:git log --oneline --graph --decorate -20 }
fn gla { e:git log --oneline --graph --decorate --all }
fn gd {|@a| e:git diff $@a }
fn gds { e:git diff --staged }
fn gco {|@a| e:git checkout $@a }
fn gb {|@a| e:git branch $@a }
fn gsw {|@a| e:git switch $@a }
fn gstash {|@a| e:git stash $@a }

# --- ported from ~/.config/fish/config.fish ----------------------------------
# (DEEPSEEK_API_KEY from that file is intentionally NOT ported -- it's a live
# secret sitting in plaintext there; worth moving to a proper secret store.
# Everything below is defined unconditionally: if the underlying tool isn't
# installed, calling it just fails with a normal "not found" error.)

fn vim {|@a| e:nvim $@a }
fn zed {|@a| e:zeditor $@a }
fn lg { e:lazygit }
fn mkdir {|@a| e:mkdir -pv $@a }
fn q { e:qs -c ii }

fn update { sudo pacman -Syu }
fn updatelist { sudo pacman -Syyu }
fn yaysua { e:yay -Sua --noconfirm }
fn yaysyu { e:yay -Syu --noconfirm }
fn unlock { sudo rm /var/lib/pacman/db.lck }

fn cleanup {
  var raw = ""
  try {
    set raw = (pacman -Qtdq | slurp)
  } catch {
    set raw = ""
  }
  var orphans = [(each {|p| if (!=s $p "") { put $p } } [(str:split "\n" $raw)])]
  if (== (count $orphans) 0) {
    echo "cleanup: no orphaned packages"
  } else {
    sudo pacman -Rns $@orphans
  }
}

fn dockerphp8 {
  try {
    docker container stop php7_mariadb php7_phpmyadmin php7_apache
  } catch {
    return
  }
  docker container start php8_mariadb php8_phpmyadmin php8_apache
}

fn dockerphp7 {
  try {
    docker container stop php8_mariadb php8_phpmyadmin php8_apache
  } catch {
    return
  }
  docker container start php7_mariadb php7_phpmyadmin php7_apache
}

# --- small helper functions ---------------------------------------------------

fn mkcd {|dir|
  mkdir -p $dir
  cd $dir
}

fn up {|@a|
  var n = 1
  if (> (count $a) 0) { set n = (num $a[0]) }
  var target = (str:join / [(repeat $n "..")])
  if (==s $target "") { set target = ".." }
  cd $target
}

fn extract {|f|
  if (not (path:is-regular $f)) {
    echo "extract: no such file: "$f
    return
  }
  if (or (str:has-suffix $f ".tar.gz") (str:has-suffix $f ".tgz")) {
    tar xzf $f
  } elif (or (str:has-suffix $f ".tar.bz2") (str:has-suffix $f ".tbz2")) {
    tar xjf $f
  } elif (str:has-suffix $f ".tar.xz") {
    tar xJf $f
  } elif (str:has-suffix $f ".tar") {
    tar xf $f
  } elif (str:has-suffix $f ".zip") {
    unzip $f
  } elif (str:has-suffix $f ".rar") {
    unrar x $f
  } elif (str:has-suffix $f ".gz") {
    gunzip $f
  } elif (str:has-suffix $f ".7z") {
    e:7z x $f
  } else {
    echo "extract: don't know how to extract '"$f"'"
  }
}

fn weather {|@a|
  var location = ""
  if (> (count $a) 0) { set location = $a[0] }
  curl -s "https://wttr.in/"$location"?format=3"
}

fn backup {|f|
  if (not (path:is-regular $f)) {
    echo "backup: no such file: "$f
    return
  }
  var stamp = (date +%Y%m%d%H%M%S)
  var dst = $f".bak."$stamp
  cp $f $dst
  echo "backup: "$f" -> "$dst
}
