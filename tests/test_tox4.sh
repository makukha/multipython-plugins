#!/usr/bin/env bash
set -eEuo pipefail

. shared.sh

# inputs
read -r DEPS HOST TARGETS <<<"$@"
IFS=: read -r PASSING NOINSTALL NOTFOUND <<<"$TARGETS"
validate_image_tags_coverage "$PASSING $NOINSTALL $NOTFOUND"

# setup
py install --sys "$HOST" --no-update-info
pip uninstall -y tox virtualenv
rm /root/.config/virtualenv/virtualenv.ini
pip_install $(tr : ' ' <<<"$DEPS") \
  "tox-multipython @ file://$(find /work/plugins/tox-multipython/dist -name '*.whl')" \
  "virtualenv-multipython @ file://$(find /work/plugins/virtualenv-multipython/dist -name '*.whl')"
pip_install_if_debug loguru
export VIRTUALENV_DISCOVERY=multipython
if [ "${DEBUG:-}" = "true" ]; then
  TOX="tox -c /tmp/tox.ini -vvv"
else
  TOX="tox -c /tmp/tox.ini"
fi

# test: test passing tags
prepare_tox_file tox.passing.ini "$PASSING" "$NOINSTALL" "$NOTFOUND" > /tmp/tox.ini
for TAG in $PASSING; do
  $TOX run -e "$TAG" --installpkg="$SAMPLEPKG"
done

# test: test non-installable tags
prepare_tox_file tox.noinstall.ini "$PASSING" "$NOINSTALL" "$NOTFOUND" > /tmp/tox.ini
for TAG in $NOINSTALL; do
  if $TOX run -e "$TAG" --installpkg="$SAMPLEPKG"; then false; fi
  [[ "$($TOX run -e "$TAG" --installpkg="$SAMPLEPKG")" != *" failed with could not find python "* ]]
done

# test: test non-discoverable tags
prepare_tox_file tox.notfound.ini "$PASSING" "$NOINSTALL" "$NOTFOUND" > /tmp/tox.ini
for TAG in $NOTFOUND py20; do
  if $TOX run -e "$TAG" --skip-pkg-install; then false; fi
  [[ "$($TOX run -e "$TAG" --skip-pkg-install)" == *" failed with could not find python "* ]]
done

# finish
py uninstall --no-update-info
rm -rf /tmp/.tox
