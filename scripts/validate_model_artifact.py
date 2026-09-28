#!/usr/bin/env python3
"""Validate the PlantCare disease-model artifact package.

This validator checks repository model assets without retraining anything and
without downloading pretrained ImageNet weights.

Usage:
    python scripts/validate_model_artifact.py
    python scripts/validate_model_artifact.py --json
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

import torch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

MODEL_PATH = ROOT / "artifacts" / "plant_disease_mobilenetv3.pth"
CLASS_NAMES_PATH = ROOT / "artifacts" / "class_names.txt"
EXPECTED_CLASSES = 38


def fail(message: str) -> None:
    raise RuntimeError(message)


def load_classes() -> list[str]:
    if not CLASS_NAMES_PATH.is_file():
        fail(f"Class names file not found: {CLASS_NAMES_PATH}")

    classes = [
        line.strip()
        for line in CLASS_NAMES_PATH.read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]

    if len(classes) != EXPECTED_CLASSES:
        fail(
            f"Expected {EXPECTED_CLASSES} class names, found {len(classes)}."
        )

    if len(set(classes)) != len(classes):
        fail("Duplicate class names detected.")

    return classes


def load_state_dict() -> dict[str, torch.Tensor]:
    if not MODEL_PATH.is_file():
        fail(f"Model artifact not found: {MODEL_PATH}")

    if MODEL_PATH.stat().st_size == 0:
        fail(f"Model artifact is empty: {MODEL_PATH}")

    state = torch.load(MODEL_PATH, map_location="cpu")

    if not isinstance(state, dict):
        fail(
            "Expected the artifact to contain a PyTorch state_dict mapping. "
            f"Found {type(state).__name__}."
        )

    return state


def validate_architecture(num_classes: int, state: dict[str, torch.Tensor]) -> None:
    from src.model import build_model

    model = build_model(num_classes, pretrained=False)
    expected = model.state_dict()

    missing = sorted(set(expected) - set(state))
    unexpected = sorted(set(state) - set(expected))

    if missing:
        fail(f"Model artifact is missing {len(missing)} expected state_dict keys.")
    if unexpected:
        fail(f"Model artifact contains {len(unexpected)} unexpected state_dict keys.")

    for key, expected_tensor in expected.items():
        actual_tensor = state[key]
        if tuple(actual_tensor.shape) != tuple(expected_tensor.shape):
            fail(
                f"Tensor shape mismatch for '{key}': "
                f"expected {tuple(expected_tensor.shape)}, "
                f"found {tuple(actual_tensor.shape)}."
            )


def validate() -> dict[str, object]:
    classes = load_classes()
    state = load_state_dict()
    validate_architecture(len(classes), state)

    classifier_weight = state.get("classifier.3.weight")

    return {
        "status": "ready",
        "model_path": str(MODEL_PATH),
        "classes_path": str(CLASS_NAMES_PATH),
        "class_count": len(classes),
        "first_class": classes[0],
        "last_class": classes[-1],
        "state_dict_keys": len(state),
        "classifier_shape": (
            list(classifier_weight.shape) if classifier_weight is not None else None
        ),
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()

    try:
        result = validate()
    except (OSError, RuntimeError, ValueError) as exc:
        if args.json:
            print(json.dumps({"status": "blocked", "error": str(exc)}))
        else:
            print(f"[BLOCKED] {exc}")
        return 1

    if args.json:
        print(json.dumps(result, indent=2))
    else:
        print("[READY] PlantCare disease-model artifact passed validation.")
        print(f"       Classes: {result['class_count']}")
        print(f"       Model:   {result['model_path']}")
        print(f"       Classes: {result['classes_path']}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
