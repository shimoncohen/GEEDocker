#!/bin/bash
# Verifies --gevol is honored for the Postgres data volume (issue #8).
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
RUN_SH="$SCRIPT_DIR/run.sh"

FAIL=0
fail() { echo "FAIL: $1"; FAIL=1; }

STUB_DIR=""
DOCKER_LOG=""
PW_FILE=""
GEVOL_A=""
GEVOL_B=""
cleanup() { rm -rf "$STUB_DIR" "$DOCKER_LOG" "$PW_FILE" "$GEVOL_A" "$GEVOL_B"; }
trap cleanup EXIT

STUB_DIR=$(mktemp -d)
DOCKER_LOG=$(mktemp)

cat >"$STUB_DIR/docker" <<EOF
#!/bin/bash
echo "\$@" >> "$DOCKER_LOG"
exit 0
EOF
chmod +x "$STUB_DIR/docker"

cat >"$STUB_DIR/sudo" <<'EOF'
#!/bin/bash
exec "$@"
EOF
chmod +x "$STUB_DIR/sudo"

export PATH="$STUB_DIR:$PATH"

PW_FILE=$(mktemp)
echo "secret" > "$PW_FILE"

GEVOL_A=$(mktemp -d)
: > "$DOCKER_LOG"

rc=0
bash "$RUN_SH" --gevol="$GEVOL_A" --admin_password_file="$PW_FILE" || rc=$?
if [ "$rc" -ne 0 ]; then
    fail "Case A: run.sh exited $rc"
fi

RUN_LINES_A=$(grep -n '^run ' "$DOCKER_LOG" || true)
RUN_COUNT_A=$(echo "$RUN_LINES_A" | grep -c '^' || true)
[ -z "$RUN_LINES_A" ] && RUN_COUNT_A=0
if [ "$RUN_COUNT_A" -ne 2 ]; then
    fail "Case A: expected exactly 2 'docker run' calls, got $RUN_COUNT_A"
fi

FIRST_RUN_LINE_A=$(grep -n '^run ' "$DOCKER_LOG" | sed -n '1p' | cut -d: -f1 || true)
CP_LINE_A=$(grep -n "^cp servercontainer:/var/opt/google/pgsql/data $GEVOL_A/data\$" "$DOCKER_LOG" | cut -d: -f1 || true)
RM_LINE_A=$(grep -n "^rm -f servercontainer\$" "$DOCKER_LOG" | cut -d: -f1 || true)
SECOND_RUN_LINE_A=$(grep -n '^run ' "$DOCKER_LOG" | sed -n '2p' | cut -d: -f1 || true)

if [ -z "$FIRST_RUN_LINE_A" ] || [ -z "$CP_LINE_A" ] || [ -z "$RM_LINE_A" ] || [ -z "$SECOND_RUN_LINE_A" ]; then
    fail "Case A: missing one of run/cp/rm/run in log"
else
    if ! { [ "$FIRST_RUN_LINE_A" -lt "$CP_LINE_A" ] && [ "$CP_LINE_A" -lt "$RM_LINE_A" ] && [ "$RM_LINE_A" -lt "$SECOND_RUN_LINE_A" ]; }; then
        fail "Case A: run/cp/rm/run not in expected order"
    fi
fi

FIRST_RUN_TEXT_A=$(sed -n "${FIRST_RUN_LINE_A}p" "$DOCKER_LOG")
if echo "$FIRST_RUN_TEXT_A" | grep -q '/var/opt/google/pgsql/data'; then
    fail "Case A: first (seed) docker run must not mount Postgres data volume"
fi

SECOND_RUN_TEXT_A=$(sed -n "${SECOND_RUN_LINE_A}p" "$DOCKER_LOG")
if ! echo "$SECOND_RUN_TEXT_A" | grep -q -- "-v $GEVOL_A/data:/var/opt/google/pgsql/data"; then
    fail "Case A: second docker run missing -v $GEVOL_A/data:/var/opt/google/pgsql/data"
fi

if ! echo "$FIRST_RUN_TEXT_A" | grep -q -- "-v $GEVOL_A/server:/gevol/server"; then
    fail "Case A: first docker run missing -v $GEVOL_A/server:/gevol/server"
fi
if ! echo "$SECOND_RUN_TEXT_A" | grep -q -- "-v $GEVOL_A/server:/gevol/server"; then
    fail "Case A: second docker run missing -v $GEVOL_A/server:/gevol/server"
fi

GEVOL_B=$(mktemp -d)
mkdir -p "$GEVOL_B/data"
: > "$DOCKER_LOG"

rc=0
bash "$RUN_SH" --gevol="$GEVOL_B" --admin_password_file="$PW_FILE" || rc=$?
if [ "$rc" -ne 0 ]; then
    fail "Case B: run.sh exited $rc"
fi

if grep -q '^cp ' "$DOCKER_LOG"; then
    fail "Case B: unexpected 'docker cp' when data dir already initialized"
fi
if grep -q '^rm ' "$DOCKER_LOG"; then
    fail "Case B: unexpected 'docker rm' when data dir already initialized"
fi

RUN_COUNT_B=$(grep -c '^run ' "$DOCKER_LOG" || true)
if [ "$RUN_COUNT_B" -ne 1 ]; then
    fail "Case B: expected exactly 1 'docker run' call, got $RUN_COUNT_B"
fi
RUN_TEXT_B=$(grep '^run ' "$DOCKER_LOG" || true)
if ! echo "$RUN_TEXT_B" | grep -q -- "-v $GEVOL_B/data:/var/opt/google/pgsql/data"; then
    fail "Case B: docker run missing -v $GEVOL_B/data:/var/opt/google/pgsql/data"
fi

if [ "$FAIL" -ne 0 ]; then
    echo "test_gevol.sh: FAILED"
    exit 1
fi
echo "test_gevol.sh: all cases passed"
