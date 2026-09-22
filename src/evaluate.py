from pathlib import Path
import sys
import numpy as np
import torch
from torch.utils.data import DataLoader
from datasets import load_dataset
from sklearn.metrics import accuracy_score, precision_recall_fscore_support, classification_report, confusion_matrix
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from config import DATASET_NAME, DATASET_REVISION, IMAGE_SIZE, BATCH_SIZE, NUM_WORKERS, MODEL_PATH, CLASS_NAMES_PATH
from src.data import HFImageDataset, rows_from_dataset
from src.model import build_model

DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")

def main():
    classes = [x.strip() for x in (ROOT / CLASS_NAMES_PATH).read_text(encoding="utf-8").splitlines() if x.strip()]
    dataset = load_dataset(DATASET_NAME, revision=DATASET_REVISION, split="train")
    test_ds = dataset.filter(lambda x: x["split"] == "test")
    rows = rows_from_dataset(test_ds, {name: i for i, name in enumerate(classes)})
    loader = DataLoader(
        HFImageDataset(rows, IMAGE_SIZE),
        batch_size=BATCH_SIZE,
        shuffle=False,
        num_workers=NUM_WORKERS,
    )

    model = build_model(len(classes)).to(DEVICE)
    model.load_state_dict(torch.load(ROOT / MODEL_PATH, map_location=DEVICE))
    model.eval()

    y_true, y_pred = [], []
    with torch.inference_mode():
        for x, y in loader:
            out = model(x.to(DEVICE))
            y_pred.extend(out.argmax(1).cpu().numpy().tolist())
            y_true.extend(y.numpy().tolist())

    acc = accuracy_score(y_true, y_pred)
    precision, recall, f1, _ = precision_recall_fscore_support(
        y_true, y_pred, average="weighted", zero_division=0
    )
    report = classification_report(
        y_true, y_pred, target_names=classes, digits=4, zero_division=0
    )
    cm = confusion_matrix(y_true, y_pred)

    outdir = ROOT / "outputs"
    outdir.mkdir(exist_ok=True)
    (outdir / "classification_report.txt").write_text(
        f"Device: {DEVICE}\nTest samples: {len(y_true)}\n"
        f"Accuracy: {acc:.4f}\nWeighted Precision: {precision:.4f}\n"
        f"Weighted Recall: {recall:.4f}\nWeighted F1: {f1:.4f}\n\n{report}",
        encoding="utf-8",
    )
    np.savetxt(outdir / "confusion_matrix.csv", cm, fmt="%d", delimiter=",")

    fig, ax = plt.subplots(figsize=(14, 12))
    im = ax.imshow(cm)
    ax.set_title("Plant Disease Detection - Confusion Matrix")
    ax.set_xlabel("Predicted class")
    ax.set_ylabel("True class")
    ax.set_xticks(range(len(classes)), classes, rotation=90, fontsize=7)
    ax.set_yticks(range(len(classes)), classes, fontsize=7)
    fig.colorbar(im, ax=ax)
    fig.tight_layout()
    fig.savefig(outdir / "confusion_matrix.png", dpi=220)
    plt.close(fig)

    print(f"Device: {DEVICE}")
    print(f"Test samples: {len(y_true)}")
    print(f"Accuracy: {acc:.4f}")
    print(f"Weighted Precision: {precision:.4f}")
    print(f"Weighted Recall: {recall:.4f}")
    print(f"Weighted F1: {f1:.4f}")
    print(f"Saved results to: {outdir}")

if __name__ == "__main__":
    main()
