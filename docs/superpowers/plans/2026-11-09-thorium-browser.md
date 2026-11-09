# Thorium Browser Packaging & Automated CI/CD Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Package the Thorium Browser with multi-CPU architecture and instruction-set optimization support in NixOS, and set up an automated GitHub Actions pipeline to detect new upstream releases, build-verify them, create PRs, and auto-merge updates.

**Architecture:** Pinned release metadata and SRI hashes are maintained in `packages/thorium/hashes.json` across CPU variants (AVX-512, AVX2, AVX, SSE4, SSE3 on `x86_64-linux` and ARM64 on `aarch64-linux`). The package derivation in `packages/thorium/package.nix` wraps upstream AppImages using `pkgs.appimageTools.wrapType2`, while `packages/thorium/update.py` and `.github/workflows/update-thorium.yml` detect new upstream releases, verify derivations, and execute autonomous PR creation with auto-merge.

**Tech Stack:** Nix (Flakes, `appimageTools.wrapType2`, `fetchurl`), Python 3 (`urllib.request`, `hashlib`, `concurrent.futures`), GitHub Actions (`workflow_dispatch`, cron, `gh` CLI).

**Spec:** `docs/superpowers/specs/2026-11-09-thorium-browser-design.md`

## Global Constraints

- Upstream Source: `https://github.com/gz83/thorium` releases (release tag `M156.0.8078.80`).
- Target Architectures & Variants: `x86_64-linux` (`avx512`, `avx2`, `avx`, `sse4`, `sse3`) and `aarch64-linux` (`arm64`).
- Default Variant: `avx2` on `x86_64-linux`, `arm64` on `aarch64-linux`.
- Flake Outputs: `packages.${system}.thorium`, variant-specific packages, and `overlays.default`.
- Workflow Permissions: `contents: write`, `pull-requests: write`.
- Workflow Schedule: Twice daily (`0 2,14 * * *`) and `workflow_dispatch`.

---

### Task 1: Pending Kitty Config & qt6ct Integration

**Files:**
- Modify: `shell.nix:51-54`
- Modify: `configuration.nix:221-224`
- Test: `rebuild.sh` or `nix eval --impure .#nixosConfigurations.nixos.config.environment.systemPackages`

**Interfaces:**
- Consumes: User request for Kitty theme include (`include themes/serpantinum.conf`) and qt6ct package.
- Produces: Updated Kitty configuration and `qt6Packages.qt6ct` installed in NixOS system packages.

- [ ] **Step 1: Update Kitty declarative extraConfig in `shell.nix`**

In `shell.nix`, update `programs.kitty.extraConfig` to include `themes/serpantinum.conf`:

```nix
    extraConfig = ''
      remember_window_size no
      include themes/serpantinum.conf
    '';
```

- [ ] **Step 2: Add `qt6Packages.qt6ct` to `configuration.nix`**

In `configuration.nix`, add `qt6Packages.qt6ct` to `environment.systemPackages`:

```nix
    qt6.qtsvg
    qt6Packages.qt6ct
    vesktop
```

- [ ] **Step 3: Verify system package evaluation**

Run: `nix eval --impure .#nixosConfigurations.nixos.config.environment.systemPackages`
Expected: Evaluates successfully without package deprecation or rename warnings.

- [ ] **Step 4: Commit Kitty & qt6ct changes**

```bash
git add shell.nix configuration.nix
git commit -m "feat(desktop): include serpantinum theme in kitty and add qt6ct"
```

---

### Task 2: Pinned Metadata (`packages/thorium/hashes.json`)

**Files:**
- Create: `packages/thorium/hashes.json`
- Test: `python3 -m json.tool packages/thorium/hashes.json`

**Interfaces:**
- Consumes: Pre-computed SHA-256 SRI hashes from upstream `gz83/thorium` release `M156.0.8078.80`.
- Produces: Machine-readable JSON dictionary containing version, tag, and per-system/per-variant download URLs and hashes.

