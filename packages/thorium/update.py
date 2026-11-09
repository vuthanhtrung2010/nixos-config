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
