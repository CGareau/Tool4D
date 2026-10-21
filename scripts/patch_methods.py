#!/usr/bin/env python3
"""Remove every hard-coded / embedded download credential from Build_Application's
download methods and route them through getDownloadCommand (see templates/Methods).

usage: patch_methods.py <Build_Application dir> <templates dir>
Fails (exit 1) if a method does not match the expected shape, so a changed upstream
method is never published half-patched.
"""
import re
import shutil
import sys
from pathlib import Path

root, templates = Path(sys.argv[1]), Path(sys.argv[2])
methods = root / "Project" / "Sources" / "Methods"
TARGETS = ["download4DApplication", "download4DComponents", "downloadPackageManager"]

# the 3 lines that decrypt Resources/key with a pass phrase stored in the code
KEY_LINES = [
    re.compile(r'^\s*BASE64 DECODE:C896\(".*"; \$key\)\s*$'),
    re.compile(r'^\s*\$bool:=Decrypt data BLOB:C1774\(File:C1566\("/RESOURCES/key"\)\.getContent\(\); \$key; MAXLONG:K35:2; \$blob\)\s*$'),
    re.compile(r'^\s*\$api:=BLOB to text:C555\(\$blob; UTF8 C string:K22:15\)\s*$'),
]
# the curl command: archive name variable captured, whatever follows (token) is dropped
CMD = re.compile(
    r'^(?P<indent>\s*)\$cmd:="curl -L -o \\""\+\$file\.path\+"\\" '
    r'https://product-download\.4d\.com/release/"\+\$version\+"/"\+\$branch\+"/"\+String:C10\(\$build\)\+"/"\+\$os\+"/"\+(?P<zip>\$\w+)\+.*$'
)

for name in TARGETS:
    path = methods / f"{name}.4dm"
    out, key_removed, cmd_replaced = [], 0, 0
    for line in path.read_text(encoding="utf-8").split("\n"):
        if any(p.match(line) for p in KEY_LINES):
            key_removed += 1
            continue
        m = CMD.match(line)
        if m:
            out.append(f'{m["indent"]}$cmd:=getDownloadCommand($file.path; $version; $branch; $build; $os; '
                       f'{m["zip"]}; $Txt_major; $Txt_release)')
            cmd_replaced += 1
            continue
        out.append(line)
    expected_cmds = 2 if name == "download4DApplication" else 1
    if key_removed != 3 or cmd_replaced != expected_cmds:
        sys.exit(f"{name}: unexpected shape (key lines {key_removed}/3, curl lines {cmd_replaced}/{expected_cmds})")
    path.write_text("\n".join(out), encoding="utf-8")

# --- single-user (standalone) build: new method + startup branch + Volume Desktop download ---
app = methods / "download4DApplication.4dm"
text = app.read_text(encoding="utf-8")
if text.count("If ($config.buildClient)") != 1:
    sys.exit("download4DApplication: expected exactly one 'If ($config.buildClient)'")
app.write_text(text.replace("If ($config.buildClient)", "If ($config.buildClient || $config.buildStandalone)"), encoding="utf-8")

startup = methods / "startup.4dm"
text = startup.read_text(encoding="utf-8")
block = re.search(r"\t\t\tIf \(\$config\.buildServer\)\n.*?\n\t\t\tEnd if\s*\n(?=\tEnd case)", text, re.S)
if not block:
    sys.exit("startup: build server block not found")
standalone = (block.group(0)
              .replace("$config.buildServer", "$config.buildStandalone")
              .replace("buildServer($config)", "buildStandalone($config)")
              .replace("BUILD SERVER", "BUILD STANDALONE"))
if "buildStandalone($config)" not in standalone:
    sys.exit("startup: could not derive the standalone block")
startup.write_text(text[:block.end()] + "\t\t\t\n" + standalone + text[block.end():], encoding="utf-8")

for helper in ("getEnvVariable", "isPublicAsset", "getDownloadCommand", "buildStandalone"):
    shutil.copy(templates / "Methods" / f"{helper}.4dm", methods / f"{helper}.4dm")

key = root / "Resources" / "key"
if key.exists():
    key.unlink()
print("patched:", ", ".join(TARGETS), "+ startup, buildStandalone")
