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
  yq 'to_entries | filter(.key=="'$SUITE'")[] | . ref $suite | .value
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





## --- entrypoint ---
#
#main () {
#  py uninstall --no-update-info 2>/dev/null || true
#  IFS= load_cases "$1" | while read -r CASE
#  do
#    SUITE="$(cut -d: -f1 <<<"$CASE")"
#    ARGS="$(case_bracex <<<"$CASE" | cut -d: -f2-)"
#    if "test_$SUITE" "$ARGS"; then
#      printf 'PASS: %s [%s] %ss\n' "$1" "$CASE" "$SECONDS"
#    else
#      printf 'FAIL: %s [%s] %ss\n' "$1" "$CASE" "$SECONDS"
#      exit 1
#    fi
#  done
#}
#
#main "$@"


























#if [ "${DEBUG:-}" = "true" ]; then
#  set -x
#  export MULTIPYTHON_DEBUG=true
#  export PIP_QUIET=false
#  export VIRTUALENV_QUIET=0
#  tox_quiet () {
#    tox "$@"
#  }
#else
#  export MULTIPYTHON_DEBUG=
#  export PIP_QUIET=true
#  export VIRTUALENV_QUIET=1
#  tox_quiet () {
#    tox "$@" &>/dev/null
#  }
#fi
#
#
#SAMPLEPKG_DIR=/work/tests/samplepkg
#TESTS_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
#
#cd "$TESTS_DIR"
#
#
#
## --- helpers ---
#
#
#load_cases () {
#  SUITE="$(cut -d- -f1 <<<"$1")"
#  HOST="$(cut -d- -f2 <<<"$1")"
#  VENV="$(cut -d- -f3 <<<"$1")"
#  yq '.'"$SUITE"'.'"$HOST"'.'"$VENV"' | "\(.venv):\(.pass):\(.noinstall):\(.notfound)"' "$TESTS_DIR/cases.toml" \
#    | sed "/null/d; s/^/$SUITE:$HOST:/"
#}
#

#
#py_install () {
#  HOST="$1";
#  shift
#  py install --sys "$HOST" --no-update-info
#  pip install --disable-pip-version-check --force-reinstall "$@" \
#    "virtualenv-multipython @ file://$(find /work/dist -name '*.whl')"
#  if [ "$MULTIPYTHON_DEBUG" = "true" ]; then
#    # use loguru if possible
#    pip install --disable-pip-version-check --force-reinstall loguru || true
#  fi
#}

#
#
#
## --- test: tox4 ---
#
#test_tox4 () {
#  # input
#  IFS=: read -r HOST VENV PASS NOINSTALL NOTFOUND <<<"$@"
#  validate_tags "$PASS $NOINSTALL $NOTFOUND"
#
#  # set env vars for tox.ini
#  ENVS_PASSING="$(commasep "$PASS")"
#  ENVS_NOINSTALL="$(commasep "$NOINSTALL")"
#  ENVS_NOTFOUND="$(commasep "$NOTFOUND py20")"
#  ALL_ENVS="$(commasep "$PASS $NOINSTALL $NOTFOUND py20")"
#
#  export ENVS_PASSING
#  export ENVS_NOINSTALL
#  export ENVS_NOTFOUND
#  export ALL_ENVS
#
#  # setup
#  py_install "$HOST" "tox>=4,<5" "virtualenv$VENV"
#  PKG="$(find "$SAMPLEPKG_DIR/dist" -name '*.whl')"
#
#  # test: test passing tags
#  for TAG in $PASS; do
#    tox_quiet run -e "$TAG" --installpkg="$PKG"
#  done
#
#  # test: test non-installable tags
#  for TAG in $NOINSTALL; do
#    # passing
#    TOX_PACKAGE=skip tox_quiet run -e "$TAG"
#    # failing
#    if TOX_PACKAGE=external tox_quiet run -e "$TAG" --installpkg="$PKG"; then false; fi
#  done
#
#  # test: test non-discoverable tags
#  for TAG in $NOTFOUND py20; do
#    [[ "$(tox_quiet run -e "$TAG")" == *" failed with could not find python "* ]]
#  done
#
#  # finish
#  py uninstall --no-update-info
#}
#
#
## --- test: venv ---
#
#test_venv () {
#  # input
#  IFS=: read -r HOST VENV PASS NOINSTALL NOTFOUND <<<"$@"
#  validate_tags "$PASS $NOINSTALL $NOTFOUND"
#
#  # setup
#  py_install "$HOST" "virtualenv$VENV"
#
#  # test: no --python specified, use system
#  virtualenv --discovery=multipython --no-seed --with-traceback "/tmp/venv"
#  [ "$(py tag "/tmp/venv/bin/python")" = "$HOST" ]
#  rm -rf /tmp/venv
#
#  # test: passing tags
#  for TAG in $PASS $NOINSTALL; do
#    virtualenv -p "$TAG" --no-seed --with-traceback "/tmp/$TAG"
#    [ "$(py tag "/tmp/$TAG/bin/python")" = "$TAG" ]
#    rm -rf "/tmp/$TAG"
#  done
#
#  # test: not found tags
#  for TAG in $NOTFOUND py20; do
#    [[ "$(virtualenv -p "$TAG" "/tmp/$TAG" 2>&1)" == *"RuntimeError: failed to find interpreter "* ]]
#    [ ! -d "/tmp/$TAG" ]
#  done
#
#  # finish
#  py uninstall --no-update-info
#}
#
#
## --- entrypoint ---
#
#main () {
#  py uninstall --no-update-info 2>/dev/null || true
#  IFS= load_cases "$1" | while read -r CASE
#  do
#    SUITE="$(cut -d: -f1 <<<"$CASE")"
#    ARGS="$(case_bracex <<<"$CASE" | cut -d: -f2-)"
#    if "test_$SUITE" "$ARGS"; then
#      printf 'PASS: %s [%s] %ss\n' "$1" "$CASE" "$SECONDS"
#    else
#      printf 'FAIL: %s [%s] %ss\n' "$1" "$CASE" "$SECONDS"
#      exit 1
#    fi
#  done
#}
#
#main "$@"
