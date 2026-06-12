#!/usr/bin/env bash
# Waybar module: Opencode-go usage tracker
# Queries the opencode SQLite database for message-level usage data.
# Outputs JSON for Waybar bar display + detailed data for Quickshell popup.
# Requires: sqlite3 (>= 3.9.0 for json_extract), awk, date
# Optional: notify-send (for --notify on-click mode)

DB="$HOME/.local/share/opencode/opencode.db"
WINDOW_H=10
WINDOW_MS=$((WINDOW_H * 60 * 60 * 1000))
NOW_MS=$(($(date +%s) * 1000))
CUTOFF_5H=$((NOW_MS - WINDOW_MS))

# --- Per-window configurable Go limits (USD) ---
# Override with OPENCODE_ROLLING_BUDGET, OPENCODE_WEEKLY_BUDGET, OPENCODE_MONTHLY_BUDGET env vars.
validate_budget() {
    local raw="$1"
    local default="$2"
    awk -v raw="$raw" -v def="$default" 'BEGIN {
        if (raw ~ /^[0-9]+([.][0-9]+)?$/ && raw + 0 > 0) printf "%.2f", raw + 0;
        else printf "%.2f", def;
    }' 2>/dev/null
}

_raw_rolling="${OPENCODE_ROLLING_BUDGET:-90.0}"
_raw_weekly="${OPENCODE_WEEKLY_BUDGET:-30.0}"
_raw_monthly="${OPENCODE_MONTHLY_BUDGET:-50.0}"

ROLLING_BUDGET=$(validate_budget "$_raw_rolling" 90.0)
[ -z "$ROLLING_BUDGET" ] && ROLLING_BUDGET="90.00"

WEEKLY_BUDGET=$(validate_budget "$_raw_weekly" 30.0)
[ -z "$WEEKLY_BUDGET" ] && WEEKLY_BUDGET="30.00"

MONTHLY_BUDGET=$(validate_budget "$_raw_monthly" 50.0)
[ -z "$MONTHLY_BUDGET" ] && MONTHLY_BUDGET="50.00"

# --- Weekly cutoff: start of current week (Monday 00:00 UTC) ---
DOW=$(TZ=UTC date +%u)  # 1=Monday, 7=Sunday
DAYS_SINCE_MON=$((DOW - 1))
WEEK_START_S=$(($(TZ=UTC date -d "$(TZ=UTC date +%Y-%m-%d)" +%s) - DAYS_SINCE_MON * 86400))
WEEK_START_MS=$((WEEK_START_S * 1000))

# --- Monthly cutoff: 30-day window anchored at first opencode-go message.
#     Fallback: 30 days ago (overwritten after DB guard if data exists). ---
MONTH_START_MS=$(( (NOW_MS / 1000 - 30 * 86400) * 1000 ))

# --- Guard: required dependencies ---
if ! command -v sqlite3 >/dev/null 2>&1; then
    printf '{"text": "?", "tooltip": "sqlite3 not installed", "class": "opencode-usage-idle", "percentage": 0}\n'
    exit 0
fi

# --- Helper: format token counts ---
format_tokens() {
    local tokens="${1:-0}"
    [[ "$tokens" =~ ^[0-9]+$ ]] || { printf '0'; return; }
    if [ "$tokens" -ge 1000000 ]; then
        awk "BEGIN {printf \"%.1fM\", $tokens/1000000}"
    elif [ "$tokens" -ge 1000 ]; then
        awk "BEGIN {printf \"%.0fK\", $tokens/1000}"
    else
        printf '%s' "$tokens"
    fi
}

# --- Helper: format cost ---
format_cost() {
    local cost="${1:-0}"
    awk "BEGIN {printf \"%.2f\", $cost}"
}

# --- Helper: calculate integer percentage from cost against a specific budget ---
# Args: $1=cost  $2=budget  Returns integer 0-100 via stdout.
calc_budget_percentage() {
    local cost="${1:-0}"
    local budget="${2:-50.0}"
    awk -v cost="$cost" -v budget="$budget" 'BEGIN {
        if (budget + 0 <= 0) { printf "0"; exit }
        v = (cost / budget) * 100;
        if (v < 0) v = 0;
        if (v > 100) v = 100;
        printf "%d", v + 0.5;
    }'
}

