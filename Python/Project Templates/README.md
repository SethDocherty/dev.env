# Getting Started with the Right Structure

**Table of Contents**:

- [Why Should You Use This Template](#why-should-you-use-this-template)
- [Tools used in this Project Template](#tools-used-in-this-project-template)
- [Template Directory Structure](#template-directory-structure)
- [How to use this Template](#how-to-use-this-template)
- [Static Code Analysis Tools](#static-code-analysis-tools)
- [Resources](#resources)

## Why Should You Use This Template?

This template is the result of my years refining the best way to structure a project so that it is reproducible and maintainable. Integrated into this template are a suite of tools that I've used to aid in maintaining code quality, codebase dependencies and much more.

This template allows you to:

✅ Create a readable structure for your project

✅ Automatically run tests when committing your code

✅ Enforce type hints at runtime

✅ Check issues in your code before committing

✅ Efficiently manage the dependencies in your project

✅ Create short and readable commands for repeatable tasks

✅ Automatically document your code

## Tools used in this Project Template

- **[Cookiecutter](https://cookiecutter.readthedocs.io/en/stable/)**: Create project directory structure from cookiecutters aka *project templates* - [article](https://towardsdatascience.com/cookiecutter-creating-custom-reusable-project-templates-fc85c8627b07)
- **[Poetry](https://python-poetry.org/)**: Dependency management - [article](https://towardsdatascience.com/how-to-effortlessly-publish-your-python-package-to-pypi-using-poetry-44b305362f9f)
- **Static Code Analysis Tools**: Examine your source code to point out possible issues - [article](https://inventwithpython.com/blog/2022/11/19/python-linter-comparison-2022-pylint-vs-pyflakes-vs-flake8-vs-autopep8-vs-bandit-vs-prospector-vs-pylama-vs-pyroma-vs-black-vs-mypy-vs-radon-vs-mccabe/)
- **[pre-commit plugins](https://pre-commit.com/)**: Automate code reviewing formatting  - [article](https://towardsdatascience.com/4-pre-commit-plugins-to-automate-code-reviewing-and-formatting-in-python-c80c6d2e9f5?sk=2388804fb174d667ee5b680be22b8b1f)

## Template Directory Structure

```bash
./{{ cookiecutter.__project_name }}        # Root directory representing the name of the project. This contains all project content and python package.
    ├── .vscode                            # Directory storing VSCode settings specific to the project  
    ├── config                             # Directory used to store configuration files
    ├── data                               # Directory used to organize data used for inputs, outputs and temporary data
    ├── docs                               # Directory containing multiple markdown files and/or other resource documentation for your project
    ├── notebooks                          # Directory to store notebooks
    ├── tests                              # Directory containing tests
    │   └── __init__.py                    # Treat directories contained within tests as modules 
    ├── {{ cookiecutter.__package_name }}  # Directory that contains your package source code for one or more modules
    │   ├── __init__.py                    # Treat directories contained within {{ cookiecutter.__package_name }} as modules
    │   ├── resources                      # Directory containing various files that the the package references. These files are not intended to be modified.
    │   │   └── project_task.xml           # XML template file used when creating a scheduled windows task
    │   ├── utils                          # Module containing project specific resources 
    │   │   ├── __init__.py                # Treat directories contained within utils as modules
    │   │   └── create_tasks.py            # Poetry script to deploy scheduled tasks.
    │   ├── main.py                        # Default main script
    │   └── config.py                      # Store logic to initialize values found in the config directory
    ├── .gitignore                         # File specifying files/directories to ignore as not to commit to Git
    ├── .pre-commit-config.yaml            # Configuration file for pre-commit hooks
    ├── LICENSE                            # Project license file. Choice of "MIT", "BSD", "Apache", "GNU General Public License", "ISC", "Other/Proprietary License"
    ├── poetry.lock                        # Poetry file containing all packages and their exact versions that it downloaded based on dependencies found in poetry.toml
    ├── poetry.toml                        # File containing project specific configurations that override global configurations for Poetry
    ├── pyproject.toml                     # Poetry file containing project dependencies
    └── README.md                          # Markdown file used to describe your project
```

## How to use this Template

1. Clone **dev.env** repo down to your local machine if it hasn't already.
2. Open your command line tool of choice and change the Current Working Directory (CWD) to ***Python\Template Structure*** folder.

   > **👀 ProTip**: You can open PowerShell directly from the *Template Structure* folder in File Explorer by typing *PowerShell* in the address bar or `Shift + Right Click` in File Explorer.
   >
3. Running the following command to install a **cookiecutter** dependent python environment.

```PowerShell
poetry install
```

4. Next, activate the installed poetry environment by running the following command:

```PowerShell
poetry shell
```

5. To deploy the cookiecutter template run:

```PowerShell
cookiecutter .
```

You'll be asked a few questions which will be applied to settings up the project package.

> Note: The "." in the command `cookiecutter .` will reference the cookiecutter template and generate a project directory structure in the CWD. If you would like to specify where to generate output, pass in the `-o, --output-dir <PATH>` command option.

You will find a generated project directory where `{{ cookiecutter.__project_name }}` matches your input for the question, `project_name`. Navigate into that directory and reference the [Project README](./{{%20cookiecutter.__project_name%20}}/README.md) to continue setting up the project environment.

> Note: Don't forget to run the command `deactivate` to disable the poetry environment created in **step 3**.

## Static Code Analysis Tools

**Static Code Analysis Tools**, also known as *linters*, are tools that scan through your python codebase to identify possible issues. Think of it as an early warning system to speed up your development by pointing out problems that can be fixed during the development process rather than in the QA stage. The linting tools included in this template include:

- **[Black](https://github.com/psf/black)**: A code formatter to modify the style of your code (typically resolving around proper whitespace) without affecting the behavior of the program.
- **[Mypy](https://github.com/python/mypy)**: A type checker that verifies that your codebase follows its own type annotations aka type hints.
- **[Ruff](https://github.com/astral-sh/ruff)**: An extremely fast error checker written in [Rust](https://www.rust-lang.org/), that identifies syntax errors or other code that will result in unhandled exceptions and crashes. It's a replacement of [Flake8](https://github.com/pycqa/flake8) and many of it's plugins.

## Resources

Below are additional resources I've referenced that are worth noting.

#### Resources for Project Layout and Packaging

- [My How and Why: pyproject.toml &amp; the &#39;src&#39; Project Structure – from python import logging – Thoughts and notes of a Python hobbyist](https://bskinn.github.io/My-How-Why-Pyproject-Src/)
- [Testing &amp; Packaging](https://hynek.me/articles/testing-packaging/)
  > Not using a `src` folder is known as a flat-layout (also known as "adhoc") See [link](https://setuptools.pypa.io/en/latest/userguide/package_discovery.html#flat-layout) for more info.
  >
- [src layout vs flat layout — Python Packaging User Guide](https://packaging.python.org/en/latest/discussions/src-layout-vs-flat-layout/#src-layout-vs-flat-layout)
- [What the heck is pyproject.toml?](https://snarky.ca/what-the-heck-is-pyproject-toml/)
- [How to read a (static) file from inside a Python package?](https://stackoverflow.com/questions/6028000/how-to-read-a-static-file-from-inside-a-python-package/58941536#58941536)

#### Resources Related to Cookiecutter

- [Cookiecutter-pypackage tutorial](https://cookiecutter-pypackage.readthedocs.io/en/latest/tutorial.html#tutorial)
- [List of Cookiecutter Templates to reference](https://github.com/audreyfeldroy/cookiecutter-pypackage#similar-cookiecutter-templates)
- [TalkPython Cookiecutter Course](https://training.talkpython.fm/courses/explore_cookiecutter_course/using-and-mastering-cookiecutter-templates-for-project-creation)
- [Cookiecutter Data Science](https://drivendata.github.io/cookiecutter-data-science/#cookiecutter-data-science)
- [Cookiecutter: Project Templates Made Easy](https://daniel.feldroy.com/posts/cookie-project-templates-made-easy)
- [Everything I know about Python...](https://jeffknupp.com/blog/2013/08/16/open-sourcing-a-python-project-the-right-way/)

#### Resources on Static Code Analysis Tools

- [PyCon US 2023 - An Overview of the Python Code Tool Landscape 2023](https://docs.google.com/presentation/d/1kHK5M4GpB_qSQO3aGbVzUtWaSwqsEaMqikuIeM4VDjk/edit#slide=id.p)
- [Python Static Analysis Tools](https://dev.to/camelcaseguy/python-static-analysis-tools-275b)
- [Type Hints for Busy Python Programmers](https://inventwithpython.com/blog/2019/11/24/type-hints-for-busy-python-programmers/)
- [mypy Type Hints Cheat Sheet](https://mypy.readthedocs.io/en/latest/cheat_sheet_py3.html)
- [4 pre-commit Plugins to Automate Code Reviewing and Formatting in Python](https://towardsdatascience.com/4-pre-commit-plugins-to-automate-code-reviewing-and-formatting-in-python-c80c6d2e9f5)
- [Ruff - The Fast, Rust-based Python Linter](https://talkpython.fm/episodes/show/400/ruff-the-fast-rust-based-python-linter)
