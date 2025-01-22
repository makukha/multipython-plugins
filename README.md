# multipython-plugins

> Workspace for [multipython]() plugins: [tox-multipython](https://pypi.org/project/tox-multipython) and [virtualenv-multipython](https://pypi.org/project/virtualenv-multipython)

[![uses docsub](https://img.shields.io/badge/uses-docsub-royalblue)](https://github.com/makukha/docsub)
[![tested with multipython](https://img.shields.io/badge/tested_with-multipython-x)](https://github.com/makukha/multipython)
[![license](https://img.shields.io/github/license/makukha/virtualenv-multipython.svg)](https://github.com/makukha/virtualenv-multipython/blob/main/LICENSE)

These plugins are intended to be installed under [multipython](https://github.com/makukha/multipython) docker image. This is done automatically during multipython release, and there seems to be no reason to manually install any of them.

* [tox-multipython](#tox-multipython) — Python interpreter resolution plugin for [tox](https://tox.wiki) 3 and 4
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

[![pypi](https://img.shields.io/pypi/v/tox-multipython.svg#v0.2.2)](https://pypi.python.org/pypi/tox-multipython)
[![python versions](https://img.shields.io/pypi/pyversions/tox-multipython.svg)](https://pypi.org/project/tox-multipython)

This plugin is intended to be installed under [multipython](https://github.com/makukha/multipython) docker image. This is done automatically during multipython release, and there seems to be no reason to install this plugin manually by anyone.

Environment names supported are all [multipython](https://github.com/makukha/multipython) tags.

## Installation

```shell
$ pip install tox-multipython
```

## Configuration

No configuration steps are needed.

## Testing

There is one test suite:

1. `tox3` — `tox>=3,<4` is installed in *host tag* environment, and `tox run` is executed on `tox.ini` with env names equal to *target tags*. This test includes subtests:
    - assert `{env_python}` version inside tox env
    - assert `python` version inside tox env
    - install externally built *sample package* in tox environment
    - execute entrypoint of *sample package*

Virtualenv supports discovery plugins since v20. In v20.22, it dropped support for Python <=3.6, in v20.27 it dropped support for Python 3.7.

This is why we use 6 different test setups:

1. `tox3` + `virtualenv>=20`
1. `tox3` + `virtualenv>=20,<20.27`
1. `tox3` + `virtualenv>=20,<20.22`

### Test report

When `tox-multipython` is installed inside *host tag* environment, it allows to use selected ✅ *target tag* (create virtualenv environment or use as tox env name in `env_list`) and automatically discovers corresponding [multipython](https://github.com/makukha/multipython) executable. For failing 💥 *target tag*, interpreter is discoverable, but virtual environment with *sample package* cannot be created.

*Host tag* and *Target tags* are valid [multipython](https://hub.docker.com/r/makukha/multipython) tags. *Host tags* are listed vertically (rows), *target tags* are listed horizontally (columns).

<table>
<tbody>

<tr>
<td>
<code>tox>=3,<4</code>, <code>virtualenv>=20</code>
<!-- docsub: begin -->
<!-- docsub: x pretty tox3-v__ -->
<!-- docsub: lines after 1 upto -1 -->
<pre>
</pre>
<!-- docsub: end -->
</td>
</tr>

<tr>
<td>
<code>tox>=3,<4</code>, <code>virtualenv>=20,<20.27</code>
<!-- docsub: begin -->
<!-- docsub: x pretty tox3-v27 -->
<!-- docsub: lines after 1 upto -1 -->
<pre>
</pre>
<!-- docsub: end -->
</td>
</tr>

<tr>
<td>
<code>tox>=3,<4</code>, <code>virtualenv>=20,<20.22</code>
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

## Changelog

Check [tox-multipython's changelog](https://github.com/makukha/multipython-plugins/tree/main/plugins/tox-multipython/CHANGELOG.md)


# virtualenv-multipython

[![pypi](https://img.shields.io/pypi/v/virtualenv-multipython.svg#v0.4.1)](https://pypi.python.org/pypi/virtualenv-multipython)
[![python versions](https://img.shields.io/pypi/pyversions/virtualenv-multipython.svg)](https://pypi.org/project/virtualenv-multipython)

This plugin is intended to be installed under [multipython](https://github.com/makukha/multipython) docker image. This is done automatically during multipython release, and there seems to be no reason to install this plugin manually by anyone.

Environment names supported are all [multipython](https://github.com/makukha/multipython) tags.

## Installation

```shell
$ pip install virtualenv-multipython
```

## Configuration

Set `multipython` to be the default discovery method for virtualenv:

### Option 1. Environment variable

```shell
VIRTUALENV_DISCOVERY=multipython
````

### Option 2. Configuration file

```ini
[virtualenv]
discovery = multipython
```

Add these lines to one of [virtualenv configuration files](https://virtualenv.pypa.io/en/latest/cli_interface.html#conf-file). Under e.g. Debian `root`, the file is `/root/.config/virtualenv/virtualenv.ini`

## Usage

This plugin allows using multipython tags in virtualenv:

```shell
$ virtualenv --python py314t /tmp/venv
```

## Behaviour

* Loosely follow behaviour of builtin virtualenv discovery, with some important differences:
* Try requests one by one, starting with [`--try-first-with`](https://virtualenv.pypa.io/en/latest/cli_interface.html#try-first-with); if one matches multipython tag or is an absolute path, return it to virtualenv.
* If no version was requested at all, use `sys.executable`
* If no request matched conditions above, fail to discover interpreter.
* In particular, command names on `PATH` are not discovered.

## Testing

There are two test suites:

1. `venv` — Install `virtualenv` in *host tag* environment and create virtual environments for all *target tags*. Environment's python version must match *target tag*.
2. `tox4` — `tox` and `virtualenv` are installed in *host tag* environment, and `tox run` is executed on `tox.ini` with env names equal to *target tags*. This test includes subtests:
    - assert `{env_python}` version inside tox env
    - assert `python` version inside tox env
    - install externally built *sample package* in tox environment
    - execute entrypoint of *sample package*

Virtualenv supports discovery plugins since v20. In v20.22, it dropped support for Python <=3.6, in v20.27 it dropped support for Python 3.7.

This is why we use 6 different test setups:

1. `venv` + `virtualenv>=20`
1. `venv` + `virtualenv>=20,<20.27`
1. `venv` + `virtualenv>=20,<20.22`
1. `tox4` + `virtualenv>=20`
1. `tox4` + `virtualenv>=20,<20.27`
1. `tox4` + `virtualenv>=20,<20.22`

### Test report

When `virtualenv-multipython` is installed inside *host tag* environment, it allows to use selected ✅ *target tag* (create virtualenv environment or use as tox env name in `env_list`) and automatically discovers corresponding [multipython](https://github.com/makukha/multipython) executable. For prohibited 🚫️ *target tag*, python executable is not discoverable. For failing 💥 *target tag*, interpreter is discoverable, but virtual environment with *sample package* cannot be created.

*Host tag* and *Target tags* are valid [multipython](https://hub.docker.com/r/makukha/multipython) tags. *Host tags* are listed vertically (rows), *target tags* are listed horizontally (columns).

<table>
<tbody>

<tr>

<td>
<code>virtualenv>=20</code>
<!-- docsub: begin -->
<!-- docsub: x pretty venv-v__ -->
<!-- docsub: lines after 1 upto -1 -->
<pre>
</pre>
<!-- docsub: end -->
</td>

<td>
<code>tox>=4,<5</code>, <code>virtualenv>=20</code>
<!-- docsub: begin -->
<!-- docsub: x pretty tox4-v__ -->
<!-- docsub: lines after 1 upto -1 -->
<pre>
</pre>
<!-- docsub: end -->
</td>

</tr>

<tr>

<td>
<code>virtualenv>=20,<20.27</code>
<!-- docsub: begin -->
<!-- docsub: x pretty venv-v27 -->
<!-- docsub: lines after 1 upto -1 -->
<pre>
</pre>
<!-- docsub: end -->
</td>

<td>
<code>tox>=4,<5</code>, <code>virtualenv>=20,<20.27</code>
<!-- docsub: begin -->
<!-- docsub: x pretty tox4-v27 -->
<!-- docsub: lines after 1 upto -1 -->
<pre>
</pre>
<!-- docsub: end -->
</td>

</tr>

<tr>

<td>
<code>virtualenv>=20,<20.22</code>
<!-- docsub: begin -->
<!-- docsub: x pretty venv-v22 -->
<!-- docsub: lines after 1 upto -1 -->
<pre>
</pre>
<!-- docsub: end -->
</td>

<td>
<code>tox>=4,<5</code>, <code>virtualenv>=20,<20.22</code>
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


## Changelog

Check [virtualenv-multipython's changelog](https://github.com/makukha/multipython-plugins/tree/main/plugins/virtualenv-multipython/CHANGELOG.md)
