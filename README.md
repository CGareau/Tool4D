# Tool4D

Everything needed to build **4D applications in CI/CD** — single-user (standalone), client and server, on **Windows** and **macOS** — with no 4D installation:

* `tool4d`, the command-line 4D (Windows, macOS, Linux)
* `Build_Application`, a 4D project that builds your application with `tool4d`
* `4DBuilder`, the engine behind it

**One branch per 4D version**: `21` is the latest LTS, `21R2`, `21R3`, `21R4`… are the public R releases of the same cycle. A new branch appears automatically when a new LTS or R is published. Branches are refreshed daily and each one holds a single commit:

| Folder | Content |
|---|---|
| `tool4d_win`, `tool4d_mac`, `tool4d_linux` | `tool4d` of that version (`tool4d_mac` is an Intel build: Apple silicon runs it through Rosetta) |
| `Build_Application`, `4DBuilder` | build tooling |
| `VERSION` | branch and 4D build number |

The matching **4D Server**, **4D Volume Desktop** and **4D** archives (Windows and macOS) are published as [Releases](../../releases) named `<branch>-<build>`; `Build_Application` downloads them for you.

## Build your application

Windows applications are built on Windows, macOS applications on macOS. Linux can only run `tool4d`.

### 1. Lay out your project

```
MyRepo/
├── Project/MyApp.4DProject        your 4D project
├── Resources/myIcon.icns          application icons (macOS / Windows)
├── Resources/myIcon.ico
├── buildStandaloneMac.json        one settings file per target and platform
├── buildStandaloneWin.json
├── buildClientMac.json
├── buildClientWin.json
├── buildServerMac.json
└── buildServerWin.json
```

[`example/`](example) is a complete minimal project to start from. Typical settings:

```jsonc
{
  "buildName": "MyApp",                      // client: "publishName" = name of the server it connects to
  "compilerOptions": { "targets": ["arm64_macOS_lib", "x86_64_generic"] },   // Windows: ["x86_64_generic"]
  "versioning": { "copyright": "Copyright My company", "companyName": "My company" },
  "signApplication": { "macSignature": false, "adHocSignature": true },        // macOS only
  "license": "/path/to/license.4DLicense"    // standalone only, optional ("auto" is accepted)
}
```

A 4D license is needed to **run** the built applications, not to build them. Signing with a Developer ID certificate and notarization (macOS), and code signing on Windows, are up to you.

### 2. Get the tools

```bash
git clone --depth 1 --branch 21R4 https://github.com/CGareau/Tool4D.git tools
```

In a workflow: `actions/checkout` with `repository: CGareau/Tool4D`, `ref: 21R4`, `path: tools` (add `sparse-checkout` to fetch only `tool4d_win` or `tool4d_mac`, `Build_Application` and `4DBuilder`).

### 3. Tell `Build_Application` where to download 4D Server / Volume Desktop

| Environment variable | Value |
|---|---|
| `TOOL4D_DOWNLOAD_REPO` | `CGareau/Tool4D` — archives come from the Releases of this repository |
| `TOOL4D_GITHUB_TOKEN` | optional GitHub token, avoids anonymous API rate limits (`${{ github.token }}` in Actions) |
| `TOOL4D_DOWNLOAD_BASE` | alternative: your own server, layout `<base>/<branch>-<build>/<os>_<archive>` (e.g. `21R4-100203/win_4D_Server.zip`) |

### 4. Run it

The build version is the one of the `tool4d` you run: use the `tool4d` of the 4D version you target.

**macOS**

```bash
./tools/tool4d_mac/tool4d.app/Contents/MacOS/tool4d --dataless \
  -s tools/Build_Application/Project/Build_Application.4DProject \
  --user-param '{"projectPath":"/abs/path/MyRepo/Project/MyApp.4DProject","output":"/abs/path/Build","buildNumber":"1.0.0","verbose":true,"buildStandalone":true,"buildClient":true,"buildServer":true}'
```

**Windows** (JSON paths use `\\`)

```bat
tools\tool4d_win\tool4d.exe --dataless -s tools\Build_Application\Project\Build_Application.4DProject --user-param "{\"projectPath\":\"C:\\MyRepo\\Project\\MyApp.4DProject\",\"output\":\"C:\\Build\",\"buildNumber\":\"1.0.0\",\"verbose\":true,\"buildStandalone\":true,\"buildClient\":true,\"buildServer\":true}"
```

| Parameter | |
|---|---|
| `projectPath`, `output` | absolute paths of the project file and of the build folder |
| `buildNumber` | version written in the applications (`1.0.0`) |
| `buildStandalone` | single-user application |
| `buildClient`, `buildServer` | client and server applications (the server embeds the client for automatic updates) |
| `forceClientUpdate` | force clients to update (version in `x.y.z` form) |
| `verbose` | print the build log |

### 5. Result

| Build | macOS | Windows |
|---|---|---|
| Standalone | `Build/Standalone/MyApp.app` | `Build/Standalone/MyApp/` |
| Client | `Build/Client/MyAppClient.app` + `update.mac.4darchive` | `Build/Client/MyAppClient/` + `update.win.4darchive` |
| Server | `Build/Server/MyAppServer.app` | `Build/Server/MyAppServer/` |

`tool4d` quits when it is done: check that the folders exist and that the log has no `***ERROR***` line to detect a failed build.

## Continuous integration example

[`.github/workflows/build-example.yml`](.github/workflows/build-example.yml) builds [`example/`](example) on `windows-latest` and `macos-latest`: standalone, client and server. Run it from the *Actions* tab (*Build example application* → *Run workflow*, choose the 4D version) and copy it to your own repository.

Notes from that workflow:

* on `macos-latest` (Apple silicon) install Rosetta first (`softwareupdate --install-rosetta --agree-to-license`);
* compiling for Apple silicon (`arm64_macOS_lib`) needs Xcode or the Command Line Tools; the compiler check is occasionally flaky on hosted runners, so the macOS build is retried up to 3 times;
* archive macOS builds with `tar` (bundles contain symbolic links) before uploading them as artifacts.
