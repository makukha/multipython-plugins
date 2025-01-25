#!/usr/bin/env bash
set -eEuo pipefail


export SAMPLEPKG="$(find "/work/tests/samplepkg/dist" -name '*.whl')"
[ -n "$SAMPLEPKG" ]


if [ "${DEBUG:-}" = "true" ]; then
  set -x
  export MULTIPYTHON_DEBUG=true
  export PIP_QUIET=false
  export VIRTUALENV_QUIET=0
else
  export MULTIPYTHON_DEBUG=
  export PIP_QUIET=true
  export VIRTUALENV_QUIET=1
fi

export PIP_ROOT_USER_ACTION=ignore
export TOX_WORK_DIR=/tmp/.tox


# helpers

commasep () {
  sed 's/^ *//; s/ *$//; s/  */,/g' <<<"$1"
}

pip_install () {
  pip install --disable-pip-version-check --force-reinstall "$@"
}

pip_install_if_debug () {
  if [ "${DEBUG:-}" = "true" ]; then
    pip_install "$@" || true
  fi
}

prepare_tox_file () {
  TEMPLATE="$1"
  PASSING="$2"
  NOINSTALL="$3"
  NOTFOUND="$4"
  sed 's/{{ALL}}/'"$(commasep "$PASSING $NOINSTALL $NOTFOUND py20")"'/;
    s/{{PASSING}}/'"$(commasep "$PASSING")"'/;
    s/{{NOINSTALL}}/'"$(commasep "$NOINSTALL")"'/;
    s/{{NOTFOUND}}/'"$(commasep "$NOTFOUND")"'/' \
    "$TEMPLATE"
}

validate_image_tags_coverage () {
  TAGS="$1"
  # shellcheck disable=SC2001
  [ "$(py ls --tag | sort | xargs)" = "$(sed 's/  */\n/g' <<<"$TAGS" | sort | xargs)" ]
}
