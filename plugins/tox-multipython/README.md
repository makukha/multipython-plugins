# tox-multipython
> python interpreter discovery plugin for [tox](https://tox.wiki) 3 and [multipython](https://github.com/makukha/multipython)

[![license](https://img.shields.io/github/license/makukha/tox-multipython.svg)](https://github.com/makukha/tox-multipython/blob/main/LICENSE)
[![python versions](https://img.shields.io/pypi/pyversions/tox-multipython.svg)](https://pypi.org/project/tox-multipython)
[![pypi](https://img.shields.io/pypi/v/tox-multipython.svg#v0.3.0)](https://pypi.python.org/pypi/tox-multipython)
[![tested with multipython](https://img.shields.io/badge/tested_with-multipython-x)](https://github.com/makukha/multipython)
[![uses docsub](https://img.shields.io/badge/uses-docsub-royalblue)](https://github.com/makukha/docsub)

> [!NOTE]
> [tox-multipython]() has twin plugin [virtualenv-multipython](https://github.com/makukha/virtualenv-multipython) that serves the same purpose for [tox](https://tox.wiki) 4

This [tox](https://tox.wiki) plugin comes pre-installed in [multipython](https://hub.docker.com/r/makukha/multipython) Docker image and is responsible for resolving tox environment name to Python executable. Most probably, you don't need to install it yourself.

Environment names supported are all multipython tags. More names may be added in the future.

# Testing

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

## Test report

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


# Changelog

Check [CHANGELOG.md](https://github.com/makukha/tox-multipython/tree/main/CHANGELOG.md)
