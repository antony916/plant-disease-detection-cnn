#!/usr/bin/env python3
"""Verify a deployed PlantCare AI inference endpoint.

This check is intentionally dependency-free so it can run from a clean Python
installation. It verifies the public contract without requiring Supabase or
mobile credentials.

Examples:
    python scripts/verify_inference_endpoint.py --base-url https://example.onrender.com
    python scripts/verify_inference_endpoint.py --base-url https://example.onrender.com --image leaf.jpg

Exit code is non-zero when any requested verification fails.
"""

from __future__ import annotations

import argparse
import json
import mimetypes
import sys
import uuid
from pathlib import Path
from urllib import error, request


SUPPORTED_TYPES = {
    ".jpg": "image/jpeg",
    ".jpeg": "image/jpeg",
    ".png": "image/png",
    ".webp": "image/webp",
}


def request_json(url: str, *, method: str = "GET", data: bytes | None = None, headers: dict[str, str] | None = None) -> object:
    req = request.Request(url, data=data, method=method, headers=headers or {})
    with request.urlopen(req, timeout=60) as response:
        payload = response.read().decode("utf-8")
        return json.loads(payload)


def build_multipart(field_name: str, filename: str, content_type: str, data: bytes, extra_fields: dict[str, str]) -> tuple[bytes, str]:
    boundary = f"----PlantCareBoundary{uuid.uuid4().hex}"
    chunks: list[bytes] = []
    for name, value in extra_fields.items():
        chunks.extend(
            [
                f"--{boundary}\r\n".encode(),
                f'Content-Disposition: form-data; name="{name}"\r\n\r\n'.encode(),
                value.encode(),
                b"\r\n",
            ]
        )
    chunks.extend(
        [
            f"--{boundary}\r\n".encode(),
            f'Content-Disposition: form-data; name="{field_name}"; filename="{filename}"\r\n'.encode(),
            f"Content-Type: {content_type}\r\n\r\n".encode(),
            data,
            b"\r\n",
            f"--{boundary}--\r\n".encode(),
        ]
    )
    return b"".join(chunks), f"multipart/form-data; boundary={boundary}"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise RuntimeError(message)


def verify_health(base_url: str) -> dict:
    result = request_json(f"{base_url}/health")
    require(isinstance(result, dict), "/health did not return a JSON object.")
    require(result.get("status") == "ok", f"/health status was {result.get('status')!r}.")
    capabilities = result.get("available_capabilities")
    require(isinstance(capabilities, list) and "disease" in capabilities, "Disease capability is not reported as available.")
    return result


def verify_models(base_url: str) -> dict:
    result = request_json(f"{base_url}/models")
    require(isinstance(result, dict), "/models did not return a JSON object.")
    models = result.get("models")
    require(isinstance(models, list), "/models response is missing a models list.")
    disease = next((model for model in models if isinstance(model, dict) and model.get("capability") == "disease"), None)
    require(disease is not None, "Disease model definition is missing from /models.")
    require(disease.get("status") == "available", "Disease model is not marked available.")
    require(disease.get("model_id") == "plant-disease-mobilenetv3", "Unexpected disease model_id.")
    require(disease.get("version") == "plantvillage-mobilenetv3-38-class", "Unexpected disease model version.")
    require(disease.get("expected_class_count") == 38, "Disease model does not advertise 38 classes.")
    return result


def verify_prediction(base_url: str, image_path: Path) -> dict:
    suffix = image_path.suffix.lower()
    content_type = SUPPORTED_TYPES.get(suffix) or mimetypes.guess_type(image_path.name)[0]
    require(content_type in SUPPORTED_TYPES.values(), f"Unsupported image type: {suffix or image_path.name}.")
    data = image_path.read_bytes()
    require(bool(data), "Image file is empty.")

    body, multipart_type = build_multipart(
        "image",
        image_path.name,
        content_type,
        data,
        {"capability": "disease"},
    )
    result = request_json(
        f"{base_url}/predict",
        method="POST",
        data=body,
        headers={"Content-Type": multipart_type, "Accept": "application/json"},
    )
    require(isinstance(result, dict), "/predict did not return a JSON object.")
    require(result.get("schema_version") == "1.1", "Unexpected prediction schema_version.")
    require(result.get("capability") == "disease", "Prediction capability is not disease.")
    require(result.get("model_id") == "plant-disease-mobilenetv3", "Prediction model_id mismatch.")
    require(result.get("model_version") == "plantvillage-mobilenetv3-38-class", "Prediction model_version mismatch.")

    confidence = result.get("confidence")
    require(isinstance(confidence, (int, float)) and 0 <= confidence <= 1, "Prediction confidence is outside [0, 1].")

    top_predictions = result.get("top_predictions")
    require(isinstance(top_predictions, list) and 1 <= len(top_predictions) <= 5, "Prediction top_predictions is missing or invalid.")
    for prediction in top_predictions:
        require(
            isinstance(prediction, dict)
            and isinstance(prediction.get("class"), str)
            and isinstance(prediction.get("confidence"), (int, float))
            and 0 <= prediction["confidence"] <= 1,
            "Invalid top_predictions entry.",
        )

    require(isinstance(result.get("needs_expert_review"), bool), "needs_expert_review is missing or invalid.")
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base-url", required=True, help="HTTPS base URL of the deployed PlantCare inference API.")
    parser.add_argument("--image", type=Path, help="Optional JPEG/PNG/WebP image for a real /predict smoke test.")
    args = parser.parse_args()

    base_url = args.base_url.rstrip("/")
    if not base_url.startswith("https://"):
        raise SystemExit("--base-url must use HTTPS for deployed verification.")

    try:
        health = verify_health(base_url)
        models = verify_models(base_url)
        print("[PASS] /health")
        print(json.dumps(health, indent=2, sort_keys=True))
        print("[PASS] /models")
        print(json.dumps(models, indent=2, sort_keys=True))

        if args.image:
            prediction = verify_prediction(base_url, args.image)
            print("[PASS] /predict")
            print(json.dumps(prediction, indent=2, sort_keys=True))
        else:
            print("[SKIP] /predict — pass --image to run a real-image inference smoke test.")

    except (OSError, error.HTTPError, error.URLError, RuntimeError, json.JSONDecodeError) as exc:
        print(f"[FAIL] {exc}", file=sys.stderr)
        return 1

    print()
    print("Inference endpoint contract verification completed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
