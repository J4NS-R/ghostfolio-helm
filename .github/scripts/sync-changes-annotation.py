#!/usr/bin/env python3
"""Sync the artifacthub.io/changes annotation in chart/Chart.yaml.

When Renovate opens a PR bumping chart dependencies or the appVersion, this
script compares the modified Chart.yaml against the PR base ref, detects which
version lines moved, and rewrites the artifacthub.io/changes annotation with a
single new `kind: changed` entry describing those bumps.

Exit codes:
  0 - annotation updated (or no changes needed); commit upstream
  1 - error
"""

import argparse
import os
import re
import subprocess
import sys
from pathlib import Path


CHART_FILE = Path("chart/Chart.yaml")

ANNOTATION_BLOCK_RE = re.compile(
    r"  artifacthub\.io/changes: \|\n"
    r"(?:    -[^\n]*\n(?:      [^\n]*\n)*)+"
)

APPVERSION_RE = re.compile(r'^appVersion:\s*"?([^"\s]+)"?', re.MULTILINE)
DEPENDENCIES_HEADER_RE = re.compile(r"^dependencies:\s*\n((?:\n|.+)+)", re.MULTILINE)
ITEM_RE = re.compile(r'^\s*-\s*name:\s*(\S+)\s*$')
ITEM_VERSION_RE = re.compile(r'^\s+version:\s*"?([^"\s]+)"?')


def _git_show(ref: str) -> str:
    candidates = [ref, f"origin/{ref}"]
    for candidate in candidates:
        result = subprocess.run(
            ["git", "show", f"{candidate}:{CHART_FILE}"],
            capture_output=True,
            text=True,
            check=False,
        )
        if result.returncode == 0:
            print(f"Resolved base ref {ref!r} via {candidate!r}", file=sys.stderr)
            return result.stdout
        print(
            f"git show {candidate}:{CHART_FILE} failed: {result.stderr.strip() or 'unknown error'}",
            file=sys.stderr,
        )
    print(
        f"::error::Could not resolve base ref {ref!r} (tried: {', '.join(candidates)})",
        file=sys.stderr,
    )
    return ""


def _parse_dependencies(text: str) -> dict:
    deps: dict = {}
    m = DEPENDENCIES_HEADER_RE.search(text)
    if not m:
        return deps
    current = None
    for line in m.group(1).splitlines():
        if not line.strip():
            current = None
            continue
        if line.lstrip().startswith("- "):
            name_m = ITEM_RE.match(line)
            if name_m:
                current = name_m.group(1)
                deps.setdefault(current, None)
            continue
        if line.startswith(" ") and current is not None:
            ver_m = ITEM_VERSION_RE.match(line)
            if ver_m and deps.get(current) is None:
                deps[current] = ver_m.group(1)
                current = None
        elif not line.startswith(" "):
            current = None
    return {k: v for k, v in deps.items() if v is not None}


def parse_chart(text: str) -> dict:
    data: dict = {"appVersion": None, "dependencies": {}}
    if not text:
        return data
    m = APPVERSION_RE.search(text)
    if m:
        data["appVersion"] = m.group(1)
    data["dependencies"] = _parse_dependencies(text)
    return data


def detect_bumps(base_ref: str) -> list[str]:
    before_text = _git_show(base_ref)
    after_text = CHART_FILE.read_text()
    print(f"Base content: {len(before_text)} bytes", file=sys.stderr)
    print(f"Head content: {len(after_text)} bytes", file=sys.stderr)

    before = parse_chart(before_text)
    after = parse_chart(after_text)
    print(f"Parsed before: {before}", file=sys.stderr)
    print(f"Parsed after:  {after}", file=sys.stderr)

    fragments: list[str] = []

    if before["appVersion"] and after["appVersion"] and before["appVersion"] != after["appVersion"]:
        fragments.append(f"Upgrade Ghostfolio to v{after['appVersion']}")

    for name, new_ver in after["dependencies"].items():
        old_ver = before["dependencies"].get(name)
        if old_ver and old_ver != new_ver:
            fragments.append(f"Bump {name} subchart to {new_ver}")

    if fragments:
        print(f"Detected bumps: {fragments}", file=sys.stderr)
    else:
        print("No version-line changes detected.", file=sys.stderr)

    return fragments


def render_annotation(description: str) -> str:
    return (
        "  artifacthub.io/changes: |\n"
        "    - kind: changed\n"
        f"      description: {description}\n"
    )


def update_chart_file(description: str) -> bool:
    text = CHART_FILE.read_text()
    new_block = render_annotation(description)
    new_text, n = ANNOTATION_BLOCK_RE.subn(new_block, text, count=1)
    if n == 0:
        print(
            "::error::Could not locate existing artifacthub.io/changes block in chart/Chart.yaml",
            file=sys.stderr,
        )
        sys.exit(1)
    if new_text == text:
        return False
    CHART_FILE.write_text(new_text)
    return True


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--base-ref",
        default=os.environ.get("BASE_REF", "master"),
    )
    parser.add_argument(
        "--chart-file",
        default=os.environ.get("CHART_FILE", "chart/Chart.yaml"),
    )
    args = parser.parse_args()

    global CHART_FILE
    CHART_FILE = Path(args.chart_file)

    fragments = detect_bumps(args.base_ref)
    if not fragments:
        print("No version-line changes detected; annotation left untouched.")
        return 0

    description = "; ".join(fragments)
    print(f"New annotation description: {description}")
    if update_chart_file(description):
        print(f"{CHART_FILE} updated.")
    else:
        print(f"{CHART_FILE} already up to date.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
