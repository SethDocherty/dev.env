# -*- coding: utf-8 -*-
import argparse
import subprocess
import textwrap
from pathlib import Path
from typing import List


def _str_to_list(string: str) -> List[str]:
    return [x.strip() for x in string.split(",")]


def build_directory_path(input_path: str) -> str:
    """Construct an absolute path from a string and create a directory at the given path if it does not exist.

    This method also takes care of checking if the string representation of `input_path` is an absolute
    or relative path. Relative paths are resolved based on the current working directory. See examples below.

    Absolute: `c:/path/to/directory` -> `C:/path/to/directory`

    Relative: `../../directory` -> `C:/directory` when CWD = `C:/path/to/directory`

    Relative: `directory/example` -> `C:/path/to/directory/example` when CWD = `C:/path/to/directory`

    Args:
        input_path (str): String that represents a relative or absolute path

    Returns:
        str: Return the string representation of path
    """

    # Create a Path object from the user input
    directory_path = Path(input_path)

    # Check if path is absolute
    if not directory_path.is_absolute():
        # If the path is relative, make it relative to the current directory
        current_dir = Path.cwd()
        directory_path = (Path(current_dir) / directory_path).resolve()

    # Ensure path exists and return as a string
    directory_path.mkdir(exist_ok=True, parents=True)
    return directory_path.as_posix()


def download_from_github(
    repoUrl: str, selection: list[str], savePath: str, branchName: str = "main"
) -> None:
    """Download one or more subdirectories/files from a remote git repository into a specified working directory.

    The git command, `sparse-checkout`, is used to selectively populates a local repository with only specific
    files or directories from the remote repository.

    Args:
        savePath (str): Working directory path that's the root of where content will be downloaded to. The working directory can be an absolute path or relative path to CWD.
        repoUrl (str): Full url to the remote git repository (e.g. https://github.com/username/reponame.git)
        selection (list[str]): A list of one or more paths of the repo. Each item in this list can be a directory (e.g. MY/DIR1) or a file (e.g. /My/File.txt)
        branchName (str, optional): Optional value which references a specific branch for the given repo. Defaults to "main".
    """

    # Defaults
    REMOTE_NAME = "temp"

    # Check and build directory path
    savePath = build_directory_path(savePath)

    # Initialize Git repository in the target directory
    subprocess.run(["git", "init", savePath], check=True)

    # Add remote repository with the
    subprocess.run(
        ["git", "-C", savePath, "remote", "add", REMOTE_NAME, repoUrl], check=True
    )

    # Configure sparse checkout
    subprocess.run(
        ["git", "-C", savePath, "config", "core.sparseCheckout", "true"], check=True
    )

    # Set the fist item from the list
    subprocess.run(
        ["git", "-C", savePath, "sparse-checkout", "set", selection[0]], check=True
    )

    # If selection length is greater than 1, add other paths to sparse checkout.
    if len(selection) > 1:
        selection_adds = selection[1:]
        for path in selection_adds:
            result = subprocess.run(
                ["git", "-C", savePath, "sparse-checkout", "add", path],
                check=False,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
            )

            # If the subprocess failed, print the error stream
            if result.returncode != 0:
                print(f"Error adding {path}:")
                print("Stdout:", result.stdout.decode())
                print("Stderr:", result.stderr.decode())

    # Perform initial pull to populate selected files/directories
    subprocess.run(["git", "-C", savePath, "pull", REMOTE_NAME, branchName], check=True)

    # Remove the remote branch. This is to ensure that if this directory is referenced again, REMOTE_NAME is not
    # linked to a remote repo.
    subprocess.run(["git", "-C", savePath, "remote", "remove", REMOTE_NAME], check=True)


def download() -> None:
    """Function to initialize creating a task"""
    # Capture input arguments
    parser = argparse.ArgumentParser(
        prog="download_from_github",
        add_help=True,
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description=textwrap.dedent(
            """\
            Description: Download one or more subdirectories/files from a remote git repository into a specified local working directory.

            The git command, `sparse-checkout`, is used to selectively populates a local repository with only specific files or directories from the remote repository.

            NOTE: The working directory path passed into `--path` can be absolute or relative. Relative paths are interpreted and resolved to the current working directory. See examples below:

                Absolute: `c:/path/to/directory` -> `C:/path/to/directory`
                Relative: `../../directory` -> `C:/directory` when CWD = `C:/path/to/directory`
                Relative: `directory/example` -> `C:/path/to/directory/example` when CWD = `C:/path/to/directory`
            """
        ),
    )

    parser.add_argument(
        "--url",
        type=str,
        required=True,
        help=r"Full url to the remote git repository (e.g. https://github.com/username/reponame.git)",
    )

    parser.add_argument(
        "--work-trees",
        type=_str_to_list,
        default="python",
        required=True,
        help=r"A comma separated list of one or more paths of the repo. Each item in this list can be a directory (e.g. MY/DIR1) or a file (e.g. /My/File.txt)",
    )

    parser.add_argument(
        "--path",
        type=str,
        default="tasks",
        required=True,
        help=r"Local working directory path where content will be downloaded to. The working directory can be an absolute path or relative path to CWD.",
    )

    parser.add_argument(
        "--branch",
        type=str,
        default="main",
        required=False,
        help=r"Optional value which references a specific branch for the given repo. (Default: main)",
    )

    args = parser.parse_args()
    download_from_github(
        repoUrl=args.url,
        selection=args.work_trees,
        savePath=args.path,
        branchName=args.branch,
    )


if __name__ == "__main__":
    download()
