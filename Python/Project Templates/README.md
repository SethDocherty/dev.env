# Getting Started with the Right Structure

**Table of Contents**:

- [Why Should You Use This Template](#why-should-you-use-this-template)
- [Tools used in this Project Template](#tools-used-in-this-project-template)
- [Template Directory Structure](#template-directory-structure)
- [How to use this Template](#how-to-use-this-template)
- [Resources](#resources)

## Why Should You Use This Template?

This template is the result of my years refining the best way to structure a project so that it is reproducible and maintainable. Integrated into this template are a suite of tools that I've used over the years to aid in maintaining code quality, codebase dependencies and much more.

This template allows you to:

✅ Create a readable structure for your project

✅ Automatically run tests when committing your code

✅ Enforce type hints at runtime

✅ Check issues in your code before committing

✅ Efficiently manage the dependencies in your project

✅ Create short and readable commands for repeatable tasks

✅ Automatically document your code

## Tools used in this Project Template

- [Poetry](https://python-poetry.org/): Dependency management - [article](https://towardsdatascience.com/how-to-effortlessly-publish-your-python-package-to-pypi-using-poetry-44b305362f9f)
- [pre-commit plugins](https://pre-commit.com/): Automate code reviewing formatting  - [article](https://towardsdatascience.com/4-pre-commit-plugins-to-automate-code-reviewing-and-formatting-in-python-c80c6d2e9f5?sk=2388804fb174d667ee5b680be22b8b1f)
- [GitHub Actions](https://docs.github.com/en/actions): Automate your workflows, making it faster to build, test, and deploy your code - [article](https://pub.towardsai.net/github-actions-in-mlops-automatically-check-and-deploy-your-ml-model-9a281d7f3c84?sk=d258c20a7ff7a1db44327c27d3f36efb)
- [pdoc](https://github.com/pdoc3/pdoc): Automatically create an API documentation for your project

## Template Directory Structure

```bash
.
├── .vscode                         # Directory storing VSCode settings specific to the project                          
├── config                          # Directory used to store configuration files
├── data                            # Directory used to organize data used for inputs, outputs and temporary data
├── docs                            # Directory containing multiple markdown files and/or other resource documentation for your project
├── notebooks                       # Directory to store notebooks
├── {{package name}}                # Directory that contains your package source code for one or more modules
│   ├── __init__.py                 # Treat directories contained within {{package_name}} as modules
│   ├── config.py                   # Store logic to initialize values found in the config directory
└── tests                           # Directory containing tests
    ├── __init__.py                 # Treat directories contained within tests as modules 
├── .flake8                         # Configuration file for flake8 - a Python formatter tool
├── .gitignore                      # File specifying files/directories to ignore as not to commit to Git
├── .pre-commit-config.yaml         # Configuration file for pre-commit hooks
├── poetry.lock                     # Poetry file containing all packages and their exact versions that it downloaded based on dependencies found in poetry.toml
├── poetry.toml                     # File containing project specific configurations that override global configurations for Poetry
├── pyproject.toml                  # Poetry file containing project dependencies
├── README.md                       # Markdown files used to describe your project
```

## How to use this Template

TODO

## Resources

TODO
