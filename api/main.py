import os
from pathlib import Path

import torch
from fastapi import FastAPI, File, Form, HTTPException, UploadFile
from PIL import Image
from torchvision import transforms

from config import CLASS_NAMES_PATH, IMAGE_SIZE, MODEL_PATH
from src.model import build_model

ROOT = Path(__file__).resolve().parents[1]
MODEL_FILE = ROOT / os.getenv("PLANTCARE_MODEL_PATH", MODEL_PATH)
CLASSES_FILE = ROOT / os.getenv("PLANTCARE_CLASSES_PATH", CLASS_NAMES_PATH)
LOW_CONFIDENCE_THRESHOLD = float(
    os.getenv("PLANTCARE_LOW_CONFIDENCE_THRESHOLD", "0.60")
)

app = FastAPI(
    title="PlantCare AI Inference API",
    version="0.1.0",
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

_model = None
_classes = None
_device = torch.device("cuda" if torch.cuda.is_available() else "cpu")


def load_artifacts():
    global _model, _classes

    if not MODEL_FILE.exists():
        raise RuntimeError(f"Model artifact not found: {MODEL_FILE}")
    if not CLASSES_FILE.exists():
        raise RuntimeError(f"Class names file not found: {CLASSES_FILE}")

    _classes = [
        line.strip()
        for line in CLASSES_FILE.read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]
    _model = build_model(len(_classes)).to(_device)
    state = torch.load(MODEL_FILE, map_location=_device)
    _model.load_state_dict(state)
    _model.eval()


@app.on_event("startup")
def startup():
    load_artifacts()


@app.get("/health")
def health():
    return {
        "status": "ok",
        "model": "MobileNetV3-Large",
        "classes": len(_classes or []),
        "device": str(_device),
    }


@app.post("/predict")
async def predict(
    image: UploadFile = File(...),
    plant_hint: str | None = Form(default=None),
):
    if _model is None or _classes is None:
        raise HTTPException(status_code=503, detail="Model is not ready.")

    if image.content_type not in {"image/jpeg", "image/png", "image/webp"}:
        raise HTTPException(
            status_code=415,
            detail="Only JPEG, PNG and WebP images are supported.",
        )

    data = await image.read()
    if not data:
        raise HTTPException(status_code=400, detail="Empty image.")

    try:
        with Image.open(__import__("io").BytesIO(data)) as source:
            pil_image = source.convert("RGB")
        tensor = transform(pil_image).unsqueeze(0).to(_device)
    except Exception as exc:
        raise HTTPException(status_code=400, detail="Invalid image.") from exc

    with torch.inference_mode():
        probabilities = torch.softmax(_model(tensor), dim=1)[0]
        values, indices = torch.topk(
            probabilities,
            k=min(5, len(_classes)),
        )

    confidence = float(values[0])
    predicted = _classes[int(indices[0])]
    parts = predicted.split("___", 1)
    plant_name = parts[0].replace("_", " ")
    condition = parts[1].replace("_", " ") if len(parts) == 2 else predicted

    needs_expert_review = confidence < LOW_CONFIDENCE_THRESHOLD
    explanation = (
        "The model confidence is below the review threshold. "
        "Use a clearer image or seek agricultural verification."
        if needs_expert_review
        else "PlantCare AI identified the most likely class from the evaluated PlantVillage model."
    )

    return {
        "plant_name": plant_name,
        "condition": condition,
        "confidence": confidence,
        "explanation": explanation,
        "needs_expert_review": needs_expert_review,
        "plant_hint": plant_hint,
        "model_version": "plantvillage-mobilenetv3-38-class",
        "top_predictions": [
            {
                "class": _classes[int(index)],
                "confidence": float(value),
            }
            for value, index in zip(values, indices)
        ],
    }