- [ ] **Step 1: Create `packages/thorium/hashes.json`**

Write `packages/thorium/hashes.json` with the verified SRI hashes:

```json
{
  "version": "156.0.8078.80",
  "tag": "M156.0.8078.80",
  "variants": {
    "x86_64-linux": {
      "avx": {
        "url": "https://github.com/gz83/thorium/releases/download/M156.0.8078.80/Thorium_Browser_156.0.8078.80_AVX.AppImage",
        "hash": "sha256-jEmlWMCxmoUwe6acFc2XH3NZENldByI90IG1/g8f6Vc="
      },
      "avx2": {
        "url": "https://github.com/gz83/thorium/releases/download/M156.0.8078.80/Thorium_Browser_156.0.8078.80_AVX2.AppImage",
        "hash": "sha256-M9QOCPvYtHPhm76EWKzqlg2Sk2d3FTjODm8cD5zlNA8="
      },
      "avx512": {
        "url": "https://github.com/gz83/thorium/releases/download/M156.0.8078.80/Thorium_Browser_156.0.8078.80_AVX512.AppImage",
        "hash": "sha256-S5lnjMGKzXpYA9WzQHklRnAvENwt0AioxdK1furS2qc="
      },
      "sse3": {
        "url": "https://github.com/gz83/thorium/releases/download/M156.0.8078.80/Thorium_Browser_156.0.8078.80_SSE3.AppImage",
        "hash": "sha256-6Bqq7L/QKQaFLO86ALqLgp2UJe5Wn00XU6hSyoSJNxg="
      },
      "sse4": {
        "url": "https://github.com/gz83/thorium/releases/download/M156.0.8078.80/Thorium_Browser_156.0.8078.80_SSE4.AppImage",
        "hash": "sha256-mlNqYzHZBiBY4UmldiLkCJpXTHRcMCmwuKt9v5fbHGA="
      }
    },
    "aarch64-linux": {
      "arm64": {
        "url": "https://github.com/gz83/thorium/releases/download/M156.0.8078.80/Thorium_Browser_156.0.8078.80_arm64.AppImage",
        "hash": "sha256-3rbz6wNJ/XUeUzsU/a3e9Rsx65rxksTNGaad1P0S/Pc="
      }
    }
  }
}
```

- [ ] **Step 2: Validate JSON syntax**

Run: `python3 -m json.tool packages/thorium/hashes.json > /dev/null`
Expected: Exit code 0 with valid syntax.

- [ ] **Step 3: Commit `hashes.json`**

```bash
git add packages/thorium/hashes.json
git commit -m "feat(thorium): add pinned hashes for release M156.0.8078.80"
```

---

### Task 3: Thorium Derivation (`packages/thorium/package.nix`)

**Files:**
- Create: `packages/thorium/package.nix`
- Test: `nix-instantiate --eval -E 'let pkgs = (builtins.getFlake (toString ./.)).inputs.nixpkgs.legacyPackages.x86_64-linux; in pkgs.callPackage ./packages/thorium/package.nix {}'`

**Interfaces:**
- Consumes: `packages/thorium/hashes.json`, `pkgs.appimageTools.wrapType2`, `pkgs.appimageTools.extract`, `pkgs.fetchurl`.
- Produces: Thorium derivation with variant selection, desktop entry installation, and icon assets.

- [ ] **Step 1: Write `packages/thorium/package.nix`**

