from pathlib import Path
import sys

import streamlit as st
import torch
from PIL import Image
from torchvision import transforms

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT))

from config import IMAGE_SIZE, MODEL_PATH, CLASS_NAMES_PATH
from src.model import build_model


st.set_page_config(
    page_title="Plant Disease Detection",
    page_icon="🌿",
    layout="wide",
    initial_sidebar_state="expanded",
)

# -----------------------------
# Custom UI
# -----------------------------
st.markdown(
    """
    <style>
        .stApp {
            background: #f7faf8;
        }

        [data-testid="stHeader"] {
            background: rgba(247, 250, 248, 0.92);
        }

        .block-container {
            max-width: 1180px;
            padding-top: 2rem;
            padding-bottom: 3rem;
        }

        .hero {
            background: linear-gradient(135deg, #0f5132 0%, #198754 100%);
            padding: 2.2rem 2.4rem;
            border-radius: 22px;
            color: white;
            margin-bottom: 1.5rem;
            box-shadow: 0 10px 30px rgba(15, 81, 50, 0.14);
        }

        .hero h1 {
            margin: 0;
            font-size: 2.25rem;
            font-weight: 750;
            letter-spacing: -0.5px;
        }

        .hero p {
            margin: 0.55rem 0 0;
            opacity: 0.9;
            font-size: 1rem;
        }

        .section-title {
            font-size: 1.2rem;
            font-weight: 700;
            color: #18352a;
            margin: 1.1rem 0 0.65rem;
        }

        .upload-card {
            background: white;
            border: 1px solid #dce9e1;
            border-radius: 18px;
            padding: 1.2rem;
            box-shadow: 0 5px 20px rgba(28, 58, 43, 0.06);
        }

        .result-card {
            background: white;
            border: 1px solid #d9e8df;
            border-radius: 18px;
            padding: 1.35rem 1.5rem;
            box-shadow: 0 5px 20px rgba(28, 58, 43, 0.06);
        }

        .result-label {
            color: #6b7d73;
            font-size: 0.82rem;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            font-weight: 700;
        }

        .result-name {
            color: #123b29;
            font-size: 1.38rem;
            font-weight: 750;
            margin-top: 0.25rem;
            line-height: 1.3;
            overflow-wrap: anywhere;
        }

        .confidence {
            color: #198754;
            font-size: 1.9rem;
            font-weight: 800;
            margin-top: 0.15rem;
        }

        .info-card {
            background: #eef8f2;
            border: 1px solid #cfe7d9;
            border-radius: 16px;
            padding: 1rem 1.1rem;
            color: #244b38;
        }

        .warning-card {
            background: #fff8e8;
            border: 1px solid #f2dfad;
            border-radius: 16px;
            padding: 1rem 1.1rem;
            color: #66501f;
        }

        .footer {
            text-align: center;
            color: #718078;
            font-size: 0.82rem;
            padding-top: 2rem;
        }

        div[data-testid="stFileUploader"] {
            background: #ffffff;
            border: 2px dashed #b8d7c5;
            border-radius: 16px;
            padding: 0.5rem;
        }

        div[data-testid="stMetric"] {
            background: #ffffff;
            border: 1px solid #dce9e1;
            border-radius: 14px;
            padding: 0.75rem;
        }

        [data-testid="stSidebar"] {
            background: #edf5f0;
        }

        [data-testid="stSidebar"] * {
            color: #173b2b !important;
        }

        [data-testid="stSidebar"] [data-testid="stMarkdownContainer"] p {
            color: #315343 !important;
        }

        [data-testid="stSidebar"] hr {
            border-color: #cfe0d6;
        }

        [data-testid="stFileUploader"] section {
            background: #ffffff !important;
            border: 0 !important;
        }

        [data-testid="stFileUploader"] section > div {
            background: #ffffff !important;
        }

        [data-testid="stFileUploader"] small {
            color: #61736a !important;
        }

        [data-testid="stFileUploader"] label {
            color: #294c3b !important;
        }

        [data-testid="stFileUploader"] button {
            background: #0f5132 !important;
            color: #ffffff !important;
            border: 1px solid #0f5132 !important;
        }

        [data-testid="stFileUploader"] button:hover {
            background: #198754 !important;
            color: #ffffff !important;
            border-color: #198754 !important;
        }
        
        /* Dark-mode support */
        @media (prefers-color-scheme: dark) {
            .stApp {
                background: #0e1712;
            }

            [data-testid="stHeader"] {
                background: rgba(14, 23, 18, 0.92);
            }

            .section-title {
                color: #e7f4ec !important;
            }

            .upload-card,
            .result-card,
            div[data-testid="stMetric"] {
                background: #17231c !important;
                border-color: #30463a !important;
                color: #e7f4ec !important;
            }

            .result-label {
                color: #a9beb1 !important;
            }

            .result-name {
                color: #dff5e7 !important;
                font-size: 1.38rem;
                overflow-wrap: anywhere;
            }

            .confidence {
                color: #62d394 !important;
            }

            .info-card {
                background: #173426 !important;
                border-color: #2c6247 !important;
                color: #d9f0e1 !important;
            }

            .warning-card {
                background: #3a3018 !important;
                border-color: #665622 !important;
                color: #f4e8b5 !important;
            }

            [data-testid="stSidebar"] {
                background: #111c16 !important;
                border-right: 1px solid #2b3e33;
            }

            [data-testid="stSidebar"] * {
                color: #e6f3eb !important;
            }

            [data-testid="stSidebar"] [data-testid="stMarkdownContainer"] p,
            [data-testid="stSidebar"] small {
                color: #b7cbbf !important;
            }

            [data-testid="stSidebar"] hr {
                border-color: #2d4437 !important;
            }

            div[data-testid="stFileUploader"] {
                background: #17231c !important;
                border-color: #4d8065 !important;
            }

            [data-testid="stFileUploader"] section,
            [data-testid="stFileUploader"] section > div {
                background: #17231c !important;
                color: #e7f4ec !important;
            }

            [data-testid="stFileUploader"] label,
            [data-testid="stFileUploader"] small {
                color: #c6d8ce !important;
            }

            [data-testid="stFileUploader"] button {
                background: #198754 !important;
                color: #ffffff !important;
                border-color: #198754 !important;
            }

            [data-testid="stFileUploader"] button:hover {
                background: #2aa96b !important;
                border-color: #2aa96b !important;
            }

            .footer {
                color: #8fa79a !important;
            }

            [data-testid="stMetric"] label,
            [data-testid="stMetric"] [data-testid="stMetricValue"] {
                color: #e7f4ec !important;
            }
        }

    </style>
    """,
    unsafe_allow_html=True,
)


