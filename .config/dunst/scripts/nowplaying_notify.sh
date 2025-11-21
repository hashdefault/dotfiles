#!/usr/bin/env bash
# Requisitos:
#   - playerctl
#   - notify-send (libnotify / dunst)
#   - curl ou wget

CACHE_DIR="${HOME}/.cache/aonsoku-nowplaying"
COVER_FILE="$CACHE_DIR/cover.jpg"
mkdir -p "$CACHE_DIR"

last_line=""

# O separador ␟ é só um char estranho pra evitar conflito com espaços
playerctl --follow metadata --format '{{title}}␟{{artist}}␟{{album}}␟{{mpris:artUrl}}' | \
while IFS='␟' read -r title artist album arturl; do
    # evita repetir notificação idêntica
    line="$title␟$artist␟$album␟$arturl"
    [ "$line" = "$last_line" ] && continue
    last_line="$line"

    # se não tem título, nem manda nada
    [ -z "$title" ] && continue

    [ -z "$artist" ] && artist="Artista desconhecido"
    [ -z "$album" ] && album="Álbum desconhecido"

    icon=""

    # Tenta descobrir a capa do álbum
    if [ -n "$arturl" ]; then
        case "$arturl" in
            file://*)
                # caminho local (file:///home/...)
                path="${arturl#file://}"
                # decodifica %20 etc
                path="$(printf '%b' "${path//%/\\x}")"
                [ -f "$path" ] && icon="$path"
                ;;
            http://*|https://*)
                # baixa a imagem pra cache
                if command -v curl >/dev/null 2>&1; then
                    curl -fsSL "$arturl" -o "$COVER_FILE" && icon="$COVER_FILE"
                elif command -v wget >/dev/null 2>&1; then
                    wget -qO "$COVER_FILE" "$arturl" && icon="$COVER_FILE"
                fi
                ;;
        esac
    fi

    body="$artist\n$album"

    if [ -n "$icon" ]; then
        notify-send -a "Now Playing" -i "$icon" "🎵 $title" "$body"
    else
        notify-send -a "Now Playing" "🎵 $title" "$body"
    fi
done