# --- Helper: format duration from seconds ---
format_duration() {
    local secs="${1:-0}"
    if [ "$secs" -ge 86400 ]; then
        local d=$((secs / 86400))
        local h=$(( (secs % 86400) / 3600 ))
        printf '%dd %dh' "$d" "$h"
    elif [ "$secs" -ge 3600 ]; then
        local h=$((secs / 3600))
        local m=$(( (secs % 3600) / 60 ))
        printf '%dh %dm' "$h" "$m"
    else
        local m=$((secs / 60))
        printf '%dm' "$m"
    fi
}

# --- Helper: query a time window from the message table ---
# Args: $1=cutoff_ms
# Returns: total_cost|total_input_tokens|total_output_tokens|total_reasoning_tokens|distinct_sessions|oldest_timestamp
query_window() {
    local cutoff="$1"
    sqlite3 "$DB" 2>/dev/null <<EOF
SELECT
    COALESCE(SUM(json_extract(data, '$.cost')), 0),
    COALESCE(SUM(json_extract(data, '$.tokens.input')), 0),
    COALESCE(SUM(json_extract(data, '$.tokens.output')), 0),
    COALESCE(SUM(json_extract(data, '$.tokens.reasoning')), 0),
    COUNT(DISTINCT session_id),
    COALESCE(MIN(time_created), 0)
FROM message
WHERE time_created > $cutoff
  AND json_extract(data, '$.providerID') = 'opencode-go'
  AND json_extract(data, '$.cost') > 0;
EOF
}

# --- Helper: per-model breakdown for a window from the message table ---
# Args: $1=cutoff_ms
query_models() {
    local cutoff="$1"
    sqlite3 "$DB" 2>/dev/null <<EOF
SELECT
    json_extract(data, '$.modelID') AS model_id,
    SUM(json_extract(data, '$.cost')) AS total_cost,
    COUNT(DISTINCT session_id) AS sessions
FROM message
WHERE time_created > $cutoff
  AND json_extract(data, '$.providerID') = 'opencode-go'
  AND json_extract(data, '$.cost') > 0
GROUP BY model_id
ORDER BY total_cost DESC;
EOF
}

# --- Guard: database missing ---
if [ ! -f "$DB" ]; then
    printf '{"text": "N/A", "tooltip": "Opencode database not found", "class": "opencode-usage-idle", "percentage": 0}\n'
    exit 0
fi

# --- Monthly anchor: first ever opencode-go message (overrides 30-day fallback above) ---
FIRST_OCG_MSG=$(sqlite3 "$DB" 2>/dev/null <<EOF
SELECT COALESCE(MIN(time_created), 0)
FROM message
WHERE json_extract(data, '$.providerID') = 'opencode-go';
EOF
)
if [ -n "$FIRST_OCG_MSG" ] && [ "$FIRST_OCG_MSG" -gt 0 ] 2>/dev/null; then
    MONTH_START_MS="$FIRST_OCG_MSG"
fi

# ============================================================
# Query all 3 windows
# ============================================================

# --- Rolling (10h window) ---
AGG_5H=$(query_window "$CUTOFF_5H")
COST_5H=$(echo "$AGG_5H" | cut -d'|' -f1)
INPUT_5H=$(echo "$AGG_5H" | cut -d'|' -f2)
OUTPUT_5H=$(echo "$AGG_5H" | cut -d'|' -f3)
REASON_5H=$(echo "$AGG_5H" | cut -d'|' -f4)
COUNT_5H=$(echo "$AGG_5H" | cut -d'|' -f5)
OLDEST_5H=$(echo "$AGG_5H" | cut -d'|' -f6)

# --- Weekly ---
AGG_WEEK=$(query_window "$WEEK_START_MS")
COST_WEEK=$(echo "$AGG_WEEK" | cut -d'|' -f1)
INPUT_WEEK=$(echo "$AGG_WEEK" | cut -d'|' -f2)
OUTPUT_WEEK=$(echo "$AGG_WEEK" | cut -d'|' -f3)
REASON_WEEK=$(echo "$AGG_WEEK" | cut -d'|' -f4)
COUNT_WEEK=$(echo "$AGG_WEEK" | cut -d'|' -f5)

# Guard: empty weekly data
if [ -z "$COUNT_WEEK" ] || [ "$COUNT_WEEK" -eq 0 ] 2>/dev/null; then
    COST_WEEK="0"
    INPUT_WEEK=0
    OUTPUT_WEEK=0
    REASON_WEEK=0
    COUNT_WEEK=0
