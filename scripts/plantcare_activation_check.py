#!/usr/bin/env python3
"""PlantCare AI activation-readiness checker.

This script does not deploy services or require secrets. It reports which
repository-side activation assets are present and which external assets remain.
"""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ARTIFACT = ROOT / "artifacts" / "plant_disease_mobilenetv3.pth"
CLASSES = ROOT / "artifacts" / "class_names.txt"
MOBILE = ROOT / "mobile"
ANDROID = MOBILE / "android"
IOS = MOBILE / "ios"
FIREBASE_OPTIONS = MOBILE / "lib" / "firebase_options.dart"
ANDROID_FIREBASE = ANDROID / "app" / "google-services.json"
IOS_FIREBASE = IOS / "Runner" / "GoogleService-Info.plist"

EXPECTED_CLASSES = 38
VALIDATOR = ROOT / "scripts" / "validate_model_artifact.py"


def report(label: str, ok: bool, detail: str) -> None:
    print(f"[{'READY' if ok else 'BLOCKED'}] {label}: {detail}")


def main() -> int:
    blocked = 0

    artifact_ok = ARTIFACT.is_file() and ARTIFACT.stat().st_size > 0
    report("Model artifact", artifact_ok, str(ARTIFACT))
    blocked += not artifact_ok

    class_ok = False
    count = 0
    duplicate_names = False
    if CLASSES.is_file():
        classes = [
            line.strip()
            for line in CLASSES.read_text(encoding="utf-8").splitlines()
            if line.strip()
        ]
        count = len(classes)
        duplicate_names = len(set(classes)) != len(classes)
        class_ok = count == EXPECTED_CLASSES and not duplicate_names
    detail = f"{count}/{EXPECTED_CLASSES} classes at {CLASSES}"
    if duplicate_names:
        detail += "; duplicate class names detected"
    report("Class names", class_ok, detail)
    blocked += not class_ok

    if artifact_ok and class_ok:
        validator = subprocess.run(
            [sys.executable, str(VALIDATOR), "--json"],
            cwd=ROOT,
            capture_output=True,
            text=True,
        )
        validator_ok = validator.returncode == 0
        report(
            "Model package compatibility",
            validator_ok,
            (
                "MobileNetV3 state_dict + class mapping passed."
                if validator_ok
                else validator.stdout.strip() or validator.stderr.strip()
            ),
        )
        blocked += not validator_ok

    android_ok = ANDROID.is_dir()
    ios_ok = IOS.is_dir()
    report("Android project", android_ok, str(ANDROID))
    report("iOS project", ios_ok, str(IOS))
    blocked += not android_ok
    blocked += not ios_ok

    firebase_ok = (
        FIREBASE_OPTIONS.is_file()
        and ANDROID_FIREBASE.is_file()
        and IOS_FIREBASE.is_file()
    )
    report(
        "Firebase native configuration",
        firebase_ok,
        "firebase_options.dart + Android + iOS configuration",
    )
    blocked += not firebase_ok

    render_file = ROOT / "render.yaml"
    inference_verifier = ROOT / "scripts" / "verify_inference_endpoint.py"
    hosting_config_ok = render_file.is_file() and inference_verifier.is_file()
    report(
        "Inference hosting configuration",
        hosting_config_ok,
        "render.yaml + hosted endpoint verifier are present",
    )
    blocked += not hosting_config_ok

    migrations = sorted((ROOT / "backend" / "supabase").glob("*.sql"))
    migrations_ok = bool(migrations)
    report(
        "Supabase migration tree",
        migrations_ok,
        f"{len(migrations)} migration files present; live application still requires a configured project.",
    )
    blocked += not migrations_ok

    print()
    if blocked:
        print(f"Activation remains blocked by {blocked} repository/device asset gate(s).")
        print("This checker intentionally does not treat Demo mode as production activation.")
        return 1

    print(
        "Repository-side activation assets are present. "
        "Proceed to configured-environment E2E verification."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
