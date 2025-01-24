#!/usr/bin/env bash
set -eEuo pipefail

. shared.sh

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
export VIRTUALENV_DISCOVERY=multipython
TOX="tox -c tox4.ini"
# used in tox.ini
export ALL="$(commasep "$PASSING $NOINSTALL $NOTFOUND py20")"
export PASSING="$(commasep "$PASSING")"
export NOINSTALL="$(commasep "$NOINSTALL")"
export NOTFOUND="$(commasep "$NOTFOUND")"

# test: test passing tags
for TAG in $PASSING; do
  $TOX run -e "$TAG" --installpkg="$SAMPLEPKG"
done

# test: test non-installable tags
for TAG in $NOINSTALL; do
  if $TOX run -e "$TAG" --installpkg="$SAMPLEPKG"; then false; fi
  [[ "$($TOX run -e "$TAG" --installpkg="$SAMPLEPKG")" != *" failed with could not find python "* ]]
done

# test: test non-discoverable tags
for TAG in $NOTFOUND py20; do
  if $TOX run -e "$TAG" --skip-pkg-install; then false; fi
  [[ "$($TOX run -e "$TAG" --skip-pkg-install)" == *" failed with could not find python "* ]]
done

# finish
py uninstall --no-update-info
rm -rf /tmp/.tox
