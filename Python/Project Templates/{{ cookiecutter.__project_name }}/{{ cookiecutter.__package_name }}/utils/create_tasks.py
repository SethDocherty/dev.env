# -*- coding: utf-8 -*-
import argparse
import os
import platform
import subprocess
import sys
import tempfile
import textwrap
import xml.etree.ElementTree as et
from pathlib import Path
from shutil import copyfile
from typing import Any, Optional

from .. import config as cf


def get_task_properties(
    file_name: str, enable_gui: Optional[bool] = True
) -> dict[str, dict[str, Any]]:
    """
    Return a dictionary of task properties to modify XML file for a Windows Scheduler Task.

    NOTE: The `Task Action` Working directory is located at the package root directory. All python scripts to be called must
    reside in the root folder for the package.

    file_name (str): Name of the python file that will be called to run in task scheduler.
    enable_gui (bool, Optional): Enable or disable the console window launching when running python executable. Default is True.
        NOTE: pythonw.exe suppresses the console window from launching.

    Returns:
        dict[str, dict[str, Any]]: Dictionary that's populated with key/val information to create task.
    """
    if enable_gui:
        python_executable = "python.exe"
    else:
        python_executable = "pythonw.exe"

    task_properties = {
        "xml": {
            "WorkingDirectory": Path(cf.CONFIG_DIR, "project_resources"),
            "FileName": "project_task.xml",
        },
        "task action": {
            "WorkingDirectory": Path(cf.PACAKGE_DIR),
            "Command": Path(cf.ROOT_DIR, *[".venv", "Scripts", python_executable]),
            "Arguments": f"{file_name}.py",
        },
    }
    return task_properties


def create_task(
    task_name: str, task_root_folder: str, task_folder: str, file_name: str
) -> None:
    r"""
    Create an automated task from a python file found in the package root directory.

    NOTE: We currently support Windows only.

    Args:
        task_name (str): Name of task that will be created which will appear in the scheduling task application.
        task_root_folder (str): Name of the root folder where taskgroup folders are stored within Windows Task Scheduler. Default string is 'python'.
        task_folder (str): Name of the taskgroup folder that's `\` character delimited is used to specify where the registered
        task is placed in the task folder hierarchy.
        file_name (str): Name of the python file that will be called to run in task scheduler.
            NOTE: This file must be found in the package root directory.

    Returns:
        _type_: None
    """
    if platform.system() == "Windows":
        task_dict = get_task_properties(file_name)

        # Source location of the of the xml template file that will be copied.
        task_xml = Path(
            task_dict["xml"]["WorkingDirectory"], task_dict["xml"]["FileName"]
        )

        # Create Temporary file that's stored in a system-agnostic temporary files location
        with tempfile.NamedTemporaryFile(
            suffix=".xml", delete=False, mode="wb"
        ) as tmpfile:
            copied_xml = tmpfile.name
            copyfile(task_xml, copied_xml)

        # Prep XML object for modification
        tree = et.ElementTree(file=task_xml)
        root = tree.getroot()

        # Write changes to XML file
        # # Add task grouping name
        # for elem in root.iter("{http://schemas.microsoft.com/windows/2004/02/mit/task}URI"):
        #     elem.text = task_folder
        #     tree.write(copied_xml)

        # Add name of the current user logged into the system
        for elem in root.iter(
            "{http://schemas.microsoft.com/windows/2004/02/mit/task}UserId"
        ):
            elem.text = os.getlogin()
            tree.write(copied_xml)

        # Add path to file for working directory tag
        for elem in root.iter(
            "{http://schemas.microsoft.com/windows/2004/02/mit/task}WorkingDirectory"
        ):
            elem.text = f'{task_dict["task action"]["WorkingDirectory"]}'
            tree.write(copied_xml)

        # Add python executable filepath from the project .venv path to command tag.
        for elem in root.iter(
            "{http://schemas.microsoft.com/windows/2004/02/mit/task}Command"
        ):
            elem.text = f'"{task_dict["task action"]["Command"]}"'
            tree.write(copied_xml)

        # Add name of runner to arguments tag
        for elem in root.iter(
            "{http://schemas.microsoft.com/windows/2004/02/mit/task}Arguments"
        ):
            elem.text = f'"{task_dict["task action"]["Arguments"]}"'
            tree.write(copied_xml)

        # Run command to run schtasks.exe and import modified xml
        # /F command will overwrite task if it already exists.
        cmd_line_call = rf'schtasks /create /TN "\{task_root_folder}\{task_folder}\{task_name}" /XML "{copied_xml}" /F'
        print(f"Running the following command:\n{cmd_line_call}")
        subprocess.call(cmd_line_call)

        # Delete Tmp XML File
        Path(copied_xml).unlink()

        return None

    else:
        print(
            f"We currently do not support an automated approach to creating Cron Jobs on {platform.system()}"
        )
        sys.exit()


def create() -> None:
    """Function to initialize creating a task"""
    # Capture input arguments
    parser = argparse.ArgumentParser(
        prog="createtask",
        add_help=True,
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description=textwrap.dedent(
            """\
            Description: Create a task within Windows Task Scheduler for running a python script that is stored within the package directory.

            By default, all tasks can be found under `Task Scheduler Library`, saved to a root taskgroup folder titled `python` under the group, `tasks`. This can be overridden with the `--root` and --group argument`

            NOTE: Encapsulate input values with quotes if you require spaces e.g. --task "My Cool Task!"
            """
        ),
    )

    parser.add_argument(
        "--task",
        dest="taskName",
        type=str,
        required=True,
        help="Name of the task to be created in Windows Task Scheduler",
    )

    parser.add_argument(
        "--root",
        dest="rootGroup",
        type=str,
        required=False,
        default="python",
        help=r"Name of the root directory that task will be saved to in Windows Task Scheduler. Example: python",
    )

    parser.add_argument(
        "--group",
        dest="taskGroup",
        type=str,
        required=False,
        default="tasks",
        help=r"Name of the group that the task will be saved to in Windows Task Scheduler. Example: python\tasks",
    )

    parser.add_argument(
        "--filename",
        dest="pythonFilename",
        type=str,
        required=True,
        help=r"""Name of the python file, without the .py extension, that will executed. NOTE: File must be located within the root package directory""",
    )

    args = parser.parse_args()
    create_task(
        task_name=args.taskName,
        task_folder=args.taskGroup,
        task_root_folder=args.rootGroup,
        file_name=args.pythonFilename,
    )


if __name__ == "__main__":
    pass