# -----------------------------
# Model
# -----------------------------
@st.cache_resource
def get_model():
    classes = [
        x.strip()
        for x in (ROOT / CLASS_NAMES_PATH)
        .read_text(encoding="utf-8")
        .splitlines()
        if x.strip()
    ]

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    model = build_model(len(classes)).to(device)
    model.load_state_dict(torch.load(ROOT / MODEL_PATH, map_location=device))
    model.eval()

    return model, classes, device


def display_class_name(name):
    """Convert dataset class labels into a presentation-friendly name."""
    return name.replace("___", " — ").replace("_", " ")


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


# -----------------------------
# Header
# -----------------------------
st.markdown(
    """
    <div class="hero">
        <h1>🌿 Plant Disease Detection</h1>
        <p>AI-powered leaf image classification using PyTorch and MobileNetV3-Large.</p>
    </div>
    """,
    unsafe_allow_html=True,
)


# -----------------------------
# Sidebar
# -----------------------------
with st.sidebar:
    st.markdown("## 🌱 Plant AI")
    st.caption("CNN-based plant disease screening")

    st.markdown("---")
    st.markdown("### Model")
    st.write("**Architecture:** MobileNetV3-Large")
    st.write("**Framework:** PyTorch")
    st.write(f"**Input:** {IMAGE_SIZE} × {IMAGE_SIZE}")
    st.write("**Classes:** 38")

    st.markdown("---")
    st.markdown("### System")
    device_name = "NVIDIA GPU" if torch.cuda.is_available() else "CPU"
    st.write(f"**Inference device:** {device_name}")

    st.markdown("---")
    st.caption(
        "This application is an educational AI prototype. "
        "Predictions should be reviewed by a qualified agricultural professional."
    )


