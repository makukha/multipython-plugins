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
  "virtualenv-multipython @ file://$(find /work/plugins/virtualenv-multipython/dist -name '*.whl')"
pip_install_if_debug loguru
export VIRTUALENV_DISCOVERY=multipython

# test: no --python specified, use system
virtualenv --no-seed --with-traceback "/tmp/venv"
[ "$(py tag "/tmp/venv/bin/python")" = "$HOST" ]
rm -rf /tmp/venv

# test: passing tags
for TAG in $PASSING; do
  virtualenv -p "$TAG" --with-traceback "/tmp/$TAG"
  [ "$(py tag "/tmp/$TAG/bin/python")" = "$TAG" ]
  "/tmp/$TAG/bin/python" -m pip install "$SAMPLEPKG"
  [ "$("/tmp/$TAG/bin/python" -m samplepkg)" = "success" ]
  rm -rf "/tmp/$TAG"
done

# test: test non-installable tags
for TAG in $NOINSTALL; do
  virtualenv -p "$TAG" --with-traceback "/tmp/$TAG"
  [ "$(py tag "/tmp/$TAG/bin/python")" = "$TAG" ]
  if "/tmp/$TAG/bin/python" -m pip install "$SAMPLEPKG"; then false; fi
  rm -rf "/tmp/$TAG"
done

# test: not found tags
for TAG in $NOTFOUND py20; do
  [[ "$(virtualenv -p "$TAG" "/tmp/$TAG" 2>&1)" == *"RuntimeError: failed to find interpreter "* ]]
  [ ! -d "/tmp/$TAG" ]
done

# finish
py uninstall --no-update-info