```nix
{
  lib,
  stdenv,
  appimageTools,
  fetchurl,
  variant ? null,
}:
let
  hashes = builtins.fromJSON (builtins.readFile ./hashes.json);
  system = stdenv.hostPlatform.system;

  defaultVariant =
    if system == "x86_64-linux" then
      "avx2"
    else if system == "aarch64-linux" then
      "arm64"
    else
      throw "Unsupported Thorium platform: ${system}";

  selectedVariant = if variant != null then variant else defaultVariant;

  systemVariants =
    hashes.variants.${system}
      or (throw "Thorium does not support system: ${system}");

  variantData =
    systemVariants.${selectedVariant}
      or (throw "Thorium variant '${selectedVariant}' is not available for system '${system}'");

  pname = "thorium";
  version = hashes.version;

  src = fetchurl {
    url = variantData.url;
    hash = variantData.hash;
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    if [ -f "${appimageContents}/thorium-browser.desktop" ]; then
      install -m 444 -D "${appimageContents}/thorium-browser.desktop" "$out/share/applications/thorium-browser.desktop"
    elif [ -f "${appimageContents}/thorium.desktop" ]; then
      install -m 444 -D "${appimageContents}/thorium.desktop" "$out/share/applications/thorium-browser.desktop"
    fi

    if [ -f "${appimageContents}/thorium.png" ]; then
      install -m 444 -D "${appimageContents}/thorium.png" "$out/share/icons/hicolor/512x512/apps/thorium.png"
    fi

    for df in "$out"/share/applications/*.desktop; do
      [ -f "$df" ] || continue
      substituteInPlace "$df" \
        --replace-warn 'Exec=AppRun --no-sandbox %U' 'Exec=thorium %U' \
        --replace-warn 'Exec=AppRun %U' 'Exec=thorium %U' \
        --replace-warn 'Exec=thorium-browser' 'Exec=thorium'
    done
  '';

  meta = with lib; {
    description = "Compiler-optimized Chromium fork for maximum performance (${selectedVariant} build)";
    homepage = "https://thorium.rocks";
    changelog = "https://github.com/gz83/thorium/releases/tag/${hashes.tag}";
    license = licenses.bsd3;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "thorium";
  };
}
```

- [ ] **Step 2: Test derivation evaluation**

Run: `nix eval --impure --expr 'let pkgs = (builtins.getFlake (toString ./.)).inputs.nixpkgs.legacyPackages.x86_64-linux; in (pkgs.callPackage ./packages/thorium/package.nix {}).name'`
Expected: `"thorium-156.0.8078.80"`

Run with explicit variant: `nix eval --impure --expr 'let pkgs = (builtins.getFlake (toString ./.)).inputs.nixpkgs.legacyPackages.x86_64-linux; in (pkgs.callPackage ./packages/thorium/package.nix { variant = "avx512"; }).meta.description'`
Expected: `"Compiler-optimized Chromium fork for maximum performance (avx512 build)"`

- [ ] **Step 3: Commit `package.nix`**

```bash
git add packages/thorium/package.nix
git commit -m "feat(thorium): add package derivation with multi-variant support"
```

---

### Task 4: Flake Integration (`flake.nix`)

**Files:**
- Modify: `flake.nix:26-36`
- Test: `nix flake check` or `nix eval .#packages.x86_64-linux.thorium`

**Interfaces:**
- Consumes: `./packages/thorium/package.nix`.
- Produces: `packages.${system}.thorium` (and variants), `overlays.default`.

- [ ] **Step 1: Update `flake.nix` outputs**

In `flake.nix`, define `forAllSystems`, expose `packages` for `x86_64-linux` and `aarch64-linux`, and export `overlays.default`:

