#!/usr/bin/env bash
# Integration tests for jira-connector-bridge.sh.
#
# Usage:
#   bash scripts/jira-connector-bridge.test.sh
#
# Exits 0 if every test passes, 1 otherwise. No real Jira credentials or network
# access required -- the bash path is exercised against a stubbed `curl` on PATH,
# and the connector path only needs its echoed string.

set -u

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BRIDGE="$REPO_ROOT/scripts/jira-connector-bridge.sh"

# Assertions run inside a subshell per test (see _run_test), so pass/fail
# counts are tallied through a results file rather than shell variables --
# a subshell's variable writes never reach the parent shell.
RESULTS_FILE=$(mktemp)
trap 'rm -f "$RESULTS_FILE"' EXIT

_assert_contains() {
  local haystack="$1" needle="$2" desc="$3"
  if [[ "$haystack" == *"$needle"* ]]; then
    echo "PASS" >> "$RESULTS_FILE"
  else
    {
      echo "FAIL: $desc"
      echo "  expected to contain: $needle"
      echo "  actual: $haystack"
    } >> "$RESULTS_FILE"
  fi
}

_assert_not_contains() {
  local haystack="$1" needle="$2" desc="$3"
  if [[ "$haystack" != *"$needle"* ]]; then
    echo "PASS" >> "$RESULTS_FILE"
  else
    {
      echo "FAIL: $desc"
      echo "  expected NOT to contain: $needle"
      echo "  actual: $haystack"
    } >> "$RESULTS_FILE"
  fi
}

_assert_eq() {
  local actual="$1" expected="$2" desc="$3"
  if [ "$actual" = "$expected" ]; then
    echo "PASS" >> "$RESULTS_FILE"
  else
    {
      echo "FAIL: $desc"
      echo "  expected: $expected"
      echo "  actual:   $actual"
    } >> "$RESULTS_FILE"
  fi
}

# Every test runs in its own subshell so env vars, PATH, and sourced functions
# from one test never leak into the next.
_run_test() {
  local fn="$1"
  ( "$fn" )
}

# Installs a stub `curl` on PATH that records its argv to $CURL_LOG and returns
# a minimal valid Jira response instead of hitting the network. A request whose
# argv matches the glob in $CURL_FAIL_MATCH gets an HTTP 400 instead.
_stub_curl() {
  local bin_dir="$1"
  mkdir -p "$bin_dir"
  cat > "$bin_dir/curl" <<'STUB'
#!/usr/bin/env bash
echo "$@" >> "$CURL_LOG"
# shellcheck disable=SC2053  # unquoted RHS is the glob match on purpose
if [ -n "${CURL_FAIL_MATCH:-}" ] && [[ "$*" == $CURL_FAIL_MATCH ]]; then
  echo '{"errorMessages": ["stubbed failure"]}'
  echo "400"
  exit 0
fi
case "$*" in
  *fields=labels*)
    echo '{"fields": {"labels": ["existing"]}}'
    ;;
  *transitions*)
    echo '{"transitions": [{"id": "31", "to": {"name": "Done"}}]}'
    ;;
  *) echo '{"key": "STUB-1"}' ;;
esac
echo "200"
STUB
  chmod +x "$bin_dir/curl"
}

# ---------------------------------------------------------------------------
# Detection
# ---------------------------------------------------------------------------

test_detect_env_var_true() {
  source "$BRIDGE"
  JIRA_MCP_CONNECTOR_AVAILABLE=true jira_bridge_detect
  _assert_eq "$USE_CONNECTOR" "true" \
    "detect: JIRA_MCP_CONNECTOR_AVAILABLE=true sets USE_CONNECTOR=true"
}

test_detect_claude_present() {
  local bin_dir fake_home
  bin_dir=$(mktemp -d)
  cat > "$bin_dir/claude" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
  chmod +x "$bin_dir/claude"
  fake_home=$(mktemp -d)
  mkdir -p "$fake_home/.claude"

  source "$BRIDGE"
  PATH="$bin_dir:$PATH" HOME="$fake_home" jira_bridge_detect
  _assert_eq "$USE_CONNECTOR" "true" \
    "detect: claude binary + ~/.claude present sets USE_CONNECTOR=true"
  rm -rf "$bin_dir" "$fake_home"
}

