#!/bin/bash
# Simulation test for the xhost grant/revoke in fusion/run.sh and fusion/tutorial/run.sh.
# Uses shim xhost/docker only; never touches the real ones. Run: bash fusion/xhost.test.sh

unset BASH_ENV ENV
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
T="$(mktemp -d)" || exit 1
[ -n "$T" ] && [ -d "$T" ] || exit 1
trap 'rm -rf "$T"' EXIT
BIN="$T/bin"
mkdir -p "$BIN" "$T/gevol" "$T/tut"

cat >"$BIN/xhost" <<'EOF'
#!/bin/bash
case "$1" in
+si:localuser:root) echo "SI:localuser:root" >>"$XHOST_ACL" ;;
-si:localuser:root)
    grep -vx "SI:localuser:root" "$XHOST_ACL" >"$XHOST_ACL.tmp"
    mv "$XHOST_ACL.tmp" "$XHOST_ACL"
    ;;
"")
    echo "access control enabled, only authorized clients can connect"
    cat "$XHOST_ACL"
    ;;
esac
exit 0
EOF

cat >"$BIN/docker" <<'EOF'
#!/bin/bash
echo "$*" >>"$DOCKER_LOG"
case "$1" in
run)
    cat "$XHOST_ACL" >"$DOCKER_LOG.acl"
    [ -n "$DOCKER_FAIL" ] && exit 125
    case " $* " in
    *" -d "*) echo "fakeid" ;;
    *) sleep "$DOCKER_LIFE" ;;
    esac
    ;;
wait)
    sleep "$DOCKER_LIFE"
    echo 0
    ;;
esac
exit 0
EOF
chmod +x "$BIN/xhost" "$BIN/docker"

# Safety guard: the real xhost/docker must never be reachable from the scripts.
unset DISPLAY
export PATH="$BIN:$PATH"
for cmd in xhost docker; do
    case "$(command -v "$cmd")" in
    "$T"/*) ;;
    *)
        echo "FAIL: shim not first on PATH ($cmd)"
        exit 1
        ;;
    esac
done

LIFE=2
FAILS=0

check() { # check <description> <command...>
    local desc="$1"
    shift
    if "$@"; then
        echo "ok   $desc"
    else
        echo "FAIL $desc"
        FAILS=$((FAILS + 1))
    fi
}

# Each scenario gets its own ACL and log so a leftover watcher cannot affect the next one.
new_scenario() {
    export XHOST_ACL="$T/$1.acl"
    export DOCKER_LOG="$T/$1.log"
    export DOCKER_LIFE="$LIFE"
    unset DOCKER_FAIL
    : >"$XHOST_ACL"
    : >"$DOCKER_LOG"
}

# Script output goes to a file: a pipe or $(...) would wait for the background watcher.
run_script() { # run_script <scenario> <script> [args...]
    local name="$1" script="$2"
    shift 2
    bash "$REPO/$script" "$@" >"$T/$name.out" 2>&1
    RC=$?
}

has_grant() { grep -qx "SI:localuser:root" "$XHOST_ACL"; }
no_grant() { ! has_grant; }
no_wait_call() { ! grep -q "^wait" "$DOCKER_LOG"; }
docker_run_called() { grep -q "^run" "$DOCKER_LOG"; }
grant_seen_by_docker() { grep -qx "SI:localuser:root" "$DOCKER_LOG.acl"; }
rc_is() { [ "$RC" -eq "$1" ]; }

for script in fusion/run.sh fusion/tutorial/run.sh; do
    tag="${script//\//_}"
    args=("--gevol=$T/gevol")
    tutorial=0
    if [ "$script" = fusion/tutorial/run.sh ]; then
        tutorial=1
        args+=("--tutorial_volume=$T/tut")
    fi

    new_scenario "$tag.1"
    run_script "$tag.1" "$script" "${args[@]}"
    check "$script default: granted when script returns" has_grant
    sleep $((LIFE + 2))
    check "$script default: revoked after container exits" no_grant

    new_scenario "$tag.2"
    echo "SI:localuser:root" >"$XHOST_ACL"
    run_script "$tag.2" "$script" "${args[@]}"
    sleep $((LIFE + 2))
    check "$script pre-existing grant kept" has_grant

    new_scenario "$tag.3"
    run_script "$tag.3" "$script" "--gevol=$T/gevol/missing"
    check "$script bad --gevol exits 1" rc_is 1
    check "$script bad --gevol: no grant" no_grant

    if [ "$tutorial" -eq 1 ]; then
        new_scenario "$tag.4"
        run_script "$tag.4" "$script" "--gevol=$T/gevol" "--tutorial_volume=$T/tut/missing"
        check "$script bad --tutorial_volume exits 1" rc_is 1
        check "$script bad --tutorial_volume: no grant" no_grant
    fi

    new_scenario "$tag.5"
    export DOCKER_FAIL=1
    run_script "$tag.5" "$script" "${args[@]}"
    sleep 2
    check "$script docker run failure: docker run was called" docker_run_called
    check "$script docker run failure: revoked" no_grant
    if [ "$tutorial" -eq 1 ]; then
        check "$script docker run failure: no docker wait" no_wait_call
    fi

    new_scenario "$tag.6"
    export DOCKER_LIFE=1
    run_script "$tag.6" "$script" "${args[@]}" --entrypoint
    check "$script --entrypoint: granted while docker ran" grant_seen_by_docker
    check "$script --entrypoint: revoked on return" no_grant

    new_scenario "$tag.7"
    export DOCKER_FAIL=1
    run_script "$tag.7" "$script" "${args[@]}" --entrypoint
    check "$script --entrypoint run failure: docker run was called" docker_run_called
    check "$script --entrypoint run failure: revoked on return" no_grant
done

if [ "$FAILS" -ne 0 ]; then
    echo "$FAILS FAIL"
    exit 1
fi
echo "all ok"