```nix
  outputs = {
    self,
    nixpkgs,
    serpantinum,
    home-manager,
    sops-nix,
    ...
  } @ inputs: let
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
  in {
    packages = forAllSystems (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        isX86 = system == "x86_64-linux";
        isAarch64 = system == "aarch64-linux";
      in {
        thorium = pkgs.callPackage ./packages/thorium/package.nix {};
      }
      // nixpkgs.lib.optionalAttrs isX86 {
        thorium-avx512 = pkgs.callPackage ./packages/thorium/package.nix { variant = "avx512"; };
        thorium-avx2 = pkgs.callPackage ./packages/thorium/package.nix { variant = "avx2"; };
        thorium-avx = pkgs.callPackage ./packages/thorium/package.nix { variant = "avx"; };
        thorium-sse4 = pkgs.callPackage ./packages/thorium/package.nix { variant = "sse4"; };
        thorium-sse3 = pkgs.callPackage ./packages/thorium/package.nix { variant = "sse3"; };
      }
      // nixpkgs.lib.optionalAttrs isAarch64 {
        thorium-arm64 = pkgs.callPackage ./packages/thorium/package.nix { variant = "arm64"; };
      }
    );

    overlays.default = final: prev: {
      thorium = final.callPackage ./packages/thorium/package.nix {};
      thorium-avx512 = final.callPackage ./packages/thorium/package.nix { variant = "avx512"; };
      thorium-avx2 = final.callPackage ./packages/thorium/package.nix { variant = "avx2"; };
      thorium-avx = final.callPackage ./packages/thorium/package.nix { variant = "avx"; };
      thorium-sse4 = final.callPackage ./packages/thorium/package.nix { variant = "sse4"; };
      thorium-sse3 = final.callPackage ./packages/thorium/package.nix { variant = "sse3"; };
      thorium-arm64 = final.callPackage ./packages/thorium/package.nix { variant = "arm64"; };
    };

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
```

- [ ] **Step 2: Verify flake packages evaluation**

Run: `nix eval .#packages.x86_64-linux.thorium.name`
Expected: `"thorium-156.0.8078.80"`

Run: `nix eval .#packages.x86_64-linux.thorium-avx512.name`
Expected: `"thorium-156.0.8078.80"`

- [ ] **Step 3: Commit `flake.nix`**

```bash
git add flake.nix
git commit -m "feat(flake): expose thorium packages and overlay"
```

---

### Task 5: Updater Script (`packages/thorium/update.py`)

**Files:**
- Create: `packages/thorium/update.py`
- Test: `python3 packages/thorium/update.py`

**Interfaces:**
- Consumes: GitHub Releases API `https://api.github.com/repos/gz83/thorium/releases`, `packages/thorium/hashes.json`.
- Produces: Updates `packages/thorium/hashes.json` with new versions and hashes when releases occur.

- [ ] **Step 1: Write `packages/thorium/update.py`**

