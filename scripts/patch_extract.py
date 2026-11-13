#!/usr/bin/env python3
"""Update an already-patched Build_Application to extract tar.xz Releases.

Copies getDownloadCommand + extractRuntimeArchive from templates and replaces
ZIP Read archive blocks. Safe to re-run.

usage: patch_extract.py <Build_Application dir> <templates dir>
"""
import re
import shutil
import sys
from pathlib import Path

root, templates = Path(sys.argv[1]), Path(sys.argv[2])
methods = root / "Project" / "Sources" / "Methods"
TARGETS = ["download4DApplication", "download4DComponents", "downloadPackageManager"]

for helper in ("getDownloadCommand", "extractRuntimeArchive"):
    shutil.copy(templates / "Methods" / f"{helper}.4dm", methods / f"{helper}.4dm")

verbose = re.compile(
    r"\t\t\$archive:=ZIP Read archive:C1637\(\$file\)\n"
    r"\t\tIf \(\$archive#Null:C1517\)\n"
    r"\t\t\tIf \(\$archive\.root#Null:C1517\)\n"
    r"\t\t\t\t\$folder:=\$archive\.root\.copyTo\(\$file\.parent; fk overwrite:K87:5\)\n"
    r"\t\t\t\tIf \(Is macOS:C1572\)\n"
    r"\t\t\t\t\t\$file\.delete\(\)\n"
    r"\t\t\t\tEnd if\n"
    r"\t\t\tElse\n"
    r"\t\t\t\tLOG EVENT:C667\(Into system standard outputs:K38:9; \"\*\*\*ERROR\*\*\* Invalid [^\"]+\"; Error message:K38:3\)\n"
    r"\t\t\t\treturn\n"
    r"\t\t\tEnd if\n"
    r"\t\tElse\n"
    r"\t\t\tLOG EVENT:C667\(Into system standard outputs:K38:9; \"\*\*\*ERROR\*\*\* Invalid [^\"]+\"; Error message:K38:3\)\n"
    r"\t\t\treturn\n"
    r"\t\tEnd if\n",
    re.M,
)
verbose_repl = (
    "\t\tIf (Not:C34(extractRuntimeArchive($file)))\n"
    "\t\t\tLOG EVENT:C667(Into system standard outputs:K38:9; \"***ERROR*** Invalid runtime archive\\n\"; Error message:K38:3)\n"
    "\t\t\treturn\n"
    "\t\tEnd if\n"
)
short = re.compile(
    r"\t\t\$archive:=ZIP Read archive:C1637\(\$file\)\n"
    r"\t\t\$folder:=\$archive\.root\.copyTo\(\$file\.parent; fk overwrite:K87:5\)\n",
    re.M,
)
short_repl = (
    "\t\tIf (Not:C34(extractRuntimeArchive($file)))\n"
    "\t\t\tLOG EVENT:C667(Into system standard outputs:K38:9; \"***ERROR*** Invalid runtime archive\\n\"; Error message:K38:3)\n"
    "\t\t\treturn\n"
    "\t\tEnd if\n"
)

total = 0
for name in TARGETS:
    path = methods / f"{name}.4dm"
    text = path.read_text(encoding="utf-8")
    if "extractRuntimeArchive($file)" in text and "ZIP Read archive" not in text:
        print(f"{name}: already using extractRuntimeArchive")
        continue
    text2, n1 = verbose.subn(verbose_repl, text)
    text3, n2 = short.subn(short_repl, text2)
    if n1 + n2 == 0:
        sys.exit(f"{name}: no ZIP Read archive block to replace")
    path.write_text(text3, encoding="utf-8")
    total += n1 + n2
    print(f"{name}: replaced {n1 + n2} ZIP extract block(s)")

print(f"ok: {total} block(s), helpers copied")
