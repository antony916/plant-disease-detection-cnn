import io
import os
from pathlib import Path

import torch
from fastapi import FastAPI, File, Form, HTTPException, UploadFile
from PIL import Image
from torchvision import transforms

from config import IMAGE_SIZE
from src.model import build_model
from .model_registry import (
    get_model_definition,
    model_summary,
    resolve_artifact_paths,
)

ROOT = Path(__file__).resolve().parents[1]
LOW_CONFIDENCE_THRESHOLD = float(
    os.getenv("PLANTCARE_LOW_CONFIDENCE_THRESHOLD", "0.60")
)

app = FastAPI(
    title="PlantCare AI Inference API",
    version="0.2.0",
)

transform = transforms.Compose(
    [
        transforms.Resize((IMAGE_SIZE, IMAGE_SIZE)),
        transforms.ToTensor(),
        transforms.Normalize(
            [0.485, 0.456, 0.406],
            [0.229, 0.224, 0.225],
        ),
    ]
)

_models: dict[str, torch.nn.Module] = {}
_classes: dict[str, list[str]] = {}
_device = torch.device("cuda" if torch.cuda.is_available() else "cpu")


def load_model(capability: str) -> None:
    definition = get_model_definition(capability)
    if definition.status != "available":
        raise RuntimeError(
            f"PlantCare capability '{capability}' is not available yet."
        )

    model_path, classes_path = resolve_artifact_paths(definition)
    model_file = ROOT / model_path
    classes_file = ROOT / classes_path

    if not model_file.exists():
        raise RuntimeError(f"Model artifact not found: {model_file}")
    if not classes_file.exists():
        raise RuntimeError(f"Class names file not found: {classes_file}")

    classes = [
        line.strip()
        for line in classes_file.read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]

    if (
        definition.expected_class_count is not None
        and len(classes) != definition.expected_class_count
    ):
        raise RuntimeError(
            "Invalid PlantCare class configuration: "
            f"expected {definition.expected_class_count} classes, "
            f"found {len(classes)}."
        )

    if len(set(classes)) != len(classes):
        raise RuntimeError(
            "Invalid PlantCare class configuration: duplicate class names found."
        )

    model = build_model(len(classes), pretrained=False).to(_device)

    try:
        state = torch.load(model_file, map_location=_device)
        model.load_state_dict(state)
    except Exception as exc:
        raise RuntimeError(
            "Model artifact is incompatible with the configured "
            f"{len(classes)}-class MobileNetV3 architecture."
        ) from exc

    model.eval()
    _classes[capability] = classes
    _models[capability] = model


@app.on_event("startup")
def startup():
    load_model("disease")


@app.get("/health")
def health():
    if "disease" not in _models or "disease" not in _classes:
        raise HTTPException(status_code=503, detail="Disease model is not ready.")

    available = sorted(_models)
    return {
        "status": "ok",
        "device": str(_device),
        "available_capabilities": available,
        "models": [
            {
                "capability": capability,
                "classes": len(_classes[capability]),
                "model_id": get_model_definition(capability).model_id,
                "model_version": get_model_definition(capability).version,
            }
            for capability in available
        ],
    }


@app.get("/models")
def models():
    return {"models": model_summary()}


@app.post("/predict")
async def predict(
    image: UploadFile = File(...),
    plant_hint: str | None = Form(default=None),
    capability: str = Form(default="disease"),
):
    try:
        definition = get_model_definition(capability)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc

    if definition.status != "available":
        raise HTTPException(
            status_code=501,
            detail=(
                f"The '{definition.capability}' capability is planned but "
                "not available in the current inference deployment."
            ),
        )

    if capability not in _models or capability not in _classes:
        try:
            load_model(capability)
        except RuntimeError as exc:
            raise HTTPException(status_code=503, detail=str(exc)) from exc

    model = _models[capability]
    classes = _classes[capability]

    if image.content_type not in {"image/jpeg", "image/png", "image/webp"}:
        raise HTTPException(
            status_code=415,
            detail="Only JPEG, PNG and WebP images are supported.",
        )

    data = await image.read()
    if not data:
        raise HTTPException(status_code=400, detail="Empty image.")

    try:
        with Image.open(io.BytesIO(data)) as source:
            pil_image = source.convert("RGB")
        tensor = transform(pil_image).unsqueeze(0).to(_device)
    except Exception as exc:
        raise HTTPException(status_code=400, detail="Invalid image.") from exc

    with torch.inference_mode():
        probabilities = torch.softmax(model(tensor), dim=1)[0]
        values, indices = torch.topk(
            probabilities,
            k=min(5, len(classes)),
        )

    confidence = float(values[0])
    predicted = classes[int(indices[0])]
    parts = predicted.split("___", 1)
    plant_name = parts[0].replace("_", " ")
    condition = parts[1].replace("_", " ") if len(parts) == 2 else predicted

    needs_expert_review = confidence < LOW_CONFIDENCE_THRESHOLD
    explanation = (
        "The model confidence is below the review threshold. "
        "Use a clearer image or seek agricultural verification."
        if needs_expert_review
        else (
            "PlantCare AI identified the most likely class from the "
            f"{definition.display_name} model."
        )
    )

    return {
        "schema_version": "1.1",
        "capability": definition.capability,
        "model_id": definition.model_id,
        "model_version": definition.version,
        "plant_name": plant_name,
        "condition": condition,
        "confidence": confidence,
        "explanation": explanation,
        "needs_expert_review": needs_expert_review,
        "plant_hint": plant_hint,
        "top_predictions": [
            {
                "class": classes[int(index)],
                "confidence": float(value),
            }
            for value, index in zip(values, indices)
        ],
    }
