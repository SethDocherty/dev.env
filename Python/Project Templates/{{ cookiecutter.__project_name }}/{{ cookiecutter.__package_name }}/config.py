# -*- coding: utf-8 -*-
import configparser
import os
from pathlib import Path
from typing import Any, Dict, Union


def get_config_properties(file_name: str) -> Dict[str, Dict[str, str]] | Any:
    """Return the variables found in a user specified .ini file in the configurations folder.

    Args:
        file_name (str): Name of the configuration file found in the config folder. Note, file type suffix is
        not required to pass in.  By default we only accept .ini files.

    Returns:
        Dict[str, Any]: Dictionary of the sections and items in the configuration file.
    """
    # Create configparser object and read in the configuration file.
    config = configparser.ConfigParser()
    config.read(Path(CONFIG_DIR).joinpath(f"{file_name}.ini"))

    # Convert config parser object into a dictionary. First level dictionary key is the section name
    # and the second level dictionary are the section key names.
    return config.__dict__["_sections"]


def get_package_root() -> Union[str, os.PathLike[Any]]:
    """Grab the root directory of this package.

    NOTE, this variable is relatively referenced. If this file is moved, path's that depend on this
    method will generate the incorrect path.

    Returns:
        Union[str, os.PathLike]:: Root path of this project represented as a string
    """
    return str(Path(__file__).parent)


def get_project_root() -> Union[str, os.PathLike[Any]]:
    """Grab the root directory of this project.

    NOTE, this variable is relatively referenced. If this file is moved, path's that depend on this
    method will generate the incorrect path.

    Returns:
        Union[str, os.PathLike]:: Root path of this project represented as a string
    """
    return str(Path(__file__).parent.parent)


# Grab folder paths to referenced directories and files.
PACAKGE_DIR = get_package_root()
ROOT_DIR = get_project_root()
CONFIG_DIR = Path(ROOT_DIR).joinpath("config")
NOTEBOOK_PATH = Path(ROOT_DIR).joinpath("notebooks")
DATA_DIR = Path(ROOT_DIR).joinpath("data")