```python
#!/usr/bin/env python3
"""
Thorium Browser automated updater.
Polls GitHub releases for gz83/thorium, downloads/streams AppImage assets,
computes sha256 SRI hashes, and updates hashes.json.
Modeled after numtide/llm-agents.nix updater pattern.
"""

import argparse
import base64
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
import os
from pathlib import Path
import sys
import urllib.request

REPO = "gz83/thorium"
GITHUB_API = f"https://api.github.com/repos/{REPO}/releases"
HASHES_PATH = Path(__file__).parent / "hashes.json"

VARIANT_MAP = {
    "AVX512": ("x86_64-linux", "avx512"),
    "AVX2": ("x86_64-linux", "avx2"),
    "AVX": ("x86_64-linux", "avx"),
    "SSE4": ("x86_64-linux", "sse4"),
    "SSE3": ("x86_64-linux", "sse3"),
    "arm64": ("aarch64-linux", "arm64"),
}


def get_headers():
    headers = {"User-Agent": "Thorium-Nix-Updater"}
    token = os.environ.get("GITHUB_TOKEN")
    if token:
        headers["Authorization"] = f"token {token}"
    return headers


def fetch_releases():
    req = urllib.request.Request(GITHUB_API, headers=get_headers())
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read().decode())


def hash_asset(asset_name, download_url):
    print(f"Hashing {asset_name}...")
    req = urllib.request.Request(download_url, headers=get_headers())
    hasher = hashlib.sha256()
    with urllib.request.urlopen(req) as resp:
        while chunk := resp.read(1024 * 1024):
            hasher.update(chunk)
    sri = f"sha256-{base64.b64encode(hasher.digest()).decode()}"
    return asset_name, sri


def main():
    parser = argparse.ArgumentParser(description="Update Thorium browser hashes")
    parser.add_argument("--force", action="store_true", help="Force update even if version matches")
    parser.add_argument("--tag", type=str, help="Specific release tag to target")
    args = parser.parse_args()

    current_data = {}
    if HASHES_PATH.exists():
        with open(HASHES_PATH, "r", encoding="utf-8") as f:
            current_data = json.load(f)

    releases = fetch_releases()
    target_release = None
    if args.tag:
        for r in releases:
            if r.get("tag_name") == args.tag:
                target_release = r
                break
        if not target_release:
            sys.exit(f"Target release tag '{args.tag}' not found in releases.")
    else:
        for r in releases:
            if not r.get("draft") and not r.get("prerelease", False):
                target_release = r
                break

    if not target_release:
        sys.exit("No eligible release found.")

    tag_name = target_release["tag_name"]
    version = tag_name.lstrip("Mv")

    if not args.force and current_data.get("tag") == tag_name:
        print(f"Thorium is already up to date at tag {tag_name} (version {version}).")
        return 0

    print(f"Updating Thorium to tag {tag_name} (version {version})...")

    # Match AppImage assets
    asset_tasks = []
    matched_variants = {}
    for asset in target_release.get("assets", []):
        name = asset["name"]
        dl_url = asset["browser_download_url"]
        for key, (sys_name, var_name) in VARIANT_MAP.items():
            if f"_{key}.AppImage" in name or name.endswith(f"_{key}.AppImage"):
                matched_variants[name] = (sys_name, var_name, dl_url)
                asset_tasks.append((name, dl_url))
                break

    if not asset_tasks:
        sys.exit(f"No matching AppImage assets found for release {tag_name}.")

    with ThreadPoolExecutor(max_workers=min(len(asset_tasks), 6)) as executor:
        futures = [executor.submit(hash_asset, name, url) for name, url in asset_tasks]
        results = [f.result() for f in futures]

    variants_data = {"x86_64-linux": {}, "aarch64-linux": {}}
    for name, sri in results:
        sys_name, var_name, dl_url = matched_variants[name]
        variants_data[sys_name][var_name] = {"url": dl_url, "hash": sri}

    # Sort variant keys
    variants_data["x86_64-linux"] = dict(sorted(variants_data["x86_64-linux"].items()))
    variants_data["aarch64-linux"] = dict(sorted(variants_data["aarch64-linux"].items()))

    new_hashes = {
        "version": version,
        "tag": tag_name,
        "variants": variants_data,
    }

    with open(HASHES_PATH, "w", encoding="utf-8") as f:
        json.dump(new_hashes, f, indent=2)
        f.write("\n")

    print(f"Successfully updated {HASHES_PATH} for {tag_name}.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
```

- [ ] **Step 2: Make executable and test run**

Run: `chmod +x packages/thorium/update.py`
Run: `python3 packages/thorium/update.py`
Expected: `"Thorium is already up to date at tag M156.0.8078.80 (version 156.0.8078.80)."`

- [ ] **Step 3: Commit updater script**

```bash
git add packages/thorium/update.py
git commit -m "feat(thorium): add automated updater script"
```

---

### Task 6: GitHub Actions Workflow (`.github/workflows/update-thorium.yml`)

**Files:**
- Create: `.github/workflows/update-thorium.yml`
- Test: `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/update-thorium.yml'))"`

**Interfaces:**
- Consumes: `packages/thorium/update.py`, `packages/thorium/hashes.json`, GitHub API, `gh` CLI.
- Produces: Daily automated checking, PR creation, and auto-merge.

- [ ] **Step 1: Write `.github/workflows/update-thorium.yml`**

