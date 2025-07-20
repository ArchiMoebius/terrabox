#!/usr/bin/env python3
#
# TODO: run me if a task is added to this directory

from pathlib import PosixPath

CWD = PosixPath(__file__).parent

yaml_files = CWD.glob("*.yml")

files = []
for f in yaml_files:
    files.append(f)

with open("main.yml", "w") as fh:
    fh.write(
        """- name: Setup garble
  ansible.builtin.include_tasks: garble.yml\n
"""
    )

    for f in sorted(files):

        if f.stem in ["garble", "main", "notes"]:
            continue

        fh.write(
            f"""- name: Setup { f.stem.lower() }
  ansible.builtin.include_tasks: { f.name }
"""
        )
