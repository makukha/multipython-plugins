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

# inputs
read -r DEPS HOST TARGETS <<<"$@"
IFS=: read -r PASSING NOINSTALL NOTFOUND <<<"$TARGETS"
validate_image_tags_coverage "$PASSING $NOINSTALL $NOTFOUND"

# setup
py install --sys "$HOST" --no-update-info
pip_install $(tr : ' ' <<<"$DEPS") \
  "tox-multipython @ file://$(find /work/plugins/tox-multipython/dist -name '*.whl')" \
  "virtualenv-multipython @ file://$(find /work/plugins/virtualenv-multipython/dist -name '*.whl')"
pip_install_if_debug loguru
TOX="tox -c /tmp/tox.ini"

# test: test passing tags
prepare_tox_file tox3.passing.ini > /tmp/tox.ini
for TAG in $PASSING; do
  $TOX run -e "$TAG" --installpkg="$SAMPLEPKG"
done

# test: test non-installable tags
prepare_tox_file tox3.noinstall.ini > /tmp/tox.ini
for TAG in $NOINSTALL; do
  if $TOX run -e "$TAG" --installpkg="$SAMPLEPKG"; then false; fi
  [[ "$($TOX run -e "$TAG" --installpkg="$SAMPLEPKG")" != *" InterpreterNotFound: "* ]]
done

# test: test non-discoverable tags
prepare_tox_file tox3.notfound.ini > /tmp/tox.ini
for TAG in $NOTFOUND py20; do
  if $TOX run -e "$TAG" --skip-pkg-install; then false; fi
  [[ "$($TOX run -e "$TAG" --skip-pkg-install)" == *" InterpreterNotFound: "* ]]
done

# finish
py uninstall --no-update-info
rm -rf /tmp/tox.ini /tmp/.tox