fi

# --- Monthly ---
AGG_MONTH=$(query_window "$MONTH_START_MS")
COST_MONTH=$(echo "$AGG_MONTH" | cut -d'|' -f1)
INPUT_MONTH=$(echo "$AGG_MONTH" | cut -d'|' -f2)
OUTPUT_MONTH=$(echo "$AGG_MONTH" | cut -d'|' -f3)
REASON_MONTH=$(echo "$AGG_MONTH" | cut -d'|' -f4)
COUNT_MONTH=$(echo "$AGG_MONTH" | cut -d'|' -f5)

# Guard: empty monthly data
if [ -z "$COUNT_MONTH" ] || [ "$COUNT_MONTH" -eq 0 ] 2>/dev/null; then
    COST_MONTH="0"
    INPUT_MONTH=0
    OUTPUT_MONTH=0
    REASON_MONTH=0
    COUNT_MONTH=0
fi

# ============================================================
# Calculate rolling window metrics
# ============================================================
if [ -z "$COUNT_5H" ] || [ "$COUNT_5H" -eq 0 ] 2>/dev/null; then
    PERCENTAGE=0
    ELAPSED_STR="0m"
    RESET_5H_STR="0m"
    COST_5H="0"
    INPUT_5H=0
    OUTPUT_5H=0
    REASON_5H=0
    COUNT_5H=0
else
    if [ "$OLDEST_5H" -gt 0 ] 2>/dev/null; then
        ELAPSED_MS=$((NOW_MS - OLDEST_5H))
        ELAPSED_SEC=$((ELAPSED_MS / 1000))
        PERCENTAGE=$(calc_budget_percentage "$COST_5H" "$ROLLING_BUDGET")
        REMAINING_MS=$((WINDOW_MS - ELAPSED_MS))
        [ "$REMAINING_MS" -lt 0 ] && REMAINING_MS=0
        RESET_5H_SEC=$((REMAINING_MS / 1000))
        ELAPSED_STR=$(format_duration "$ELAPSED_SEC")
        RESET_5H_STR=$(format_duration "$RESET_5H_SEC")
    else
        PERCENTAGE=0
        ELAPSED_STR="0m"
        RESET_5H_STR="10h 0m"
    fi
fi

# --- Weekly reset: time until next Monday 00:00 ---
NOW_S=$(($(date +%s)))
NEXT_MON_S=$((WEEK_START_S + 7 * 86400))
RESET_WEEK_SEC=$((NEXT_MON_S - NOW_S))
[ "$RESET_WEEK_SEC" -lt 0 ] && RESET_WEEK_SEC=0
RESET_WEEK_STR=$(format_duration "$RESET_WEEK_SEC")

# --- Weekly percentage: cost against weekly budget ---
WEEK_PERCENTAGE=$(calc_budget_percentage "$COST_WEEK" "$WEEKLY_BUDGET")

# --- Monthly reset: 30 days from first opencode-go message (Go-style window) ---
RESET_MONTH_MS=$((MONTH_START_MS + 30 * 86400 * 1000))
RESET_MONTH_SEC=$(( (RESET_MONTH_MS - NOW_MS) / 1000 ))
[ "$RESET_MONTH_SEC" -lt 0 ] && RESET_MONTH_SEC=0
RESET_MONTH_STR=$(format_duration "$RESET_MONTH_SEC")

# --- Monthly percentage: cost against monthly budget ---
MONTH_PERCENTAGE=$(calc_budget_percentage "$COST_MONTH" "$MONTHLY_BUDGET")

# ============================================================
# Format values
# ============================================================
COST_5H_FMT=$(format_cost "$COST_5H")
COST_WEEK_FMT=$(format_cost "$COST_WEEK")
COST_MONTH_FMT=$(format_cost "$COST_MONTH")

INPUT_5H_FMT=$(format_tokens "$INPUT_5H")
OUTPUT_5H_FMT=$(format_tokens "$OUTPUT_5H")
REASON_5H_FMT=$(format_tokens "$REASON_5H")

INPUT_WEEK_FMT=$(format_tokens "$INPUT_WEEK")
OUTPUT_WEEK_FMT=$(format_tokens "$OUTPUT_WEEK")
REASON_WEEK_FMT=$(format_tokens "$REASON_WEEK")

