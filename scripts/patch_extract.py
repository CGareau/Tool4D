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

# 4D source often has a trailing space before newline ("End if ").
SP = r"[ \t]*"

REPL = (
    "{indent}If (Not:C34(extractRuntimeArchive($file)))\n"
    "{indent}\tLOG EVENT:C667(Into system standard outputs:K38:9; \"***ERROR*** Invalid runtime archive\\n\"; Error message:K38:3)\n"
    "{indent}\treturn\n"
    "{indent}End if\n"
)

PATTERNS = [
    # download4DApplication Server (nested, verbose)
    re.compile(
        rf"(?P<indent>\t\t)\$archive:=ZIP Read archive:C1637\(\$file\){SP}\n"
        rf"\t\tIf \(\$archive#Null:C1517\){SP}\n"
        rf"\t\t\tIf \(\$archive\.root#Null:C1517\){SP}\n"
        rf"\t\t\t\t\$folder:=\$archive\.root\.copyTo\(\$file\.parent; fk overwrite:K87:5\){SP}\n"
        rf"\t\t\t\tIf \(Is macOS:C1572\){SP}\n"
        rf"\t\t\t\t\t\$file\.delete\(\){SP}\n"
        rf"\t\t\t\tEnd if{SP}\n"
        rf"\t\t\tElse{SP}\n"
        rf"\t\t\t\tLOG EVENT:C667\(Into system standard outputs:K38:9; \"\*\*\*ERROR\*\*\* Invalid [^\"]+\"; Error message:K38:3\){SP}\n"
        rf"\t\t\t\treturn{SP}\n"
        rf"\t\t\tEnd if{SP}\n"
        rf"\t\tElse{SP}\n"
        rf"\t\t\tLOG EVENT:C667\(Into system standard outputs:K38:9; \"\*\*\*ERROR\*\*\* Invalid [^\"]+\"; Error message:K38:3\){SP}\n"
        rf"\t\t\treturn{SP}\n"
        rf"\t\tEnd if{SP}\n",
        re.M,
    ),
    # download4DApplication Volume Desktop (short, nested)
    re.compile(
        rf"(?P<indent>\t\t)\$archive:=ZIP Read archive:C1637\(\$file\){SP}\n"
        rf"\t\t\$folder:=\$archive\.root\.copyTo\(\$file\.parent; fk overwrite:K87:5\){SP}\n",
        re.M,
    ),
    # downloadPackageManager (Try/Catch)
    re.compile(
        rf"(?P<indent>\t)Try{SP}\n"
        rf"\t\t\$archive:=ZIP Read archive:C1637\(\$file\){SP}\n"
        rf"\tCatch{SP}\n"
        rf"\t\tLOG EVENT:C667\(Into system standard outputs:K38:9; \"\*\*\*ERROR\*\*\* \[[^\"]+\"; Error message:K38:3\){SP}\n"
        rf"\tEnd try{SP}\n"
        rf"\t\$folder:=\$archive\.root\.copyTo\(\$file\.parent; fk overwrite:K87:5\){SP}\n"
        rf"\tIf \(Is macOS:C1572\){SP}\n"
        rf"\t\t\$file\.delete\(\){SP}\n"
        rf"\tEnd if{SP}\n",
        re.M,
    ),
    # download4DComponents (flat)
    re.compile(
        rf"(?P<indent>\t)\$archive:=ZIP Read archive:C1637\(\$file\){SP}\n"
        rf"\t\$folder:=\$archive\.root\.copyTo\(\$file\.parent; fk overwrite:K87:5\){SP}\n"
        rf"\tIf \(Is macOS:C1572\){SP}\n"
        rf"\t\t\$file\.delete\(\){SP}\n"
        rf"\tEnd if{SP}\n",
        re.M,
    ),
]


def repl_fn(m: re.Match) -> str:
    return REPL.format(indent=m.group("indent"))


total = 0
for name in TARGETS:
    path = methods / f"{name}.4dm"
    text = path.read_text(encoding="utf-8")
    if "ZIP Read archive" not in text:
        if "extractRuntimeArchive($file)" in text:
            print(f"{name}: already using extractRuntimeArchive")
            continue
        sys.exit(f"{name}: no ZIP Read archive and no extractRuntimeArchive")
    n = 0
    for pat in PATTERNS:
        text, k = pat.subn(repl_fn, text)
        n += k
    if n == 0:
        sys.exit(f"{name}: ZIP Read present but no pattern matched")
    if "ZIP Read archive" in text:
        sys.exit(f"{name}: ZIP Read archive still present after patch")
    path.write_text(text, encoding="utf-8")
    total += n
    print(f"{name}: replaced {n} ZIP extract block(s)")

print(f"ok: {total} block(s), helpers copied")
