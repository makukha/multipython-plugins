#!/usr/bin/env bash
set -eEuo pipefail


export SAMPLEPKG="$(find "/work/tests/samplepkg/dist" -name '*.whl')"
[ -n "$SAMPLEPKG" ]


if [ "${DEBUG:-}" = "true" ]; then
  set -x
  export MULTIPYTHON_DEBUG=true
  export PIP_QUIET=false
  export TOX="tox -c /tmp/tox.ini -vvv"
  export VIRTUALENV_QUIET=0
else
  export MULTIPYTHON_DEBUG=
  export PIP_QUIET=true
  export TOX="tox -c /tmp/tox.ini"
  export VIRTUALENV_QUIET=1
fi

export PIP_DISABLE_PIP_VERSION_CHECK=1
export PIP_ROOT_USER_ACTION=ignore
export TOX_WORK_DIR=/tmp/.tox


# outcome

get_tox_outcome () {
  TAG="$1"
  # passing
  sed 's/{{TAG}}/'"$1"'/' tox.passing.ini > /tmp/tox.ini
  if $TOX run -e "$TAG" --installpkg="$SAMPLEPKG" >&2; then
    echo "passing"
    exit 0
  fi
  # noexec
  sed 's/{{TAG}}/'"$1"'/' tox.noexec.ini > /tmp/tox.ini
  if $TOX run -e "$TAG" --installpkg="$SAMPLEPKG" >&2; then
    echo "noexec"
    exit 0
  fi
  # noinstall
  sed 's/{{TAG}}/'"$1"'/' tox.noinstall.ini > /tmp/tox.ini
  if $TOX run -e "$TAG" >&2; then
    echo "noinstall"
    exit 0
  fi
  # notfound
  sed 's/{{TAG}}/'"$1"'/' tox.notfound.ini > /tmp/tox.ini
  OUT="$($TOX run -e "$TAG" --skip-pkg-install)"
  if [[ "$OUT" == *"InterpreterNotFound:"* ]] \
  || [[ "$OUT" == *"failed with could not find python interpreter"* ]] \
  || [[ "$OUT" == *"No virtualenv implementation"* ]] \
  || [[ "$OUT" == *"SyntaxError:"* ]]; then
    echo "notfound"
    exit 0
  fi
  # unexpected
  echo "unexpected"
  exit 0
}

get_venv_outcome () {
  TAG="$1"
  if ! virtualenv -p "$TAG" --with-traceback "/tmp/$TAG"; then
    if [[ "$(virtualenv -p "$TAG" "/tmp/$TAG" 2>&1)" == *"RuntimeError: failed to find interpreter "* ]]; then
      echo "notfound"
      exit 1
    else
      echo "unexpected"
      exit 1
    fi
  fi
  if [ "$(py tag "/tmp/$TAG/bin/python")" != "$TAG" ]; then
    echo "error"
    rm -rf "/tmp/$TAG"
    exit 1
  fi
  if ! "/tmp/$TAG/bin/python" -m pip install "$SAMPLEPKG"; then
    echo "noinstall"
    rm -rf "/tmp/$TAG"
    exit 1
  fi
  if [ "$("/tmp/$TAG/bin/python" -m samplepkg)" != "success" ]; then
    echo "noexec"
    rm -rf "/tmp/$TAG"
    exit 1
  fi
  echo "passing"
  rm -rf "/tmp/$TAG"
  exit 1
}

# helpers

pip_install () {
  pip install --disable-pip-version-check --force-reinstall "$@"
}

pip_install_if_debug () {
  if [ "${DEBUG:-}" = "true" ]; then
    pip_install "$@" || true
  fi
}

validate_image_tags_coverage () {
  TAGS="$1"
  # shellcheck disable=SC2001
  [ "$(py ls --tag | sort | xargs)" = "$(sed 's/  */\n/g' <<<"$TAGS" | sort | xargs)" ]
}
