#!/bin/bash
# Exercises removeImage.sh against a fake `docker` bash function (exported
# so the bash subprocess that runs removeImage.sh inherits it). No real
# docker calls are made.
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

export DOCKER_LOG
DOCKER_LOG="$(mktemp)"
trap 'rm -f "$DOCKER_LOG"' EXIT

# "image ls -a" without -q returns a canned table shaped like real
# `docker image ls` output, so the old code's local `grep -w` runs against
# it for real and reproduces the reported collision (geeserver-slim/
# geefusion-ssh share a "word" with their short-named siblings).
# "image ls -a -q <ref>" emulates Docker's REPOSITORY[:TAG] filter: an
# exact string lookup on the ref, not a reimplementation of Docker's own
# glob-ish filter semantics.
docker() {
	local listing='REPOSITORY          TAG       IMAGE ID             CREATED        SIZE
geeserver-slim      v1        id-geeserver-slim    1 day ago     100MB
geeserver           v1        id-geeserver         1 day ago     100MB
geefusion-ssh       v1        id-geefusion-ssh     1 day ago     100MB
geefusion           v1        id-geefusion         1 day ago     100MB
fusiontutorial      v1        id-fusiontutorial    1 day ago     100MB
geetest             v1        id-geetest           1 day ago     100MB
geebuild            v1        id-geebuild          1 day ago     100MB'

	case "$1" in
		image)
			if [[ "$*" == *" -q "* ]]; then
				local ref="${*: -1}"
				echo "ls -q $ref" >>"$DOCKER_LOG"
				case "$ref" in
					geeserver | geeserver:v1) echo "id-geeserver" ;;
					geeserver-slim) echo "id-geeserver-slim" ;;
					geefusion | geefusion:v1) echo "id-geefusion" ;;
					geefusion-ssh) echo "id-geefusion-ssh" ;;
					fusiontutorial) echo "id-fusiontutorial" ;;
					geetest) echo "id-geetest" ;;
					geebuild) echo "id-geebuild" ;;
					*) ;;
				esac
			else
				echo "ls (full)" >>"$DOCKER_LOG"
				echo "$listing"
			fi
			;;
		rmi)
			shift
			echo "rmi argc=$# args=$*" >>"$DOCKER_LOG"
			if [ "$#" -eq 0 ]; then
				echo "docker: 'rmi' requires at least 1 argument." >&2
				echo "See 'docker rmi --help'." >&2
				return 1
			fi
			;;
		*)
			echo "fake docker: unhandled command: $*" >&2
			return 1
			;;
	esac
}
export -f docker

failures=0

fail() {
	echo "FAIL: $1"
	failures=$((failures + 1))
}

assert_eq() {
	local actual="$1" expected="$2" desc="$3"
	if [[ "$actual" != "$expected" ]]; then
		fail "$desc: expected '$expected', got '$actual'"
	fi
}

assert_contains() {
	local haystack="$1" needle="$2" desc="$3"
	if [[ "$haystack" != *"$needle"* ]]; then
		fail "$desc: expected to find '$needle' in: $haystack"
	fi
}

# RMI_LINE is exact-matched so a wrong id with the right prefix, e.g.
# id-geeserver-slim, can't pass as id-geeserver.
run_remove() {
	: >"$DOCKER_LOG"
	STDOUT=$(bash "$REPO_DIR/removeImage.sh" "$1" 2>/dev/null)
	STATUS=$?
	RMI_LINE=$(tail -n1 "$DOCKER_LOG")
}

# Case A: collision - geeserver must not resolve geeserver-slim's id, and
# geefusion must not resolve geefusion-ssh's id.
run_remove "geeserver"
assert_eq "$RMI_LINE" "rmi argc=1 args=id-geeserver" "case A geeserver rmi"

run_remove "geefusion"
assert_eq "$RMI_LINE" "rmi argc=1 args=id-geefusion" "case A geefusion rmi"

# Case B: all six removeAll.sh callers resolve their own id.
declare -A expected_ids=(
	[geeserver]=id-geeserver
	[geefusion]=id-geefusion
	[fusiontutorial]=id-fusiontutorial
	[geefusion-ssh]=id-geefusion-ssh
	[geetest]=id-geetest
	[geebuild]=id-geebuild
)
for name in geeserver geefusion fusiontutorial geefusion-ssh geetest geebuild; do
	run_remove "$name"
	assert_eq "$RMI_LINE" "rmi argc=1 args=${expected_ids[$name]}" "case B $name rmi"
done

# Case C: name:tag resolves the same id as the bare name.
run_remove "geeserver:v1"
assert_eq "$RMI_LINE" "rmi argc=1 args=id-geeserver" "case C geeserver:v1 rmi"

run_remove "geefusion:v1"
assert_eq "$RMI_LINE" "rmi argc=1 args=id-geefusion" "case C geefusion:v1 rmi"

# Case D: no match -> "Image does not exist.", rmi called with zero args,
# script exits 1. The stderr text on that exit is the fake's own, not
# asserted here.
run_remove "doesnotexist"
assert_contains "$STDOUT" "Image does not exist." "case D stdout"
assert_eq "$RMI_LINE" "rmi argc=0 args=" "case D zero-arg rmi"
assert_eq "$STATUS" "1" "case D exit status"

# Case E: empty argument hits the missing-arg guard, never reaching
# docker - an empty ref would otherwise list (and rmi) every image.
run_remove ""
assert_eq "$RMI_LINE" "" "case E empty arg: docker never invoked"

if [[ "$failures" -eq 0 ]]; then
	echo "All removeImage.sh tests passed."
	exit 0
else
	echo "$failures test(s) failed."
	exit 1
fi
