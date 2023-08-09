<h1 align="center">{{ cookiecutter.project_name }}</h1>

<p align="center">
    <a href="https://python-poetry.org//"><img src="https://img.shields.io/endpoint?url=https://python-poetry.org/badge/v0.json" alt="Poetry" style="max-width:100%;"></a>
    <a href="https://mypy-lang.org/"><img src="https://www.mypy-lang.org/static/mypy_badge.svg" alt="Checked with mypy" style="max-width:100%;"></a>
    <a href="https://github.com/psf/black"><img alt="Code style: black" src="https://img.shields.io/badge/code%20style-black-000000.svg" style="max-width:100%;"></a>
    <a href="https://github.com/astral-sh/ruff"><img src="https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/astral-sh/ruff/main/assets/badge/v2.json" alt="Ruff" style="max-width:100%;"></a>
</p>

{{ cookiecutter.description }}

## Table of Contents

- [Setting up the Project Environment](#setting-up-the-project-environment)
- [Installing Static Code Analysis Tools](#installing-static-code-analysis-tools)
- [Scripts and Executables](#scripts-and-executables)

## Setting up the Project Environment

1. To install all python dependencies for this project, open terminal into the root of {{ cookiecutter.__project_name }} directory and run the following command:

```bash
poetry install
```

2. Activate the installed poetry environment.

```bash
poetry shell
```

3. Next, initialize a blank git repository to version control your project by running:

```bash
git init .
```

> Note: Note: The "." in the command `git init .` is a reference to the current working directory (CWD).

At this point, your project environment is ready to go!

## Installing Static Code Analysis Tools

The linters **[Black](https://github.com/psf/black)**, **[Mypy](https://github.com/python/mypy)** and **[Ruff](https://github.com/astral-sh/ruff)** have been integrated into a [pre-commit](https://pre-commit.com/#2-add-a-pre-commit-configuration) configuration file (file named `.pre-commit-config.yaml`) as to ensure that no bugs or issues appear in your code before pushing changes to your repo. To install the pre-commit git hooks:

1. Run the following command:

```bash
pre-commit install
```

now `pre-commit` will run automatically on `git commit`.

2. (Optional) Run against all files in your repo with the following command:

```bash
pre-commit run --all-files
```

### Adding more pre-commit plugins

[Adding pre-commit plugins](https://pre-commit.com/#adding-pre-commit-plugins-to-your-project) to your project is done with the `.pre-commit-config.yaml` configuration file. To view a list of all supported plugins, visit this [link](https://pre-commit.com/hooks.html).

## Scripts and Executables

A set of pre-defined command line scripts have been configured to be used with {{ cookiecutter.project_name }}. Below is an overview of each script that can be executed by running the command `poetry run <script name>`

#### create-task

Create a task within Windows Task Scheduler for running a python script that's in the package root directory of {{ cookiecutter.__package_name }}. Run the following command for more details: `poetry run create-task --help`
