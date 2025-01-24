# multipython-plugins

> Workspace for [multipython]() plugins: [tox-multipython](https://pypi.org/project/tox-multipython) and [virtualenv-multipython](https://pypi.org/project/virtualenv-multipython)

[![uses docsub](https://img.shields.io/badge/uses-docsub-royalblue)](https://github.com/makukha/docsub)
[![tested with multipython](https://img.shields.io/badge/tested_with-multipython-x)](https://github.com/makukha/multipython)
[![license](https://img.shields.io/github/license/makukha/virtualenv-multipython.svg)](https://github.com/makukha/virtualenv-multipython/blob/main/LICENSE)

These plugins are intended to be installed under [multipython](https://github.com/makukha/multipython) docker image. This is done automatically during multipython release, and there seems to be no reason to manually install any of them.

* [tox-multipython](#tox-multipython) — Python interpreter discovery plugin for [tox](https://tox.wiki) 3 and 4
* [virtualenv-multipython](#virtualenv-multipython) — [virtualenv](https://virtualenv.pypa.io) discovery plugin

## Use cases

### virtualenv

* [virtualenv-multipython](#virtualenv-multipython) allows to use multipython tags to select Python interpreter

### tox 4

* [tox-multipython](#tox-multipython) is used to match multipython tag in [tox environment name](https://tox.wiki/en/latest/user_guide.html#test-environments)
* [virtualenv-multipython](#virtualenv-multipython) then finds multipython interpreter with `py bin --path <tag>`

### tox 3

* [tox-multipython](#tox-multipython) uses [legacy hook](https://tox.wiki/en/3.27.1/plugins.html#tox.hookspecs.tox_get_python_executable) and [virtualenv-multipython](#virtualenv-multipython) to select multipython interpreter path based on [tox environment name](https://tox.wiki/en/latest/user_guide.html#test-environments)
* [virtualenv-multipython](#virtualenv-multipython) is installed alongside


# tox-multipython

<!-- docsub: begin -->
<!-- docsub: include plugins/tox-multipython/docs/part/badges.md -->
<!-- docsub: end -->

<!-- docsub: begin -->
<!-- docsub: include plugins/tox-multipython/docs/part/main.md -->
<!-- docsub: end -->


# virtualenv-multipython

<!-- docsub: begin -->
<!-- docsub: include plugins/virtualenv-multipython/docs/part/badges.md -->
<!-- docsub: end -->

<!-- docsub: begin -->
<!-- docsub: include plugins/tox-multipython/docs/part/main.md -->
<!-- docsub: end -->


# Testing

Testing suites (scenarios) for python discovery and provisioning virtual environments:
1. [**tox3**](#venv) — under tox 3
2. [**tox4**](#venv) — under tox 4
3. [**venv**](#venv) — in virtualenv

Virtualenv supports discovery plugins since v20. In v20.22, it dropped support for Python <=3.6, in v20.27 it dropped support for Python 3.7. This is why for every scenario above we test separate cases with different outcomes:

1. `virtualenv>=20`
2. `virtualenv>=20,<20.27`
3. `virtualenv>=20,<20.22`

In every case, both `tox-multipython` and `virtualenv-multipython` are installed under *host tag environment* and used to discover and/or initialize *target tag environments*, where tags are all tags supported by multipython.

When plugins are installed inside *host tag* environment, for every *target tag* environment icons are used to denote test outcome:

* ✅ — all testing requirements are satisfied for *target tag*
* 🚫️ — *target tag* interpreter is not discoverable
* 💥 — *target tag* interpreter is discoverable, but virtual environment with *sample package* cannot be created


## tox3

### Assumptions on *host tag*

* `tox>=3,<4`
* `virtualenv` — 3 different cases
* `tox-multipython` and `virtualenv-multipython` are installed
* `VIRTUALENV_DISCOVERY` environment variable is not set

### Requirements on *target tag*

* `tox` environment for *target tag* is created
* inside tox environment, `{envpython}` version matches *target tag*
* inside tox environment, `python` version matches *target tag*
* *sample package* is successfully installed in tox environment
* entrypoint script of *sample package* is successfully called

<small>
<table>
<thead>
<th><code>tox>=3,<4; virtualenv>=20</code></th>
<th><code>tox>=3,<4; virtualenv>=20,<20.27</code></th>
<th><code>tox>=3,<4; virtualenv>=20,<20.22</code></th>
</thead>
<tbody>
<tr>
<td>
<!-- docsub: begin -->
<!-- docsub: x pretty tox3-v__ -->
<!-- docsub: lines after 1 upto -1 -->
<pre>
</pre>
<!-- docsub: end -->
</td>
<td>
<!-- docsub: begin -->
<!-- docsub: x pretty tox3-v27 -->
<!-- docsub: lines after 1 upto -1 -->
<pre>
</pre>
<!-- docsub: end -->
</td>
<td>
<!-- docsub: begin -->
<!-- docsub: x pretty tox3-v22 -->
<!-- docsub: lines after 1 upto -1 -->
<pre>
</pre>
<!-- docsub: end -->
</td>
</tr>
</tbody>
</table>
</small>


## tox4

### Assumptions on *host tag*

* `python>=3.7`
* `tox>=4,<5`
* `virtualenv` — 3 different cases
* `tox-multipython` and `virtualenv-multipython` are installed
* `VIRTUALENV_DISCOVERY=multipython`

### Requirements on *target tag*

* `tox` environment for *target tag* is created
* inside tox environment, `{env_python}` version matches *target tag*
* inside tox environment, `python` version matches *target tag*
* *sample package* is successfully installed in tox environment
* entrypoint script of *sample package* is successfully called

<small>
<table>
<thead>
<th><code>tox>=4,<5; virtualenv>=20</code></th>
<th><code>tox>=4,<5; virtualenv>=20,<20.27</code></th>
<th><code>tox>=4,<5; virtualenv>=20,<20.22</code></th>
</thead>
<tbody>
<tr>
<td>
<!-- docsub: begin -->
<!-- docsub: x pretty tox4-v__ -->
<!-- docsub: lines after 1 upto -1 -->
<pre>
</pre>
<!-- docsub: end -->
</td>
<td>
<!-- docsub: begin -->
<!-- docsub: x pretty tox4-v27 -->
<!-- docsub: lines after 1 upto -1 -->
<pre>
</pre>
<!-- docsub: end -->
</td>
<td>
<!-- docsub: begin -->
<!-- docsub: x pretty tox4-v22 -->
<!-- docsub: lines after 1 upto -1 -->
<pre>
</pre>
<!-- docsub: end -->
</td>
</tr>
</tbody>
</table>
</small>


## venv

### Assumptions on *host tag*

* `virtualenv` — 3 different cases
* `virtualenv-multipython` is installed
* `VIRTUALENV_DISCOVERY=multipython`

### Requirements on *host tag*

* when called with no `--python` requested, `virtualenv` uses *host tag* python

### Requirements on *target tag*

* `virtualenv` environment for *target tag* is created
* inside virtualenv environment, `bin/python` version matches *target tag*
* *sample package* is successfully installed in virtualenv environment
* entrypoint script of *sample package* is successfully called

<small>
<table>
<thead>
<th><code>virtualenv>=20</code></th>
<th><code>virtualenv>=20,<20.27</code></th>
<th><code>virtualenv>=20,<20.22</code></th>
</thead>
<tbody>
<tr>
<td>
<!-- docsub: begin -->
<!-- docsub: x pretty venv-v__ -->
<!-- docsub: lines after 1 upto -1 -->
<pre>
</pre>
<!-- docsub: end -->
</td>
<td>
<!-- docsub: begin -->
<!-- docsub: x pretty venv-v27 -->
<!-- docsub: lines after 1 upto -1 -->
<pre>
</pre>
<!-- docsub: end -->
</td>
<td>
<!-- docsub: begin -->
<!-- docsub: x pretty venv-v22 -->
<!-- docsub: lines after 1 upto -1 -->
<pre>
</pre>
<!-- docsub: end -->
</td>
</tr>
</tbody>
</table>
</small>


# Changelog

Check [multipython-plugins changelog](https://github.com/makukha/multipython-plugins/tree/main/CHANGELOG.md)
