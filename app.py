from pathlib import Path
import sys
import torch
import streamlit as st
from PIL import Image
from torchvision import transforms

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT))

from config import IMAGE_SIZE, MODEL_PATH, CLASS_NAMES_PATH
from src.model import build_model

st.set_page_config(page_title="Plant Disease Detection", page_icon="🌿", layout="centered")

@st.cache_resource
def get_model():
    classes = [x.strip() for x in (ROOT / CLASS_NAMES_PATH).read_text(encoding="utf-8").splitlines() if x.strip()]
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model = build_model(len(classes)).to(device)
    model.load_state_dict(torch.load(ROOT / MODEL_PATH, map_location=device))
    model.eval()
    return model, classes, device

transform = transforms.Compose([
    transforms.Resize((IMAGE_SIZE, IMAGE_SIZE)),
    transforms.ToTensor(),
    transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
])

st.title("🌿 Plant Disease Detection")
st.caption("MobileNetV3-Large • CNN-based image classification")

uploaded = st.file_uploader("Upload a clear plant leaf image", type=["jpg", "jpeg", "png"])

if uploaded:
    image = Image.open(uploaded).convert("RGB")
    st.image(image, caption="Uploaded leaf", use_container_width=True)

    with st.spinner("Analyzing leaf..."):
        model, classes, device = get_model()
        x = transform(image).unsqueeze(0).to(device)
        with torch.inference_mode():
            probs = torch.softmax(model(x), dim=1)[0]
            values, indices = torch.topk(probs, k=min(5, len(classes)))

    top_idx = int(indices[0])
    st.success(f"Prediction: {classes[top_idx]}")
    st.metric("Confidence", f"{float(values[0]) * 100:.2f}%")

    st.subheader("Top predictions")
    for score, idx in zip(values.tolist(), indices.tolist()):
        st.write(f"**{classes[idx]}** — {score * 100:.2f}%")
        st.progress(float(score))

    st.info(
        "Educational prototype: the prediction is an AI screening result and "
        "should not replace professional agricultural diagnosis."
    )
else:
    st.write("Upload a leaf image to begin.")