# -----------------------------
# Upload area
# -----------------------------
st.markdown('<div class="section-title">1. Upload a leaf image</div>', unsafe_allow_html=True)

uploaded = st.file_uploader(
    "Choose a clear plant leaf image",
    type=["jpg", "jpeg", "png"],
    help="For best results, use a well-lit image where the leaf is clearly visible.",
)

if not uploaded:
    st.markdown(
        """
        <div class="info-card">
            <b>How it works</b><br>
            Upload a leaf image → the CNN processes the image → the model
            predicts the most likely plant disease class → the app displays
            the confidence and top predictions.
        </div>
        """,
        unsafe_allow_html=True,
    )
else:
    image = Image.open(uploaded).convert("RGB")

    left, right = st.columns([1, 1], gap="large")

    with left:
        st.markdown('<div class="section-title">2. Uploaded image</div>', unsafe_allow_html=True)
        st.image(image, caption="Leaf image", use_container_width=True)

    with right:
        st.markdown('<div class="section-title">3. AI analysis</div>', unsafe_allow_html=True)

        with st.spinner("Analyzing the leaf with MobileNetV3..."):
            model, classes, device = get_model()
            x = transform(image).unsqueeze(0).to(device)

            with torch.inference_mode():
                probs = torch.softmax(model(x), dim=1)[0]
                values, indices = torch.topk(probs, k=min(5, len(classes)))

        top_idx = int(indices[0])
        prediction = classes[top_idx]
        prediction_display = display_class_name(prediction)
        confidence = float(values[0]) * 100

        st.markdown(
            f"""
            <div class="result-card">
                <div class="result-label">Predicted class</div>
                <div class="result-name">{prediction_display}</div>
                <div class="result-label" style="margin-top:0.9rem;">Confidence</div>
                <div class="confidence">{confidence:.2f}%</div>
            </div>
            """,
            unsafe_allow_html=True,
        )

        if confidence >= 80:
            st.success("High-confidence model prediction.")
        elif confidence >= 60:
            st.info("Moderate-confidence prediction. Review the image and result carefully.")
        else:
            st.warning("Low-confidence prediction. A clearer image or expert verification is recommended.")

    # -----------------------------
    # Top predictions
    # -----------------------------
    st.markdown('<div class="section-title">Top 5 model predictions</div>', unsafe_allow_html=True)

    for rank, (score, idx) in enumerate(zip(values.tolist(), indices.tolist()), start=1):
        col1, col2 = st.columns([4, 1])

        with col1:
            st.write(f"**{rank}. {display_class_name(classes[idx])}**")
            st.progress(float(score))

        with col2:
            st.metric("Score", f"{score * 100:.2f}%")

    # -----------------------------
    # Guidance
    # -----------------------------
    st.markdown('<div class="section-title">Interpretation</div>', unsafe_allow_html=True)

    st.markdown(
        """
        <div class="warning-card">
            <b>Important:</b> This result is an AI-based screening output,
            not a confirmed agricultural diagnosis. Image quality, lighting,
            leaf condition, and differences between real-world images and
            training data can affect predictions.
        </div>
        """,
        unsafe_allow_html=True,
    )

    st.markdown(
        """
        <div class="info-card" style="margin-top:0.8rem;">
            <b>Recommended next step:</b> Use the prediction as an initial
            screening result and verify the condition with a qualified
            agricultural professional before taking treatment decisions.
        </div>
        """,
        unsafe_allow_html=True,
    )


st.markdown(
    '<div class="footer">Plant Disease Detection • PyTorch + MobileNetV3-Large • Streamlit</div>',
    unsafe_allow_html=True,
)
