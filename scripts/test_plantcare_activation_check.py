#!/usr/bin/env python3
"""Regression tests for PlantCare AI activation-readiness gates."""

from __future__ import annotations

import tempfile
import unittest
from pathlib import Path
from unittest import mock

import plantcare_activation_check as checker


class ActivationCheckerTests(unittest.TestCase):
    def _fake_root(self, *, firebase: bool) -> tuple[Path, dict[str, Path]]:
        root = Path(tempfile.mkdtemp())
        artifacts = root / "artifacts"
        mobile = root / "mobile"
        android = mobile / "android"
        ios = mobile / "ios"
        (artifacts).mkdir(parents=True)
        android.mkdir(parents=True)
        ios.mkdir(parents=True)
        (artifacts / "plant_disease_mobilenetv3.pth").write_bytes(b"model")
        (artifacts / "class_names.txt").write_text(
            "\n".join(f"class-{i}" for i in range(38)) + "\n",
            encoding="utf-8",
        )
        if firebase:
            (mobile / "lib").mkdir(parents=True)
            (mobile / "lib" / "firebase_options.dart").write_text("// test\n", encoding="utf-8")
            (android / "app").mkdir(parents=True)
            (android / "app" / "google-services.json").write_text("{}", encoding="utf-8")
            (ios / "Runner").mkdir(parents=True)
            (ios / "Runner" / "GoogleService-Info.plist").write_text("<plist/>", encoding="utf-8")
        (root / "render.yaml").write_text("services:\n  - name: plantcare-inference\n", encoding="utf-8")
        (root / "scripts").mkdir(parents=True)
        verifier = root / "scripts" / "verify_inference_endpoint.py"
        verifier.write_text("# verifier\n", encoding="utf-8")
        (root / "backend" / "supabase").mkdir(parents=True)
        (root / "backend" / "supabase" / "001_initial_schema.sql").write_text("-- test\n", encoding="utf-8")
        validator = root / "scripts" / "validate_model_artifact.py"
        validator.write_text(
            "import sys\n"
            "sys.exit(0)\n",
            encoding="utf-8",
        )
        return root, {
            "artifact": artifacts / "plant_disease_mobilenetv3.pth",
            "classes": artifacts / "class_names.txt",
            "mobile": mobile,
            "android": android,
            "ios": ios,
            "firebase_options": mobile / "lib" / "firebase_options.dart",
            "android_firebase": android / "app" / "google-services.json",
            "ios_firebase": ios / "Runner" / "GoogleService-Info.plist",
            "validator": validator,
        }

    def _run(self, root: Path, paths: dict[str, Path]) -> int:
        values = {
            "ROOT": root,
            "ARTIFACT": paths["artifact"],
            "CLASSES": paths["classes"],
            "MOBILE": paths["mobile"],
            "ANDROID": paths["android"],
            "IOS": paths["ios"],
            "FIREBASE_OPTIONS": paths["firebase_options"],
            "ANDROID_FIREBASE": paths["android_firebase"],
            "IOS_FIREBASE": paths["ios_firebase"],
            "VALIDATOR": paths["validator"],
        }
        with mock.patch.multiple(checker, **values):
            return checker.main()

    def test_missing_firebase_is_an_activation_blocker(self) -> None:
        root, paths = self._fake_root(firebase=False)
        self.assertNotEqual(self._run(root, paths), 0)

    def test_complete_repository_assets_pass_activation_gate(self) -> None:
        root, paths = self._fake_root(firebase=True)
        self.assertEqual(self._run(root, paths), 0)


if __name__ == "__main__":
    unittest.main()