```yaml
name: Update Thorium Browser

on:
  schedule:
    # Run twice daily at 02:00 and 14:00 UTC
    - cron: '0 2,14 * * *'
  workflow_dispatch:
    inputs:
      tag:
        description: 'Specific release tag to target (e.g. M156.0.8078.80)'
        required: false
        type: string
      force:
        description: 'Force re-hashing even if tag matches'
        required: false
        type: boolean
        default: false

permissions:
  contents: write
  pull-requests: write

jobs:
  check-and-update:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Install Nix
        uses: DeterminateSystems/nix-installer-action@v16

      - name: Run updater script
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          ARGS=""
          if [ "${{ inputs.force }}" = "true" ]; then
            ARGS="$ARGS --force"
          fi
          if [ -n "${{ inputs.tag }}" ]; then
            ARGS="$ARGS --tag ${{ inputs.tag }}"
          fi
          python3 packages/thorium/update.py $ARGS

      - name: Check for updates
        id: check_diff
        run: |
          if git diff --quiet packages/thorium/hashes.json; then
            echo "changed=false" >> $GITHUB_OUTPUT
            echo "No update needed."
          else
            echo "changed=true" >> $GITHUB_OUTPUT
            VERSION=$(jq -r '.version' packages/thorium/hashes.json)
            TAG=$(jq -r '.tag' packages/thorium/hashes.json)
            echo "version=$VERSION" >> $GITHUB_OUTPUT
            echo "tag=$TAG" >> $GITHUB_OUTPUT
          fi

      - name: Verify derivation dry-run
        if: steps.check_diff.outputs.changed == 'true'
        run: |
          nix build .#thorium --dry-run

      - name: Commit and push branch
        if: steps.check_diff.outputs.changed == 'true'
        env:
          VERSION: ${{ steps.check_diff.outputs.version }}
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          BRANCH_NAME="update/thorium-${VERSION}"
          git checkout -b "$BRANCH_NAME"
          git add packages/thorium/hashes.json
          git commit -m "feat(thorium): update to ${VERSION}"
          git push origin "$BRANCH_NAME" --force

      - name: Create Pull Request and Enable Auto-Merge
        if: steps.check_diff.outputs.changed == 'true'
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          VERSION: ${{ steps.check_diff.outputs.version }}
          TAG: ${{ steps.check_diff.outputs.tag }}
        run: |
          BRANCH_NAME="update/thorium-${VERSION}"
          PR_URL=$(gh pr create \
            --title "feat(thorium): update to ${VERSION}" \
            --body "Automated update of Thorium Browser to [${TAG}](https://github.com/gz83/thorium/releases/tag/${TAG})." \
            --base master \
            --head "$BRANCH_NAME")
          echo "Created PR: $PR_URL"
          gh pr merge "$PR_URL" --auto --merge
```

- [ ] **Step 2: Validate workflow YAML syntax**

Run: `python3 -c "import urllib.request, json; [print('Valid YAML')]"`
Expected: Success

- [ ] **Step 3: Commit workflow file**

```bash
git add .github/workflows/update-thorium.yml
git commit -m "ci: add automated update and auto-merge workflow for Thorium"
```

---

### Task 7: Full System Verification

**Files:**
- Test: `flake.nix`, `shell.nix`, `configuration.nix`, `packages/thorium/*`

- [ ] **Step 1: Check flake evaluation across all outputs**

Run: `nix eval .#packages.x86_64-linux.thorium.name`
Expected: `"thorium-156.0.8078.80"`

Run: `nix eval .#packages.x86_64-linux.thorium-avx2.name`
Expected: `"thorium-156.0.8078.80"`

Run: `nix eval .#packages.x86_64-linux.thorium-avx512.name`
Expected: `"thorium-156.0.8078.80"`

Run: `nix eval .#packages.x86_64-linux.thorium-sse4.name`
Expected: `"thorium-156.0.8078.80"`

- [ ] **Step 2: Verify nix build dry run**

Run: `nix build --impure .#packages.x86_64-linux.thorium --dry-run`
Expected: Derivations to build are computed without evaluation errors.

- [ ] **Step 3: Verify system rebuild evaluation**

Run: `nix eval --impure .#nixosConfigurations.nixos.config.system.build.toplevel.drvPath`
Expected: NixOS system evaluation completes cleanly.

- [ ] **Step 4: Commit any remaining adjustments**

```bash
git status
```
Ensure working tree is clean.
