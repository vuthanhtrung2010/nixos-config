# Thorium Browser Packaging & Automated CI/CD Update Pipeline

## 1. Overview
This design specifies the integration of the **Thorium Browser** into the `nixos-config` repository, supporting multiple CPU architectures and instruction-set optimizations (AVX-512, AVX2, AVX, SSE4, SSE3, ARM64) based on upstream releases from [`gz83/thorium`](https://github.com/gz83/thorium).

The architecture and automation pipeline are modeled after [`numtide/llm-agents.nix`](https://github.com/numtide/llm-agents.nix), providing:
1. Declarative Nix expressions with pinned metadata in `hashes.json`.
2. A Python update script to discover releases, download or stream hashes, and update metadata.
3. A GitHub Actions workflow running on a schedule to detect new releases, build/verify the derivation, create pull requests, and automatically merge them.

---

## 2. Directory & File Structure

```
nixos-config/
├── .github/
│   └── workflows/
│       └── update-thorium.yml    # CI/CD schedule for detection, PR creation & auto-merge
├── packages/
│   └── thorium/
│       ├── hashes.json           # Pinned version, release URLs, and SHA-256 SRI hashes
│       ├── package.nix           # Derivation function wrapping AppImage per CPU variant
│       └── update.py             # Python updater modeled after llm-agents.nix
├── flake.nix                     # Flake outputs (packages & overlays)
└── configuration.nix             # Optional system package inclusion
```

---

## 3. Package Specification

### 3.1 Metadata Storage (`packages/thorium/hashes.json`)
The metadata file tracks the upstream release tag, version, and per-architecture/variant URLs and SHA-256 SRI hashes:

```json
{
  "version": "156.0.8078.80",
  "tag": "M156.0.8078.80",
  "variants": {
    "x86_64-linux": {
      "avx512": {
        "url": "https://github.com/gz83/thorium/releases/download/M156.0.8078.80/Thorium_Browser_156.0.8078.80_AVX512.AppImage",
        "hash": "<sha256-sri>"
      },
      "avx2": {
        "url": "https://github.com/gz83/thorium/releases/download/M156.0.8078.80/Thorium_Browser_156.0.8078.80_AVX2.AppImage",
        "hash": "<sha256-sri>"
      },
      "avx": {
        "url": "https://github.com/gz83/thorium/releases/download/M156.0.8078.80/Thorium_Browser_156.0.8078.80_AVX.AppImage",
        "hash": "<sha256-sri>"
      },
      "sse4": {
        "url": "https://github.com/gz83/thorium/releases/download/M156.0.8078.80/Thorium_Browser_156.0.8078.80_SSE4.AppImage",
        "hash": "<sha256-sri>"
      },
      "sse3": {
        "url": "https://github.com/gz83/thorium/releases/download/M156.0.8078.80/Thorium_Browser_156.0.8078.80_SSE3.AppImage",
        "hash": "<sha256-sri>"
      }
    },
    "aarch64-linux": {
      "arm64": {
        "url": "https://github.com/gz83/thorium/releases/download/M156.0.8078.80/Thorium_Browser_156.0.8078.80_arm64.AppImage",
        "hash": "<sha256-sri>"
      }
    }
  }
}
```

### 3.2 Package Derivation (`packages/thorium/package.nix`)
- **Base Builder**: `pkgs.appimageTools.wrapType2`.
- **Arguments**:
  - `variant`: Desired CPU variant (defaults to `"avx2"` on `x86_64-linux` and `"arm64"` on `aarch64-linux`).
- **Asset Extraction**:
  - Uses `pkgs.appimageTools.extract` to extract `thorium-browser.desktop` and application icons (`thorium.png`).
- **Installation Phase**:
  - Installs the `.desktop` file to `$out/share/applications/thorium-browser.desktop`.
  - Installs application icons to `$out/share/icons/hicolor/512x512/apps/thorium.png`.
  - Patches `Exec` line in the desktop file from `AppRun --no-sandbox %U` to `thorium %U`.
- **Metadata**:
  - `mainProgram = "thorium"`.
  - Proper categories (`Network`, `WebBrowser`), license (`licenses.bsd3`), and platform constraints (`[ "x86_64-linux" "aarch64-linux" ]`).

### 3.3 Flake Integration (`flake.nix`)
Exposes:
1. `packages.${system}.thorium`: Main package defaulting to `avx2` on `x86_64-linux` and `arm64` on `aarch64-linux`.
2. Explicit variant packages:
   - `packages.x86_64-linux.thorium-avx512`
   - `packages.x86_64-linux.thorium-avx2`
   - `packages.x86_64-linux.thorium-avx`
   - `packages.x86_64-linux.thorium-sse4`
   - `packages.x86_64-linux.thorium-sse3`
   - `packages.aarch64-linux.thorium-arm64`
3. `overlays.default`: Overlay extending `pkgs` with `thorium` and its variant attributes.

---

## 4. Auto-Updater (`packages/thorium/update.py`)

A standalone Python 3 script without heavy third-party dependencies:
- **Upstream Source**: GitHub API (`https://api.github.com/repos/gz83/thorium/releases`).
- **Release Filtering**:
  - Selects the latest release tag (matching pattern `M<major>.<minor>...`).
  - Ignores draft releases.
- **Asset Matching**:
  - Parses assets for `Thorium_Browser_<version>_<variant>.AppImage`.
  - Map of variants:
    - `AVX512` -> `avx512` (`x86_64-linux`)
    - `AVX2` -> `avx2` (`x86_64-linux`)
    - `AVX` -> `avx` (`x86_64-linux`)
    - `SSE4` -> `sse4` (`x86_64-linux`)
    - `SSE3` -> `sse3` (`x86_64-linux`)
    - `arm64` -> `arm64` (`aarch64-linux`)
- **Hash Computation**:
  - If the release tag differs from `hashes.json`, streams each asset over HTTP and computes its SHA-256 hash formatted as a standard base64 SRI string (`sha256-...`).
- **File Update**:
  - Formats and writes the updated dictionary to `packages/thorium/hashes.json` with sorted keys and 2-space indentation.
  - Outputs summary status to stdout and sets exit code `0`.

---

## 5. GitHub Actions Workflow (`.github/workflows/update-thorium.yml`)

### 5.1 Trigger Configuration
- **Cron Schedule**: Runs twice daily (`0 2,14 * * *`).
- **Manual Dispatch**: `workflow_dispatch` enabled with optional target version parameter.

### 5.2 Workflow Jobs & Steps
1. **`check-and-update` Job**:
   - Runs on `ubuntu-latest`.
   - Permissions:
     ```yaml
     permissions:
       contents: write
       pull-requests: write
     ```
   - Checks out the repository with full fetch history (`fetch-depth: 0`).
   - Sets up Python 3.
   - Installs Nix using `NixOS/nix-installer-action`.
   - Executes `python3 packages/thorium/update.py`.
   - Checks `git diff --quiet packages/thorium/hashes.json`:
     - If no diff, exits gracefully with `"Thorium is up to date"`.
   - If changed:
     - Verifies derivation builds with `nix build .#thorium --dry-run`.
     - Creates branch `update/thorium-<version>`.
     - Commits changes using `github-actions[bot]`:
       ```
       feat(thorium): update to <version>
       ```
     - Pushes branch to origin.
     - Opens a Pull Request via `gh pr create`:
       - Title: `feat(thorium): update to <version>`
       - Body: Reference to release notes at `https://github.com/gz83/thorium/releases/tag/<tag>`.
     - Enables auto-merge via `gh pr merge --auto --merge`.

---

## 6. Verification Plan

1. **Local Package Evaluation & Build**:
   - Run `nix eval .#packages.x86_64-linux.thorium` to verify attribute resolution.
   - Run `nix eval .#packages.x86_64-linux.thorium-avx512` to verify variant handling.
   - Build derivation dry-run: `nix build .#thorium --dry-run`.
2. **Updater Verification**:
   - Execute `python3 packages/thorium/update.py` locally and verify `hashes.json` matches upstream `M156.0.8078.80`.
3. **Workflow Syntax & Schema**:
   - Validate `.github/workflows/update-thorium.yml` YAML syntax and GitHub Actions schema.
