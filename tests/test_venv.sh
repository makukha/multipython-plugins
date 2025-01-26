#!/usr/bin/env bash
set -eEuo pipefail

# shellcheck disable=SC1091 # shared.sh already checked
. shared.sh

# inputs
read -r DEPS HOST TARGETS <<<"$@"
IFS=: read -r PASSING NOEXEC NOINSTALL NOTFOUND <<<"$TARGETS"
validate_image_tags_coverage "$PASSING $NOEXEC $NOINSTALL $NOTFOUND"

# setup
py install --sys "$HOST" --no-update-info
pip uninstall -y tox virtualenv
rm /root/.config/virtualenv/virtualenv.ini
# shellcheck disable=SC2046 # not quoted intentionally
pip_install $(tr : ' ' <<<"$DEPS") \
  "virtualenv-multipython @ file://$(find /work/plugins/virtualenv-multipython/dist -name '*.whl')"
pip_install_if_debug loguru
export VIRTUALENV_DISCOVERY=multipython

# test: no --python specified, use system
virtualenv --no-seed --with-traceback "/tmp/venv"
[ "$(py tag "/tmp/venv/bin/python")" = "$HOST" ]
rm -rf /tmp/venv

# test: test passing tags
for TAG in $PASSING; do
  [ "$(get_venv_outcome "$TAG")" = "passing" ]
done

# test: test non-executable tags
for TAG in $NOEXEC; do
  [ "$(get_venv_outcome "$TAG")" = "noexec" ]
done

# test: test non-installable tags
for TAG in $NOINSTALL; do
  [ "$(get_venv_outcome "$TAG")" = "noinstall" ]
done

# test: test non-discoverable tags
for TAG in $NOTFOUND py20; do
  [ "$(get_venv_outcome "$TAG")" = "notfound" ]
done

# finish
py uninstall --no-update-info
