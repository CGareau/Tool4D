#!/usr/bin/env python3
"""4DBuilder fixes applied to the copies published here:

1. accept a Windows path (D:\\a\\project\\Build) for the "output" parameter.

getMake builds the output folder with Folder($config.output), which expects a POSIX path, so a Windows
runner that passes its native path ends with "A valid posix path was expected". The path type is now
chosen from the path itself.

2. compileProject: a component was added only if its .4DZ had exactly the name of its .4dbase folder.
   When it has another name, the first .4DZ of the component is used.

usage: patch_builder.py <4DBuilder dir>
"""
import re
import sys
from pathlib import Path

root = Path(sys.argv[1]) / "Project" / "Sources" / "Methods"

# --- 1. getMake: output path type ---
path = root / "getMake.4dm"
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

# --- 2. compileProject: component .4DZ with another name than its .4dbase ---
path = root / "compileProject.4dm"
text = path.read_text(encoding="utf-8")

if ".files().query(\"extension = :1\"" in text:
    print("compileProject already looks for any .4DZ, nothing to do")
else:
    LINE = re.compile(r'^(?P<i>\t*)\$componentFile:=\$componentFolder\.file\(\$componentName\+"\.4DZ"\)[ \t]*\n', re.M)

    def add_fallback(m):
        i = m.group("i")
        return (m.group(0)
                + f'{i}If (Not($componentFile.exists))  // the .4DZ may be named differently from its .4dbase\n'
                + f'{i}\t$componentFiles:=$componentFolder.files().query("extension = :1"; ".4DZ")\n'
                + f'{i}\tIf ($componentFiles.length>0)\n'
                + f'{i}\t\t$componentFile:=$componentFiles.first()\n'
                + f'{i}\tEnd if \n'
                + f'{i}End if \n')

    text, n = LINE.subn(add_fallback, text)
    if n != 2:
        sys.exit(f"compileProject: expected 2 component lookups, found {n}")
    DECL = "var $componentName : Text\n"
    if text.count(DECL) != 1:
        sys.exit("compileProject: declaration anchor not found")
    text = text.replace(DECL, DECL + "var $componentFiles : Collection\n")
    path.write_text(text, encoding="utf-8")
    print("patched: compileProject component .4DZ lookup")
