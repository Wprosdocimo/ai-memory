#!/bin/sh
# kiro preToolUse hook. Forwards the event JSON to the ai-memory server,
# fire-and-forget. See ai_memory_kiro_session_id_qs in _lib.sh for why
# SESSION_QS falls back to $KIRO_SESSION_ID instead of the (always-empty)
# payload field.
_lib_dir="$(dirname "$0")"
[ -f "$_lib_dir/_lib.sh" ] || _lib_dir="$_lib_dir/.."
. "$_lib_dir/_lib.sh"

SERVER="${AI_MEMORY_HOOK_URL:-http://127.0.0.1:49374}"
PAYLOAD=$(cat)
CWD=$(ai_memory_extract_cwd "$PAYLOAD")
QS=$(ai_memory_marker_qs "$CWD")
SESSION_QS=$(ai_memory_kiro_session_id_qs "$PAYLOAD")

printf '%s' "$PAYLOAD" \
    | ai_memory_post_hook "$SERVER/hook?event=pre-tool-use&agent=kiro${QS}${SESSION_QS}" >/dev/null 2>&1 || true
exit 0
