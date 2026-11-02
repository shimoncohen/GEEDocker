#!/bin/bash
# Checks server/run.sh publishes the admin port on loopback only, and still
# refuses to start without --admin_password_file. docker and sudo are fakes.
cd "$(dirname "$0")/.." || exit 1

d=$(mktemp -d)
trap 'rm -rf "$d"' EXIT
mkdir "$d/bin" "$d/gevol"

# Fake docker logs each argv element on its own line.
cat >"$d/bin/docker" <<'EOF'
#!/bin/bash
printf '%s\n' "$@" >>"$FAKE_DOCKER_LOG"
EOF
printf '#!/bin/bash\nexec "$@"\n' >"$d/bin/sudo"
chmod +x "$d/bin/docker" "$d/bin/sudo"
printf 'dummy\n' >"$d/pw"

fail=0
check() { # check <name> <command...>
    local name=$1
    shift
    if "$@"; then echo "PASS: $name"; else echo "FAIL: $name"; fail=1; fi
}

run_server() { # run_server <log> <run.sh args...>
    local log=$1
    shift
    FAKE_DOCKER_LOG=$log PATH="$d/bin:$PATH" bash server/run.sh "$@" >/dev/null 2>&1
}

only_loopback_p() { # every -p is followed by exactly 127.0.0.1:8081:80
    local log=$1 line prev="" n=0
    while IFS= read -r line; do
        if [ "$prev" = "-p" ]; then
            n=$((n + 1))
            [ "$line" = "127.0.0.1:8081:80" ] || return 1
        fi
        prev=$line
    done <"$log"
    [ "$n" -ge 1 ]
}

scenario_a() {
    local log="$d/a.log"
    run_server "$log" --gevol "$d/gevol" --admin_password_file "$d/pw" &&
        only_loopback_p "$log" &&
        ! grep -qx '8081:80' "$log"
}

scenario_b() {
    local log="$d/b.log"
    ! run_server "$log" --gevol "$d/gevol" && [ ! -s "$log" ]
}

check "admin port bound to 127.0.0.1 only" scenario_a
check "no password file: exits non-zero, never reaches docker" scenario_b
exit "$fail"
