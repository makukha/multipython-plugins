SHELL=/bin/bash -euo pipefail

# python packages

.PHONY: build
build: \
	plugins/tox-multipython/dist \
	plugins/virtualenv-multipython/dist \
	tests/samplepkg/dist

%/dist: %/src %/pyproject.toml %/README.md
	uv lock
	rm -rf $@
	cd $(dir $@) && uv build -o dist
