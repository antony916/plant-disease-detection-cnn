from pathlib import Path
import sys
import time

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

        .confidence-note {
            border-radius: 14px;
            padding: 0.8rem 1rem;
            margin-top: 0.8rem;
            font-size: 0.92rem;
            line-height: 1.45;
            font-weight: 600;
        }

        .confidence-high {
            background: #123b29;
            border: 1px solid #2f8057;
            color: #bdeecf;
        }

        .confidence-medium {
            background: #173426;
            border: 1px solid #3c7455;
            color: #bfe8ce;
        }

        .confidence-low {
            background: #3a3018;
            border: 1px solid #665622;
            color: #f4e8b5;
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


DISEASE_GUIDANCE = {
    "Apple___Apple_scab": {
        "summary": "A fungal disease commonly associated with dark olive-to-brown lesions on leaves and fruit.",
        "management": ["Remove badly affected fallen leaves and fruit where practical.", "Improve airflow by pruning and avoid prolonged leaf wetness.", "Use locally approved fungicide products only according to the product label and agricultural guidance."],
        "search": "Apple scab management extension",
    },
    "Apple___Black_rot": {
        "summary": "A fungal disease that can affect leaves, fruit, and woody tissue.",
        "management": ["Remove and dispose of visibly infected plant material.", "Prune affected dead wood with clean tools.", "Maintain good orchard sanitation and airflow.", "Use only locally approved products according to label directions."],
        "search": "Apple black rot management extension",
    },
    "Apple___Cedar_apple_rust": {
        "summary": "A fungal disease that can produce yellow-orange leaf symptoms and fruit infection.",
        "management": ["Remove heavily affected plant material where practical.", "Maintain good airflow around the canopy.", "Follow local agricultural extension guidance for approved fungicide programs."],
        "search": "Cedar apple rust management extension",
    },
    "Tomato___Late_blight": {
        "summary": "A serious disease that can spread rapidly under cool, wet conditions.",
        "management": ["Remove severely affected leaves and fruit where practical.", "Avoid overhead irrigation and reduce prolonged leaf wetness.", "Separate affected plants from healthy plants when feasible.", "Use only locally approved products following the label and expert guidance."],
        "search": "tomato late blight management extension",
    },
    "Tomato___Early_blight": {
        "summary": "A fungal disease that commonly causes dark concentric leaf spots and progressive leaf loss.",
        "management": ["Remove severely affected lower leaves.", "Water at soil level and avoid wetting foliage.", "Improve airflow and remove plant debris.", "Follow local extension guidance for approved disease-control products."],
        "search": "tomato early blight management extension",
    },
    "Potato___Early_blight": {
        "summary": "A fungal disease that commonly produces dark target-like lesions on potato foliage.",
        "management": ["Remove infected debris after harvest.", "Maintain balanced plant nutrition and avoid prolonged leaf wetness.", "Use crop rotation where practical.", "Use approved products only according to local label guidance."],
        "search": "potato early blight management extension",
    },
    "Potato___Late_blight": {
        "summary": "A destructive disease favored by cool, wet conditions.",
        "management": ["Remove severely affected foliage and tubers where practical.", "Avoid overhead irrigation and prolonged leaf wetness.", "Separate affected material from healthy crops.", "Follow local agricultural extension recommendations for control products."],
        "search": "potato late blight management extension",
    },
    "Corn_(maize)___Common_rust_": {
        "summary": "A fungal rust disease that produces reddish-brown pustules on leaves.",
        "management": ["Monitor new growth for expanding rust symptoms.", "Choose locally recommended resistant varieties when available.", "Maintain good crop management and follow local extension advice for severe outbreaks."],
        "search": "corn common rust management extension",
    },
}

def get_guidance(prediction):
    """Return general management guidance for a predicted disease."""
    if prediction in DISEASE_GUIDANCE:
        return DISEASE_GUIDANCE[prediction]
    return {
        "summary": "The model identified a disease class, but a class-specific management note is not included in this prototype yet.",
        "management": [
            "Take a clear second image and compare the result with the plant's visible symptoms.",
            "Remove severely affected material only when appropriate for the crop.",
            "Consult a qualified agricultural professional before treatment decisions.",
        ],
        "search": f"{display_class_name(prediction)} plant disease management extension",
    }


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

        # Visible analysis animation. This runs again whenever a new image is uploaded.
        progress = st.progress(0)
        status_text = st.empty()

        status_text.markdown("🔍 **Checking the uploaded image...**")
        progress.progress(15)
        time.sleep(0.35)

        status_text.markdown("🧹 **Preprocessing the leaf image...**")
        progress.progress(35)
        time.sleep(0.35)

        model, classes, device = get_model()
        x = transform(image).unsqueeze(0).to(device)
        progress.progress(55)

        status_text.markdown("🧠 **Analyzing disease patterns with MobileNetV3...**")
        progress.progress(70)

        with torch.inference_mode():
            probs = torch.softmax(model(x), dim=1)[0]
            values, indices = torch.topk(probs, k=min(5, len(classes)))

        progress.progress(90)
        status_text.markdown("📊 **Preparing prediction results...**")
        time.sleep(0.35)

        progress.progress(100)
        status_text.success("✅ **Analysis complete**")

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
            confidence_message = "High-confidence model prediction."
            confidence_class = "confidence-high"
        elif confidence >= 60:
            confidence_message = "Moderate-confidence prediction. Review the image and result carefully."
            confidence_class = "confidence-medium"
        else:
            confidence_message = "Low-confidence prediction. A clearer image or expert verification is recommended."
            confidence_class = "confidence-low"

        st.markdown(
            f'<div class="confidence-note {confidence_class}">{confidence_message}</div>',
            unsafe_allow_html=True,
        )

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

    guidance = get_guidance(prediction)

    st.markdown('<div class="section-title">Disease management</div>', unsafe_allow_html=True)
    st.markdown(
        f'<div class="info-card"><b>What it means:</b> {guidance["summary"]}</div>',
        unsafe_allow_html=True,
    )

    for item in guidance["management"]:
        st.markdown(f"- {item}")

    st.markdown('<div class="section-title">Treatment & product information</div>', unsafe_allow_html=True)
    st.info(
        "For treatment products, use only products legally approved for your crop and disease in your area. "
        "Check the product label and local agricultural extension advice rather than relying on an AI dosage recommendation."
    )

    search_query = guidance["search"].replace(" ", "+")
    st.markdown(
        f'🔎 [Find trusted management guidance online](https://www.google.com/search?q={search_query})'
    )

    st.markdown('<div class="section-title">Find nearby agricultural help</div>', unsafe_allow_html=True)
    help_area = st.text_input(
        "Enter your town / district to find nearby agricultural shops or consultants",
        placeholder="Example: Chennai, Tamil Nadu",
        key="help_area",
    )
    if help_area.strip():
        maps_query = help_area.strip().replace(" ", "+")
        st.markdown(
            f'📍 [Agricultural shops near {help_area}](https://www.google.com/maps/search/agricultural+shop+{maps_query})'
        )
        st.markdown(
            f'👨‍🌾 [Agricultural consultants / plant clinics near {help_area}](https://www.google.com/maps/search/agricultural+consultant+{maps_query})'
        )
        st.markdown(
            f'🛒 [Search agricultural products near {help_area}](https://www.google.com/search?q=agricultural+products+{maps_query})'
        )

    st.markdown('<div class="section-title">Consult an expert</div>', unsafe_allow_html=True)
    st.markdown(
        "If symptoms are severe, spreading quickly, or the confidence is low, "
        "share the plant image and model result with a qualified agricultural professional."
    )
    st.markdown(
        "💬 [Find an agricultural professional / plant clinic](https://www.google.com/search?q=agricultural+extension+plant+clinic)"
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
