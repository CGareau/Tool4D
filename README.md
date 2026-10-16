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

A 4D license is needed to **run** the built applications, not to build them. Signing with a Developer ID certificate and notarization are covered in [Sign and notarize on macOS](#sign-and-notarize-on-macos-optional); Windows code signing is up to you.

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

## Sign and notarize on macOS (optional)

`Build_Application` can **sign** the applications it builds; **notarization** (required for apps distributed outside the Mac App Store, so that Gatekeeper accepts them) is a separate step you run afterwards. Both need an Apple Developer account and a *Developer ID Application* certificate. Without them, keep the default ad hoc signature (`"adHocSignature": true`): the app runs on the machine that built it, but not on other Macs without a warning.

**What you have to do, in short**

1. Get an Apple Developer account and create a *Developer ID Application* certificate; note your **Team ID**.
2. Create an **app-specific password** for your Apple ID (account.apple.com → Sign-In and Security).
3. Put the certificate in the keychain of the Mac that builds (your Mac or a self-hosted runner), or import it from a secret on a hosted runner.
4. Set `macSignature` to `true` and your certificate name in the macOS build JSON files.
5. After the build, notarize with `notarytool` and staple the result.

### Sign during the build

In `buildStandaloneMac.json`, `buildClientMac.json` and `buildServerMac.json`:

```json
"signApplication": {
  "macSignature": true,
  "macCertificate": "Developer ID Application: Your Name (TEAMID)"
}
```

The certificate must be installed in a keychain that is available to the build. On your own Mac it already is. On a CI runner, import it into a temporary keychain first.

### On your own Mac or a self-hosted runner

Install the certificate once (double-click the `.p12` in Keychain Access, or `security import certificate.p12 -k ~/Library/Keychains/login.keychain-db -T /usr/bin/codesign`), then store the notarization credentials once in the keychain so that no password appears in scripts:

```bash
xcrun notarytool store-credentials "notary" --apple-id "you@example.com" --team-id "TEAMID" --password "app-specific-password"
```

and notarize with `--keychain-profile "notary"` instead of the three `--apple-id/--team-id/--password` options below. On a shared runner use a dedicated keychain and user rather than a personal one.

### In GitHub Actions

Create these repository **secrets** (Settings → Secrets and variables → Actions → *Secrets*; never *Variables*, which are readable in clear):

| Secret | Value |
|---|---|
| `APPLE_CERTIFICATE_P12` | your Developer ID Application certificate exported from Keychain Access as `.p12`, encoded with `base64 -i certificate.p12` |
| `APPLE_CERTIFICATE_PASSWORD` | password chosen when exporting the `.p12` |
| `KEYCHAIN_PASSWORD` | any random password, used for the temporary keychain |
| `NOTARY_APPLE_ID` | your Apple ID |
| `NOTARY_TEAM_ID` | your Apple Developer Team ID |
| `NOTARY_PASSWORD` | an [app-specific password](https://support.apple.com/102654) for that Apple ID |

Add this step **before** the build, and the cleanup step at the end of the job:

```yaml
- name: Import the signing certificate
  env:
    APPLE_CERTIFICATE_P12: ${{ secrets.APPLE_CERTIFICATE_P12 }}
    APPLE_CERTIFICATE_PASSWORD: ${{ secrets.APPLE_CERTIFICATE_PASSWORD }}
    KEYCHAIN_PASSWORD: ${{ secrets.KEYCHAIN_PASSWORD }}
  run: |
    KEYCHAIN="$RUNNER_TEMP/build.keychain-db"
    echo -n "$APPLE_CERTIFICATE_P12" | base64 --decode > "$RUNNER_TEMP/cert.p12"
    security create-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN"
    security set-keychain-settings -lut 21600 "$KEYCHAIN"
    security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN"
    security import "$RUNNER_TEMP/cert.p12" -P "$APPLE_CERTIFICATE_PASSWORD" -A -t cert -f pkcs12 -k "$KEYCHAIN"
    security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$KEYCHAIN_PASSWORD" "$KEYCHAIN"
    security list-keychains -d user -s "$KEYCHAIN" $(security list-keychains -d user | tr -d '"')
    rm "$RUNNER_TEMP/cert.p12"

# ... build with macSignature = true ...

- name: Remove the temporary keychain
  if: always()
  run: security delete-keychain "$RUNNER_TEMP/build.keychain-db" || true
```

### Notarize

Notarize the built application (for a client/server pair, the server and the client app each), then staple the ticket:

```bash
ditto -c -k --keepParent "Build/Standalone/MyApp.app" MyApp.zip
xcrun notarytool submit MyApp.zip --apple-id "$NOTARY_APPLE_ID" --team-id "$NOTARY_TEAM_ID" --password "$NOTARY_PASSWORD" --wait
xcrun stapler staple "Build/Standalone/MyApp.app"
```

The submission must end with `status: Accepted`. If it is rejected, `xcrun notarytool log <submission-id> ...` explains why (usually a binary that is not signed with the hardened runtime and a secure timestamp). Re-archive the stapled `.app` afterwards (`tar` or `ditto`), and keep your Apple credentials in secrets only.

> These steps follow Apple's documented tooling; the sample workflow in this repository builds with the ad hoc signature and does not sign or notarize.

Windows code signing (for example with `signtool` and a code signing certificate) is not handled by `Build_Application` either.

## Continuous integration example

[`.github/workflows/build-example.yml`](.github/workflows/build-example.yml) builds [`example/`](example) on Windows and macOS: standalone, client and server. Run it from the *Actions* tab (*Build example application* → *Run workflow*, choose the 4D version) and copy it to your own repository.

### GitHub-hosted or self-hosted runners?

The example runs on GitHub-hosted runners (`windows-latest`, `macos-latest`) so that it works out of the box. **For regular builds, your own self-hosted runners are usually the better choice:**

| | GitHub-hosted | Self-hosted |
|---|---|---|
| Setup | nothing | a Windows and a Mac machine to install and maintain |
| Cost | macOS minutes cost several times the Linux price | your own hardware |
| macOS compiler | Xcode installed by GitHub; the Apple silicon compiler check is occasionally flaky (the example retries) | Xcode / Command Line Tools and Rosetta installed once, stable |
| Signing | the certificate must be imported from a secret in every run | the certificate stays in the runner's keychain (still use a dedicated keychain, never a personal login) |
| Speed | clean machine: 4D Server and Volume Desktop (hundreds of MB) are downloaded on each run | the same machine every time: keep a cache or a copy of the archives and use `TOOL4D_DOWNLOAD_BASE` |
| Isolation | a fresh VM every run | the workspace is reused: clean `Build/` and the downloaded `4D Server.app` / `4D Volume Desktop` folders at the start of each job |

To switch the example to your own runners, define two **repository variables** (Settings → Secrets and variables → Actions → *Variables*; they are not secrets) with the runner labels as JSON:

| Variable | Example |
|---|---|
| `RUNNER_WINDOWS` | `["self-hosted","windows"]` |
| `RUNNER_MACOS` | `["self-hosted","macOS","ARM64"]` |

Prerequisites on the machines: `git`, `curl` and `tar` (macOS also `jq`), Xcode or the Command Line Tools and Rosetta for macOS (`softwareupdate --install-rosetta --agree-to-license`), and, for Windows applications, a Windows machine. Nothing else is installed: `tool4d` comes from this repository.

> **Security:** never run workflows from untrusted pull requests (for example forks of a public repository) on a self-hosted runner: they would run arbitrary code on your machines. Use self-hosted runners only in private repositories, or restrict them to trusted workflows and branches.

### Notes from the example workflow

* on GitHub-hosted `macos-latest` (Apple silicon) Rosetta is installed first, because `tool4d` for macOS is an Intel build (the step is skipped on self-hosted runners);
* compiling for Apple silicon (`arm64_macOS_lib`) needs Xcode or the Command Line Tools; the compiler check is occasionally flaky on hosted runners, so the macOS build is retried up to 3 times;
* archive macOS builds with `tar` (bundles contain symbolic links) before uploading them as artifacts.
