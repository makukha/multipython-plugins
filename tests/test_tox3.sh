#!/usr/bin/env bash
set -eEuo pipefail

. shared.sh

prepare_tox_file () {
  TEMPLATE="$1"
  sed 's/{{ALL}}/'"$(commasep "$PASSING $NOINSTALL $NOTFOUND py20")"'/;
    s/{{PASSING}}/'"$(commasep "$PASSING")"'/;
    s/{{NOINSTALL}}/'"$(commasep "$NOINSTALL")"'/;
    s/{{NOTFOUND}}/'"$(commasep "$NOTFOUND")"'/' \
    "$TEMPLATE"
}

# input
read -r DEPS HOST DATA <<<"$@"
IFS=: read -r PASSING NOINSTALL NOTFOUND <<<"$DATA"
validate_image_tags_coverage "$PASSING $NOINSTALL $NOTFOUND"

# setup
py install --sys "$HOST" --no-update-info
pip_install $(tr : ' ' <<<"$DEPS") \
  "tox-multipython @ file://$(find /work/plugins/tox-multipython/dist -name '*.whl')"
pip_install_if_debug loguru

# sample package
PKG="$(find "$SAMPLEPKG_DIR/dist" -name '*.whl')"
[ -n "$PKG" ]

# test: test passing tags
prepare_tox_file tox3.passing.ini > /tmp/tox.ini
for TAG in $PASSING; do
  tox -c /tmp run -e "$TAG" --installpkg="$PKG"
done

# test: test non-installable tags
prepare_tox_file tox3.noinstall.ini > /tmp/tox.ini
for TAG in $NOINSTALL; do
  if tox -c /tmp run -e "$TAG" --installpkg="$PKG"; then false; fi
  [[ "$(tox -c /tmp run -e "$TAG" --installpkg="$PKG")" != *" InterpreterNotFound: "* ]]
done

# test: test non-discoverable tags
prepare_tox_file tox3.notfound.ini > /tmp/tox.ini
for TAG in $NOTFOUND py20; do
  if tox -c /tmp run -e "$TAG" --skip-pkg-install; then false; fi
  [[ "$(tox -c /tmp run -e "$TAG" --skip-pkg-install)" == *" InterpreterNotFound: "* ]]
done

# finish
py uninstall --no-update-info
rm -rf /tmp/tox.ini /tmp/.tox
