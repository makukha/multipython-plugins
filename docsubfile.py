# ruff: noqa: S603 = allow check_output with arbitrary cmdline
from itertools import product
import json
from pathlib import Path
from shlex import split
from subprocess import check_output
import tomllib

import bracex
from docsub import Environment, pass_env, click


IMG = 'makukha/multipython:unsafe'
CASES_TOML = Path('tests/cases.toml')

PASSING = '✅'
NOINSTALL = '💥'
NOTFOUND = '🚫'
COLSP = ' '


@click.group()
def x(): ...


@x.command()
@pass_env
def generate(env: Environment) -> None:
    """
    Generate test reports.
    """
    temp_dir = env.get_temp_dir('reports')

    # get source data
    with CASES_TOML.open('rb') as f:
        data = tomllib.load(f)

    # factors
    suites = [k for k in data.keys() if k != 'requirements']
    venvs = [k for k in data['requirements'].keys() if k not in suites]

    # get tags
    tags = check_output(
        split(f'docker run --rm {IMG} py ls --tag'),
        text=True,
    ).splitlines()

    # generate reports
    for suite, venv in product(suites, venvs):
        case = f'{suite}-{venv}'

        # prepare matrix
        cross = {tag: val[venv] for tag, val in data[suite].items()}
        for tag, val in cross.items():
            marks = [
                *((t, 'P') for t in filter(None, bracex.expand(val['passing']))),
                *((t, 'I') for t in filter(None, bracex.expand(val['noinstall']))),
                *((t, 'F') for t in filter(None, bracex.expand(val['notfound']))),
            ]
            marks.sort(key=lambda tm: tags.index(tm[0]))
            cross[tag] = ''.join(tm[1] for tm in marks)

        # write matrix
        with (temp_dir / f'{case}.json').open('wt') as f:
            result = dict(
                suite=suite,
                venv=venv,
                targets=tags,
                host_results=cross,
            )
            json.dump(result, f, indent=2)


@x.command()
@click.argument('suite', type=str, required=True)
@pass_env
def pretty(env: Environment, suite: str) -> None:
    """
    Print report in compact terminal-based format.
    """
    ALPHA = 'ABCDEFGHIJKLMNOPQRSTUVW'
    temp_dir = env.get_temp_dir('reports')

    with (temp_dir / f'{suite}.json').open() as f:
        data = json.load(f)
    row_title = 'HOST'
    col_title = 'TARGETS'
    tags = data['targets']

    if len(tags) > len(ALPHA):
        raise RuntimeError('Too many tags')

    width = max(len(row_title), max(len(v) for v in tags))

    print(f'{row_title: >{width}}    {col_title}')
    print(f'{"—" * width}    {COLSP.join(ALPHA[: len(tags)])}')
    for i, tag in enumerate(tags):
        res = data['host_results'].get(tag)
        marks = (
            [{'P': PASSING, 'I': NOINSTALL, 'F': NOTFOUND}[x] for x in res]
            if res
            else COLSP.join('.' * len(tags))
        )
        print(f'{tag: >{width}}  {ALPHA[i]} {"".join(marks)}')
