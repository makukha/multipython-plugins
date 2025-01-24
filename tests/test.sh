#!/usr/bin/env bash
set -eEuo pipefail


SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )


bracex () {
  eval echo "$(sed 's/:/ : /'g)" | sed 's/\s*:\s*/:/g'
}

list_cases () {
  yq 'to_entries | filter(.key!="requirements")[] | . ref $suite | .value
    | to_entries[] | . ref $tag | .value
    | to_entries[] | . ref $venv
    | "\($suite.key)-\($venv.key)-\($tag.key)"' \
    "$SCRIPT_DIR/cases.toml"
}

case_data () {
  IFS='-' read -r SUITE VENV TAG <<<"$1"
  yq 'to_entries | filter(.key=="'"$SUITE"'")[] | . ref $suite | .value
    | to_entries | filter(.key=="'"$TAG"'") | .[] | . ref $tag | .value
    | to_entries | filter(.key=="'"$VENV"'") | .[] | . ref $venv
    | "\(.value.passing):\(.value.noinstall):\(.value.notfound)"' \
    "$SCRIPT_DIR/cases.toml"
}

case_deps () {
  IFS='-' read -r SUITE VENV TAG <<<"$1"
  CASES="$SCRIPT_DIR/cases.toml"
  echo -n "$(yq '.requirements.'"$SUITE" "$CASES"):$(yq '.requirements.'"$VENV" "$CASES")"
}

run_case () {
  IFS='-' read -r SUITE VENV TAG <<<"$1"
  DATA="$(case_data "$1" | bracex)"
  DEPS="$(case_deps "$1")"
  # cleanup multipython defaults
  py uninstall --no-update-info 2>/dev/null || true
  # run
  pushd "$SCRIPT_DIR" >/dev/null
  if bash "test_$SUITE.sh" "$DEPS" "$TAG" "$DATA"; then
    printf 'PASSED: %s [%s] %ss\n' "$1" "$DATA" "$SECONDS"
  else
    printf 'FAILED: %s [%s] %ss\n' "$1" "$DATA" "$SECONDS"
    exit 1
  fi
  popd >/dev/null
}

case "$1" in
  cases) list_cases ;;
  data)  case_data "$2" ;;
  deps)  case_deps "$2" ;;
  run)   run_case "$2" ;;
esac
