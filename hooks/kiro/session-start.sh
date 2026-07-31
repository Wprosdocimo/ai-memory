#!/bin/sh
# kiro agentSpawn hook (closest analog to SessionStart — DOES inject stdout
# into context, verified live against kiro-cli 2.15.2).
# 1. Forwards the event JSON to the ai-memory server (fire-and-forget).
# 2. Synchronously fetches any pending cross-agent handoff and prints it to
#    stdout, which kiro-cli prepends to the resuming session's context.
#
# See ai_memory_kiro_session_id_qs in _lib.sh for why SESSION_QS falls back
# to $KIRO_SESSION_ID instead of the (always-empty) payload field — it's
# forwarded via the server's session_id query-string fallback (see
# HookQuery::session_id in ai-memory-hooks) on every request below, not
# just the handoff fetch.
_lib_dir="$(dirname "$0")"
[ -f "$_lib_dir/_lib.sh" ] || _lib_dir="$_lib_dir/.."
. "$_lib_dir/_lib.sh"

SERVER="${AI_MEMORY_HOOK_URL:-http://127.0.0.1:49374}"
PAYLOAD=$(cat)
CWD=$(ai_memory_extract_cwd "$PAYLOAD")
QS=$(ai_memory_marker_qs "$CWD")
SESSION_QS=$(ai_memory_kiro_session_id_qs "$PAYLOAD")

printf '%s' "$PAYLOAD" \
    | ai_memory_post_hook "$SERVER/hook?event=session-start&agent=kiro${QS}${SESSION_QS}" >/dev/null 2>&1 || true
ai_memory_get_handoff "$SERVER/handoff?agent=kiro${QS}${SESSION_QS}" 2>/dev/null || true
exit 0
