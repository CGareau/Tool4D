#!/usr/bin/env python3
"""4DBuilder: accept a Windows path (D:\\a\\project\\Build) for the "output" parameter.

getMake builds the output folder with Folder($config.output), which expects a POSIX path, so a Windows
runner that passes its native path ends with "A valid posix path was expected". The path type is now
chosen from the path itself.

usage: patch_builder.py <4DBuilder dir>
"""
import re
import sys
from pathlib import Path

path = Path(sys.argv[1]) / "Project" / "Sources" / "Methods" / "getMake.4dm"
text = path.read_text(encoding="utf-8")

OLD = "$make.outputFolder:=Folder:C1567($config.output)"
NEW = ('$make.outputFolder:=Folder:C1567($config.output; (Is Windows:C1573 & (Position:C15("\\\\"; String:C10($config.output))>0)) '
       '? fk platform path:K87:2 : fk posix path:K87:1)')

if OLD in text:
    path.write_text(text.replace(OLD, NEW), encoding="utf-8")
    print("patched: getMake output path")
elif re.search(r"outputFolder:=Folder:C1567\(\$config\.output;", text):
    print("getMake already handles the path type, nothing to do")
else:
    sys.exit("getMake: output folder line not found")