test_detect_claude_absent() {
  local empty_bin fake_home
  empty_bin=$(mktemp -d)
  fake_home=$(mktemp -d)   # no .claude subdir

  source "$BRIDGE"
  PATH="$empty_bin" HOME="$fake_home" jira_bridge_detect
  _assert_eq "$USE_CONNECTOR" "false" \
    "detect: no claude binary, no ~/.claude sets USE_CONNECTOR=false"
  rm -rf "$empty_bin" "$fake_home"
}

test_detect_is_cached() {
  source "$BRIDGE"
  JIRA_MCP_CONNECTOR_AVAILABLE=true jira_bridge_detect
  _assert_eq "$USE_CONNECTOR" "true" "detect (cache setup): first call honors env var"

  # Second call with the env var gone must NOT re-check -- cached result stands.
  unset JIRA_MCP_CONNECTOR_AVAILABLE
  jira_bridge_detect
  _assert_eq "$USE_CONNECTOR" "true" \
    "detect: cached result survives env var changing after first check"
  _assert_eq "$CONNECTOR_CHECKED" "true" "detect: CONNECTOR_CHECKED stays true after caching"
}

# ---------------------------------------------------------------------------
# Connector path -- bridge echoes the MCP tool invocation as a string
# ---------------------------------------------------------------------------

test_connector_create_epic() {
  source "$BRIDGE"
  JIRA_MCP_CONNECTOR_AVAILABLE=true jira_bridge_detect
  local out
  out=$(jira_bridge_call create-epic "DASH" "My Epic" "Epic description")
  _assert_contains "$out" "CONNECTOR: jira_create_issue" \
    "connector create-epic: echoes the create-issue MCP tool"
  _assert_contains "$out" "--project_key 'DASH'" "connector create-epic: quotes project_key"
  _assert_contains "$out" "--summary 'My Epic'" "connector create-epic: quotes summary"
  _assert_contains "$out" "--issue_type 'Epic'" "connector create-epic: issue_type is Epic"
}

test_connector_create_task() {
  source "$BRIDGE"
  JIRA_MCP_CONNECTOR_AVAILABLE=true jira_bridge_detect
  local body_file
  body_file=$(mktemp)
  echo "Task body" > "$body_file"

  local out
  out=$(jira_bridge_call create-task "DASH" "My Task" "$body_file" "DASH-1" "8" "user@example.com")
  _assert_contains "$out" "--issue_type 'Task'" "connector create-task: issue_type is Task"
  _assert_contains "$out" '"epicKey": "DASH-1"' \
    "connector create-task: additional_fields carries epicKey"
  _assert_contains "$out" "originalEstimate" "connector create-task: timetracking fields present"
  rm -f "$body_file"
}

test_connector_transition() {
  source "$BRIDGE"
  JIRA_MCP_CONNECTOR_AVAILABLE=true jira_bridge_detect
  local out
  out=$(jira_bridge_call transition "DASH-1" "In Progress")
  _assert_contains "$out" "jira_get_transitions" \
    "connector transition: fetches available transitions first"
  _assert_contains "$out" "jira_transition_issue" \
    "connector transition: pipes into transition_issue"
  _assert_contains "$out" '.[] | select(.name ==' \
    "connector transition: filters a bare array on .name (the MCP tool's own shape has no .to)"
  _assert_not_contains "$out" '.transitions[]' \
    "connector transition: must not assume a .transitions[] wrapper"
}

test_connector_fetch_issue() {
  source "$BRIDGE"
  JIRA_MCP_CONNECTOR_AVAILABLE=true jira_bridge_detect
  local out
  out=$(jira_bridge_call fetch-issue "DASH-1" "summary,status")
  _assert_contains "$out" "CONNECTOR: jira_get_issue" \
    "connector fetch-issue: echoes get_issue"
  _assert_contains "$out" "--fields 'summary,status'" \
    "connector fetch-issue: fields parameter is included"
}

test_connector_get_transitions() {
  source "$BRIDGE"
  JIRA_MCP_CONNECTOR_AVAILABLE=true jira_bridge_detect
  local out
  out=$(jira_bridge_call get-transitions "DASH-1")
  _assert_contains "$out" "jira_get_transitions --issue_key 'DASH-1'" \
    "connector get-transitions: echoes get_transitions with issue_key"
}

