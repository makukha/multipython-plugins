member := file_stem(invocation_dir())
proj := file_stem(justfile_dir())


default:
  @just --list


# install local dev dependencies with MacPorts
[group('init')]
init-macports:
    #!/usr/bin/env bash
    cat <<EOF | xargs sudo port install
      jq
      parallel
      shellcheck
      uv
      yq
    EOF
    just sync


# update local dev environment
[group('init')]
sync:
    uv sync


#
#  Development
# -------------
#


# add news item of type
[group('dev')]
news type id *msg:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ "{{id}}" = "-" ]; then
      id=`git rev-parse --abbrev-ref HEAD | cut -d- -f1`
    else
      id="{{id}}"
    fi
    if [ "{{msg}}" = "" ]; then
      msg=`git rev-parse --abbrev-ref HEAD | sed 's/^[0-9][0-9]*-//' | uv run caseutil -csentence`
    fi
    uv run towncrier create -c "{{msg}}" "$id.{{type}}.md"


# run linters
[group('dev')]
lint:
    find plugins/* -depth 0 | xargs uv run mypy
    uv run ruff check
    uv run ruff format --check
    shellcheck **/*.sh


# build python package
[group('dev')]
build:
    make build


# run tests
[group('dev')]
test *case:
    #!/usr/bin/env bash
    set -euo pipefail
    make build
    trap 'docker compose kill' SIGINT
    if [ -n "{{case}}" ]; then
      time docker compose run --rm runtest run "{{case}}"
    else
      time parallel --jobs 50% --load 90% --bar --color-failed --halt now,fail=1 \
        docker compose run --rm runtest run {} \
        ::: "$(docker compose run --rm runtest cases)"
    fi


# run specific test in debug mode
[group('dev')]
debug case:
    make build
    docker compose run --rm -i rundebug run "{{case}}"


# shell to testing container
[group('dev')]
shell:
    docker compose run --rm -i --entrypoint bash rundebug


# compile docs
[group('dev')]
docs:
  uv run docsub x generate
  cd plugins/tox-multipython && uv run docsub apply -i docs/part/main.md README.md
  cd plugins/virtualenv-multipython && uv run docsub apply -i docs/part/main.md README.md
  uv run docsub apply -i README.md


# free disk space
[group('dev')]
clean:
  docker builder prune
  docker image prune
  docker network prune


#
#  Release
# ---------
#
# just lint
# just test
# just docs
#
# just version [patch|minor|major]
# just changelog
# (proofread changelog)
#
# just build
# just push-pypi
# (create github release)
#


# bump project version (major|minor|patch)
[group('release')]
version *component:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -n "{{component}}" ]; then
        cd "plugins/{{component}}"
        echo "Bumping plugin {{component}}:"
    else
        echo "Bumping project multipython-plugins:"
    fi
    uv run bump-my-version show-bump
    printf 'Enter bump path: '
    read BUMP
    uv run bump-my-version bump -- "$BUMP"
    uv lock


# collect changelog entries
[group('release')]
changelog member:
    #!/usr/bin/env bash
    set -euo pipefail
    version=$(uv run bump-my-version show current_version 2>/dev/null)
    uv run towncrier build --yes --version "$version"
    sed -e's/^### \(.*\)$/***\1***/; s/\([a-z]\)\*\*\*$/\1:***/' -i '' CHANGELOG.md


# publish package on PyPI
[group('release')]
push-pypi plugin:
    make build
    cd plugins/{{plugin}} && uv publish
