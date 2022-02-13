#!/usr/bin/env python3

import subprocess
import pathlib
import argparse

from rosettascripts import metadata
from rosettascripts import MODULE_DIR


def extract_pdb():
    subprocess.run(str(MODULE_DIR.joinpath("scripts", "extract_pdb.sh")))


def submitJobs():
    subprocess.run(str(MODULE_DIR.joinpath("scripts", "submitJobs.sh")))


def process_silentfile():
    subprocess.run(str(MODULE_DIR.joinpath("scripts", "process_silentfile.sh")))


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