test_connector_fetch_comments() {
  source "$BRIDGE"
  JIRA_MCP_CONNECTOR_AVAILABLE=true jira_bridge_detect
  local out
  out=$(jira_bridge_call fetch-comments "DASH-1")
  _assert_contains "$out" "CONNECTOR: jira_get_issue" \
    "connector fetch-comments: echoes get_issue"
  _assert_contains "$out" "--include 'comments'" \
    "connector fetch-comments: requests the comments expansion"
}

test_connector_comment() {
  source "$BRIDGE"
  JIRA_MCP_CONNECTOR_AVAILABLE=true jira_bridge_detect
  local out
  out=$(jira_bridge_call comment "DASH-1" "Looks good")
  _assert_contains "$out" "CONNECTOR: jira_add_comment" \
    "connector comment: echoes add_comment"
  _assert_contains "$out" "--body 'Looks good'" "connector comment: quotes the body"
}

test_connector_assign() {
  source "$BRIDGE"
  JIRA_MCP_CONNECTOR_AVAILABLE=true jira_bridge_detect
  local out
  out=$(jira_bridge_call assign "DASH-1" "user@example.com")
  _assert_contains "$out" "CONNECTOR: jira_assign_issue" \
    "connector assign: echoes assign_issue"
  _assert_contains "$out" "--assignee 'user@example.com'" "connector assign: quotes the assignee"
}

# ---------------------------------------------------------------------------
# Bash path -- bridge invokes bash helpers directly, no network required
# thanks to the stubbed `curl` on PATH.
# ---------------------------------------------------------------------------

test_bash_create_epic() {
  local bin_dir env_file curl_log
  bin_dir=$(mktemp -d)
  env_file=$(mktemp)
  curl_log=$(mktemp)
  _stub_curl "$bin_dir"
  {
    echo "JIRA_BASE_URL=https://jira.example.com"
    echo "JIRA_API_TOKEN=dummy-token"
    echo "JIRA_PROJECT_KEY=DASH"
  } > "$env_file"

  source "$BRIDGE"
  PATH="$bin_dir:$PATH" CURL_LOG="$curl_log" JIRA_ENV_FILE="$env_file" JIRA_ENV_SILENT=1 \
    USE_CONNECTOR=false CONNECTOR_CHECKED=true \
    jira_bridge_call create-epic "DASH" "My Epic" "Description" >/dev/null

  _assert_contains "$(cat "$curl_log")" "issue" \
    "bash create-epic: POSTs to the issue endpoint via _jira_create_epic"
  rm -rf "$bin_dir" "$env_file" "$curl_log"
}

test_bash_create_task() {
  local bin_dir env_file body_file curl_log
  bin_dir=$(mktemp -d)
  env_file=$(mktemp)
  body_file=$(mktemp)
  curl_log=$(mktemp)
  echo "Task body" > "$body_file"
  _stub_curl "$bin_dir"
  {
    echo "JIRA_BASE_URL=https://jira.example.com"
    echo "JIRA_API_TOKEN=dummy-token"
    echo "JIRA_PROJECT_KEY=DASH"
  } > "$env_file"

  source "$BRIDGE"
  PATH="$bin_dir:$PATH" CURL_LOG="$curl_log" JIRA_ENV_FILE="$env_file" JIRA_ENV_SILENT=1 \
    USE_CONNECTOR=false CONNECTOR_CHECKED=true \
    jira_bridge_call create-task "DASH" "My Task" "$body_file" "DASH-1" "8" >/dev/null

  _assert_contains "$(cat "$curl_log")" "issue" \
    "bash create-task: POSTs to the issue endpoint via _jira_create_task"
  rm -rf "$bin_dir" "$env_file" "$body_file" "$curl_log"
}

test_bash_transition() {
  local bin_dir env_file curl_log
  bin_dir=$(mktemp -d)
  env_file=$(mktemp)
  curl_log=$(mktemp)
  _stub_curl "$bin_dir"
  {
    echo "JIRA_BASE_URL=https://jira.example.com"
    echo "JIRA_API_TOKEN=dummy-token"
  } > "$env_file"

  source "$BRIDGE"
  PATH="$bin_dir:$PATH" CURL_LOG="$curl_log" JIRA_ENV_FILE="$env_file" JIRA_ENV_SILENT=1 \
    USE_CONNECTOR=false CONNECTOR_CHECKED=true \
    jira_bridge_call transition "DASH-1" "Done" >/dev/null

  _assert_contains "$(cat "$curl_log")" "transitions" \
    "bash transition: calls the transitions endpoint via _jira_transition"
  rm -rf "$bin_dir" "$env_file" "$curl_log"
}

