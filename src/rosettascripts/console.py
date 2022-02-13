#!/usr/bin/env python3

import subprocess
import pathlib
import argparse
import platform

from rosettascripts import metadata
from rosettascripts import MODULE_DIR


def extract_pdb():
    if platform.system() != "Windows":
        subprocess.call(str(MODULE_DIR.joinpath("scripts", "extract_pdb.sh")))
    else:
        print("extract_pdb is only available for Unix operating systems")


def submitJobs():
    if platform.system() != "Windows":
        subprocess.call(str(MODULE_DIR.joinpath("scripts", "submitJobs.sh")))
    else:
        print("submitJobs is only available for Unix operating systems")


def process_silentfile():
    if platform.system() != "Windows":
        subprocess.call(str(MODULE_DIR.joinpath("scripts", "process_silentfile.sh")))
    else:
        print("process_silentfile is only available for Unix operating systems")


def rosettascripts():
    parser = argparse.ArgumentParser(
        description="Scripts for RNA homology and de novo modeling using the Rosetta suite"
    )
    parser.add_argument("--version", action="version", version="%(prog)s " + str(metadata["Version"]))
    parser.add_argument(
        "--path",
        action="version",
        version=f"package directory: {MODULE_DIR}",
        help="Show package directory",
    )
    parser.parse_args()
