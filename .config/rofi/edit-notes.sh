#!/usr/bin/env bash
# Quick note picker powered by rofi; lets you open or create notes from a single menu.
set -euo pipefail

theme="${ROFI_THEME:-$HOME/.config/rofi/theme.rasi}"
notes_dir="${NOTES_DIR:-$HOME/notes}"
fallback_dir="$HOME/Documents/notes"

if [[ ! -d "$notes_dir" ]]; then
  if [[ -d "$fallback_dir" ]]; then
    notes_dir="$fallback_dir"
  else
    mkdir -p "$notes_dir"
  fi
fi

editor="${VISUAL:-${EDITOR:-nvim}}"

mapfile -t files < <(find "$notes_dir" -maxdepth 2 -type f \( -name "*.md" -o -name "*.txt" -o -name "*.org" \) -print | sed "s|^$notes_dir/||" | sort -f)

menu=( "New note…" )
for file in "${files[@]}"; do
  [[ -n "$file" ]] && menu+=("$file")
done

selection=$(printf '%s\n' "${menu[@]}" | rofi -dmenu -i -p "Notes" -theme "$theme" -mesg "Directory: ${notes_dir/$HOME/~}")
[[ -z "$selection" ]] && exit 0

if [[ "$selection" == "New note…" ]]; then
  new_name=$(printf '' | rofi -dmenu -p "Note title" -theme "$theme" -mesg "Will be saved under ${notes_dir/$HOME/~}")
  [[ -z "$new_name" ]] && exit 0
  safe_name="${new_name// /-}"
  [[ "$safe_name" != *.* ]] && safe_name="${safe_name}.md"
  note_path="$notes_dir/$safe_name"
else
  selection="${selection#./}"
  selection="${selection#/}"
  if [[ "$selection" == *".."* ]]; then
    exit 1
  fi
  note_path="$notes_dir/$selection"
fi

mkdir -p "$(dirname "$note_path")"
exec "$editor" "$note_path"