test_bash_credential_fallback_resolves_from_any_cwd() {
  # load-jira-env.sh is resolved relative to the bridge's own file location, not
  # the caller's CWD or a hardcoded ~/.agents/... guess -- so credential sourcing
  # must succeed even from a CWD and HOME that have nothing Jira-related in them.
  local scratch fake_home bin_dir env_file curl_log out status
  scratch=$(mktemp -d)
  fake_home=$(mktemp -d)   # no ~/.agents/skills/setup-internal-skills here
  bin_dir=$(mktemp -d)
  env_file=$(mktemp)
  curl_log=$(mktemp)
  _stub_curl "$bin_dir"
  {
    echo "JIRA_BASE_URL=https://jira.example.com"
    echo "JIRA_API_TOKEN=dummy-token"
    echo "JIRA_PROJECT_KEY=DASH"
  } > "$env_file"

  out=$(cd "$scratch" && PATH="$bin_dir:$PATH" HOME="$fake_home" CURL_LOG="$curl_log" \
    JIRA_ENV_FILE="$env_file" JIRA_ENV_SILENT=1 bash -c "
    source '$BRIDGE'
    USE_CONNECTOR=false CONNECTOR_CHECKED=true jira_bridge_call create-epic DASH 'My Epic' ''
  " 2>&1)
  status=$?

  _assert_not_contains "$out" "Failed to source Jira credentials" \
    "bash credential fallback: does not report a sourcing failure from an arbitrary CWD/HOME"
  _assert_contains "$(cat "$curl_log")" "issue" \
    "bash credential fallback: still reaches the real _jira_create_epic call"
  _assert_eq "$status" "0" "bash credential fallback: returns 0 when credentials resolve"
  rm -rf "$scratch" "$fake_home" "$bin_dir" "$env_file" "$curl_log"
}

# ---------------------------------------------------------------------------
# Write exit status -- every write helper returns the result of its own write,
# and watcher policy still runs after it without changing that result.
# ---------------------------------------------------------------------------

# Runs one jira_bridge_call on the bash path against the stubbed curl.
# Usage: _bridge_write_status <fail_glob> <curl_log> <op> [args...]
# Prints the call's exit status; the curl log is left for the caller to inspect.
_bridge_write_status() {
  local fail_glob="$1" curl_log="$2" bin_dir env_file; shift 2
  bin_dir=$(mktemp -d)
  env_file=$(mktemp)
  _stub_curl "$bin_dir"
  {
    echo "JIRA_BASE_URL=https://jira.example.com"
    echo "JIRA_API_TOKEN=dummy-token"
    echo "JIRA_PROJECT_KEY=DASH"
    echo "JIRA_WATCHER_IGNORE=bob"
  } > "$env_file"

  source "$BRIDGE"
  PATH="$bin_dir:$PATH" CURL_LOG="$curl_log" CURL_FAIL_MATCH="$fail_glob" \
    JIRA_ENV_FILE="$env_file" JIRA_ENV_SILENT=1 \
    USE_CONNECTOR=false CONNECTOR_CHECKED=true \
    jira_bridge_call "$@" >/dev/null 2>&1
  echo "$?"
  rm -rf "$bin_dir" "$env_file"
}

# Calls one helper from jira-helpers.sh directly against the stubbed curl.
# Usage: _helper_write_status <fail_glob> <curl_log> <helper> [args...]
_helper_write_status() {
  local fail_glob="$1" curl_log="$2" bin_dir; shift 2
  bin_dir=$(mktemp -d)
  _stub_curl "$bin_dir"
  source "$REPO_ROOT/scripts/jira-helpers.sh"
  export PATH="$bin_dir:$PATH" CURL_LOG="$curl_log" CURL_FAIL_MATCH="$fail_glob" \
    JIRA_BASE_URL="https://jira.example.com" JIRA_API_TOKEN="dummy-token" \
    JIRA_WATCHER_IGNORE="bob"
  "$@" >/dev/null 2>&1
  echo "$?"
  rm -rf "$bin_dir"
}

readonly WATCHER_REMOVAL="-X DELETE"
readonly TRANSITION_POST='*-X POST*/transitions?notifyUsers=false*'
readonly CREATE_POST='*-X POST*/rest/api/2/issue?notifyUsers=false*'
readonly ISSUE_PUT='*-X PUT*'
readonly LABELS_GET='*-X GET*fields=labels*'

test_write_status_transition() {
  local curl_log status
  curl_log=$(mktemp)
  status=$(_bridge_write_status "$TRANSITION_POST" "$curl_log" transition "DASH-1" "Done")
  _assert_eq "$status" "1" "write status: bash transition returns 1 when the POST gets a 400"
  _assert_contains "$(cat "$curl_log")" "$WATCHER_REMOVAL" \
    "write status: bash transition still applies watcher policy after a failed POST"

  : > "$curl_log"
  status=$(_bridge_write_status "" "$curl_log" transition "DASH-1" "Done")
  _assert_eq "$status" "0" "write status: bash transition returns 0 when the POST succeeds"
  rm -f "$curl_log"
}

test_write_status_create_epic() {
  local curl_log status
  curl_log=$(mktemp)
  status=$(_bridge_write_status "$CREATE_POST" "$curl_log" create-epic "DASH" "My Epic" "Desc")
  _assert_eq "$status" "1" "write status: bash create-epic returns 1 when the POST gets a 400"

  status=$(_bridge_write_status "" "$curl_log" create-epic "DASH" "My Epic" "Desc")
  _assert_eq "$status" "0" "write status: bash create-epic returns 0 when the POST succeeds"
  rm -f "$curl_log"
}

test_write_status_create_task() {
  local curl_log body_file status
  curl_log=$(mktemp)
  body_file=$(mktemp)
  echo "Task body" > "$body_file"
  status=$(_bridge_write_status "$CREATE_POST" "$curl_log" \
    create-task "DASH" "My Task" "$body_file" "DASH-1" "8")
  _assert_eq "$status" "1" "write status: bash create-task returns 1 when the POST gets a 400"

  status=$(_bridge_write_status "" "$curl_log" \
    create-task "DASH" "My Task" "$body_file" "DASH-1" "8")
  _assert_eq "$status" "0" "write status: bash create-task returns 0 when the POST succeeds"
  rm -f "$curl_log" "$body_file"
}

test_write_status_update_issue() {
  local curl_log status
  curl_log=$(mktemp)
  status=$(_helper_write_status "$ISSUE_PUT" "$curl_log" \
    _jira_update_issue "DASH-1" '{"summary": "New"}')
  _assert_eq "$status" "1" "write status: _jira_update_issue returns 1 when the PUT gets a 400"
  _assert_contains "$(cat "$curl_log")" "$WATCHER_REMOVAL" \
    "write status: _jira_update_issue still applies watcher policy after a failed PUT"

  status=$(_helper_write_status "" "$curl_log" \
    _jira_update_issue "DASH-1" '{"summary": "New"}')
  _assert_eq "$status" "0" "write status: _jira_update_issue returns 0 when the PUT succeeds"
  rm -f "$curl_log"
}

test_write_status_update_description() {
  local curl_log body_file status
  curl_log=$(mktemp)
  body_file=$(mktemp)
  echo "# Heading" > "$body_file"
  status=$(_helper_write_status "$ISSUE_PUT" "$curl_log" \
    _jira_update_description "DASH-1" "$body_file")
  _assert_eq "$status" "1" \
    "write status: _jira_update_description returns 1 when the PUT gets a 400"
  _assert_contains "$(cat "$curl_log")" "$WATCHER_REMOVAL" \
    "write status: _jira_update_description still applies watcher policy after a failed PUT"

  status=$(_helper_write_status "" "$curl_log" _jira_update_description "DASH-1" "$body_file")
  _assert_eq "$status" "0" \
    "write status: _jira_update_description returns 0 when the PUT succeeds"
  rm -f "$curl_log" "$body_file"
}

test_write_status_set_labels() {
  local curl_log status
  curl_log=$(mktemp)
  status=$(_helper_write_status "$ISSUE_PUT" "$curl_log" _jira_set_labels "DASH-1" "new")
  _assert_eq "$status" "1" "write status: _jira_set_labels returns 1 when the PUT gets a 400"
  _assert_contains "$(cat "$curl_log")" "$WATCHER_REMOVAL" \
    "write status: _jira_set_labels still applies watcher policy after a failed PUT"

  : > "$curl_log"
  status=$(_helper_write_status "" "$curl_log" _jira_set_labels "DASH-1" "new")
  _assert_eq "$status" "0" "write status: _jira_set_labels returns 0 when the PUT succeeds"
  _assert_contains "$(cat "$curl_log")" '"existing"' \
    "write status: _jira_set_labels keeps the labels it read"
  _assert_contains "$(cat "$curl_log")" '"new"' \
    "write status: _jira_set_labels adds the requested label"
  rm -f "$curl_log"
}

test_write_status_set_labels_get_fails() {
  local curl_log status
  curl_log=$(mktemp)
  status=$(_helper_write_status "$LABELS_GET" "$curl_log" _jira_set_labels "DASH-1" "new")
  _assert_eq "$status" "1" "write status: _jira_set_labels returns 1 when the labels GET fails"
  _assert_not_contains "$(cat "$curl_log")" "-X PUT" \
    "write status: _jira_set_labels sends no PUT when the labels GET fails"
  rm -f "$curl_log"
}

# ---------------------------------------------------------------------------
# Error handling
# ---------------------------------------------------------------------------

test_unknown_operation() {
  source "$BRIDGE"
  JIRA_MCP_CONNECTOR_AVAILABLE=true jira_bridge_detect
  local out status
  out=$(jira_bridge_call totally-not-an-operation 2>&1)
  status=$?
  _assert_contains "$out" "Unknown operation" "unknown operation: prints a clear error"
  _assert_eq "$status" "1" "unknown operation: returns 1"
}

test_executed_directly_refuses() {
  local out status
  out=$(bash "$BRIDGE" 2>&1)
  status=$?
  _assert_contains "$out" "Source this script instead of executing it" \
    "direct execution: refuses and tells the caller to source it"
  _assert_eq "$status" "1" "direct execution: exits 1"
}

# ---------------------------------------------------------------------------
# Output consistency across the two paths
# ---------------------------------------------------------------------------

test_connector_output_prefix_consistent() {
  source "$BRIDGE"
  JIRA_MCP_CONNECTOR_AVAILABLE=true jira_bridge_detect
  local epic issue transitions
  epic=$(jira_bridge_call create-epic "DASH" "X")
  issue=$(jira_bridge_call fetch-issue "DASH-1")
  transitions=$(jira_bridge_call get-transitions "DASH-1")
  _assert_contains "$epic" "CONNECTOR:" "output consistency: create-epic uses the CONNECTOR: prefix"
  _assert_contains "$issue" "CONNECTOR:" \
    "output consistency: fetch-issue uses the CONNECTOR: prefix"
  _assert_contains "$transitions" "CONNECTOR:" \
    "output consistency: get-transitions uses the CONNECTOR: prefix"
}

# ---------------------------------------------------------------------------
# Run
# ---------------------------------------------------------------------------

_run_test test_detect_env_var_true
_run_test test_detect_claude_present
_run_test test_detect_claude_absent
_run_test test_detect_is_cached
_run_test test_connector_create_epic
_run_test test_connector_create_task
_run_test test_connector_transition
_run_test test_connector_fetch_issue
_run_test test_connector_get_transitions
_run_test test_connector_fetch_comments
_run_test test_connector_comment
_run_test test_connector_assign
_run_test test_bash_create_epic
_run_test test_bash_create_task
_run_test test_bash_transition
_run_test test_bash_credential_fallback_resolves_from_any_cwd
_run_test test_write_status_transition
_run_test test_write_status_create_epic
_run_test test_write_status_create_task
_run_test test_write_status_update_issue
_run_test test_write_status_update_description
_run_test test_write_status_set_labels
_run_test test_write_status_set_labels_get_fails
_run_test test_unknown_operation
_run_test test_executed_directly_refuses
_run_test test_connector_output_prefix_consistent

echo ""
grep -v '^PASS$' "$RESULTS_FILE" || true
PASS_COUNT=$(grep -c '^PASS$' "$RESULTS_FILE" || true)
FAIL_COUNT=$(grep -c '^FAIL:' "$RESULTS_FILE" || true)
echo ""
echo "PASS: $PASS_COUNT  FAIL: $FAIL_COUNT"
[ "$FAIL_COUNT" -eq 0 ]
