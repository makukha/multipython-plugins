# virtualenv-multipython
> virtualenv discovery plugin for [multipython](https://github.com/makukha/multipython)

[![python versions](https://img.shields.io/pypi/pyversions/virtualenv-multipython.svg)](https://pypi.org/project/virtualenv-multipython)
[![pypi](https://img.shields.io/pypi/v/virtualenv-multipython.svg#v0.4.1)](https://pypi.python.org/pypi/virtualenv-multipython)
[![tested with multipython](https://img.shields.io/badge/tested_with-multipython-x)](https://github.com/makukha/multipython)
[![uses docsub](https://img.shields.io/badge/uses-docsub-royalblue)](https://github.com/makukha/docsub)
[![license](https://img.shields.io/github/license/makukha/virtualenv-multipython.svg)](https://github.com/makukha/virtualenv-multipython/blob/main/LICENSE)

> [!NOTE]
> [virtualenv-multipython]() has twin plugin [tox-multipython](https://github.com/makukha/tox-multipython) that serves similar purpose for [tox](https://tox.wiki) 3

This [virtualenv](https://virtualenv.pypa.io) plugin comes pre-installed in [multipython](https://hub.docker.com/r/makukha/multipython) Docker image and is responsible for resolving tox environment name to Python executable. Most probably, you don't need to install it yourself.

Environment names supported are all multipython tags. More names may be added in the future.

# Behaviour

* Loosely follow behaviour of builtin virtualenv discovery, with some important differences:
* Try requests one by one, starting with [`--try-first-with`](https://virtualenv.pypa.io/en/latest/cli_interface.html#try-first-with); if one matches multipython tag or is an absolute path, return it to virtualenv.
* If no version was requested at all, use `sys.executable`
* If no request matched conditions above, fail to discover interpreter.
* In particular, command names on `PATH` are not discovered.

# Testing

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

## Test report

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


# Changelog

Check [CHANGELOG.md](https://github.com/makukha/virtualenv-multipython/tree/main/CHANGELOG.md)