INPUT_MONTH_FMT=$(format_tokens "$INPUT_MONTH")
OUTPUT_MONTH_FMT=$(format_tokens "$OUTPUT_MONTH")
REASON_MONTH_FMT=$(format_tokens "$REASON_MONTH")

# ============================================================
# Build tooltip (Pango markup for Waybar hover)
# ============================================================
TOOLTIP="<b>Opencode-go Usage</b> (Go limits: rolling \$${ROLLING_BUDGET}/10h, weekly \$${WEEKLY_BUDGET}, monthly \$${MONTHLY_BUDGET})"
TOOLTIP="${TOOLTIP}\\n\\n<b>Rolling:</b> ${PERCENTAGE}% | Reset: ${RESET_5H_STR}"
TOOLTIP="${TOOLTIP}\\n<b>Weekly:</b> ${WEEK_PERCENTAGE}% | Reset: ${RESET_WEEK_STR}"
TOOLTIP="${TOOLTIP}\\n<b>Monthly:</b> ${MONTH_PERCENTAGE}% | Reset: ${RESET_MONTH_STR}"

# ============================================================
# Handle --json mode (for Quickshell popup data)
# ============================================================
if [ "$1" = "--json" ]; then
    # Build model breakdown as JSON array
    MODELS_JSON="["
    FIRST=true
    while IFS='|' read -r MODEL_ID MODEL_COST MODEL_SESSIONS; do
        [ -z "$MODEL_ID" ] && continue
        # Escape special JSON characters in model ID
        MODEL_ID_ESCAPED=$(printf '%s' "$MODEL_ID" | sed 's/\\/\\\\/g; s/"/\\"/g')
        if [ "$FIRST" = true ]; then
            FIRST=false
        else
            MODELS_JSON="${MODELS_JSON},"
        fi
        MODELS_JSON="${MODELS_JSON}{\"name\":\"${MODEL_ID_ESCAPED}\",\"cost\":$(format_cost "$MODEL_COST"),\"sessions\":${MODEL_SESSIONS}}"
    done < <(query_models "$CUTOFF_5H")
    MODELS_JSON="${MODELS_JSON}]"

    printf '{"rolling5h":{"cost":%s,"sessions":%d,"input":"%s","output":"%s","reasoning":"%s","elapsed":"%s","reset":"%s","percentage":%d,"models":%s},"weekly":{"cost":%s,"sessions":%d,"input":"%s","output":"%s","reasoning":"%s","reset":"%s","percentage":%d},"monthly":{"cost":%s,"sessions":%d,"input":"%s","output":"%s","reasoning":"%s","reset":"%s","percentage":%d}}\n' \
        "$COST_5H" "$COUNT_5H" "$INPUT_5H_FMT" "$OUTPUT_5H_FMT" "$REASON_5H_FMT" "$ELAPSED_STR" "$RESET_5H_STR" "$PERCENTAGE" "$MODELS_JSON" \
        "$COST_WEEK" "$COUNT_WEEK" "$INPUT_WEEK_FMT" "$OUTPUT_WEEK_FMT" "$REASON_WEEK_FMT" "$RESET_WEEK_STR" "$WEEK_PERCENTAGE" \
        "$COST_MONTH" "$COUNT_MONTH" "$INPUT_MONTH_FMT" "$OUTPUT_MONTH_FMT" "$REASON_MONTH_FMT" "$RESET_MONTH_STR" "$MONTH_PERCENTAGE"
    exit 0
fi

# ============================================================
# Handle --notify mode (for desktop notification)
# ============================================================
if [ "$1" = "--notify" ]; then
    if ! command -v notify-send >/dev/null 2>&1; then
        exit 0
    fi
    PLAIN=$(printf '%b' "$TOOLTIP" | sed 's/<[^>]*>//g')
    notify-send -t 12000 -i utilities-system-monitor \
        "Opencode-go Usage" "$PLAIN"
    exit 0
fi

# ============================================================
# Default: Waybar bar output (robot icon + AI text)
# ============================================================
TOOLTIP_ESCAPED=$(printf '%s' "$TOOLTIP" | sed 's/"/\\"/g')

printf '{"text": "🤖 AI", "tooltip": "%s", "class": "opencode-usage", "percentage": %d}\n' \
    "$TOOLTIP_ESCAPED" "$PERCENTAGE"
