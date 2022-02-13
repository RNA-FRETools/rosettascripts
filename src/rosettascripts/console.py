#!/usr/bin/env python3

import subprocess
import pathlib
import argparse
import platform

from rosettascripts import metadata
from rosettascripts import MODULE_DIR


def extract_pdb():
    if platform.system() != "Windows":
        parser = argparse.ArgumentParser(description="Extract PDB(s) with the lowest energy score from silentfile(s)")
        parser.add_argument("-s", "--silentfile", default="", help="Rosetta output file")
        parser.add_argument("-d", "--directory", default="", help="directory with silentfiles")
        parser.add_argument("-n", "--number", default="1", help="number of models")
        parser.add_argument("-e", "--extract", default="true", help="extract PDBs")
        parser.add_argument("-m", "--merge", default="false", help="merge PDBs")
        args = parser.parse_args()
        subprocess.run(
            [
                str(MODULE_DIR.joinpath("scripts", "extract_pdb.sh")),
                "-s",
                args.silentfile,
                "-d",
                args.directory,
                "-n",
                args.number,
                "-e",
                args.extract,
                "-m",
                args.merge,
            ]
        )
    else:
        print("extract_pdb is only available for Unix operating systems")


def submitJobs():
    if platform.system() != "Windows":
        parser = argparse.ArgumentParser(description="Submit a Rosetta FARFAR job on multiple cores")
        parser.add_argument("-i", "--input", default="", help="FARFAR input script")
        parser.add_argument("-d", "--directory", default="", help="directory for silentfiles")
        parser.add_argument("-p", "--processes", default="1", help="number of processes (cores) to run in parallel")
        args = parser.parse_args()
        subprocess.run(
            [
                str(MODULE_DIR.joinpath("scripts", "submitJobs.sh")),
                "-i",
                args.input,
                "-d",
                args.directory,
                "-p",
                args.processes,
            ]
        )
    else:
        print("submitJobs is only available for Unix operating systems")


def process_silentfile():
    if platform.system() != "Windows":
        parser = argparse.ArgumentParser(description="Submit a Rosetta FARFAR job on multiple cores")
        parser.add_argument("-s", "--silentfile", default="", help="Rosetta output file")
        args = parser.parse_args()
        subprocess.run([str(MODULE_DIR.joinpath("scripts", "process_silentfile.sh")), "-s", args.silentfile])
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
