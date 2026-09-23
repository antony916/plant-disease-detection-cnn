from pathlib import Path
import sys
import time
import json
import urllib.parse
import urllib.request

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

DISEASE_GUIDANCE.update({
    "Apple___healthy": {
        "summary": "No disease pattern was identified by the model for this class.",
        "management": ["Continue routine monitoring.", "Maintain good airflow and plant hygiene.", "If symptoms appear later, capture a clear image and reassess."],
        "search": "apple healthy plant care extension",
    },
    "Tomato___healthy": {
        "summary": "No disease pattern was identified by the model for this class.",
        "management": ["Continue routine monitoring.", "Maintain good airflow and avoid prolonged leaf wetness.", "Reassess if new spots, wilting, or discoloration appear."],
        "search": "tomato healthy plant care extension",
    },
    "Potato___healthy": {
        "summary": "No disease pattern was identified by the model for this class.",
        "management": ["Continue routine monitoring.", "Maintain good crop hygiene and airflow.", "Reassess if visible disease symptoms develop."],
        "search": "potato healthy plant care extension",
    },
    "Corn_(maize)___healthy": {
        "summary": "No disease pattern was identified by the model for this class.",
        "management": ["Continue routine monitoring.", "Maintain appropriate crop nutrition and field hygiene.", "Reassess if visible symptoms develop."],
        "search": "corn healthy crop care extension",
    },
    "Grape___Black_rot": {
        "summary": "A fungal disease that can affect grape leaves and fruit.",
        "management": ["Remove infected fruit and plant debris where practical.", "Improve canopy airflow.", "Avoid prolonged leaf wetness.", "Use only locally approved products according to label and agricultural guidance."],
        "search": "grape black rot management extension",
    },
    "Grape___Esca_(Black_Measles)": {
        "summary": "A grapevine disease complex associated with leaf and fruit symptoms.",
        "management": ["Remove severely affected plant material where appropriate.", "Maintain vineyard sanitation and monitor affected vines.", "Consult local viticulture extension guidance for management options."],
        "search": "grape esca black measles management extension",
    },
    "Grape___Leaf_blight_(Isariopsis_Leaf_Spot)": {
        "summary": "A fungal leaf disease that can cause spotting and premature leaf loss.",
        "management": ["Remove affected debris where practical.", "Improve canopy airflow.", "Avoid unnecessary leaf wetting.", "Follow local extension guidance for approved control products."],
        "search": "grape leaf blight Isariopsis management extension",
    },
    "Tomato___Bacterial_spot": {
        "summary": "A bacterial disease that can cause dark spots on leaves and fruit.",
        "management": ["Avoid working with plants when foliage is wet.", "Remove severely affected material where practical.", "Use clean seed and plant material when available.", "Follow local extension guidance for management products."],
        "search": "tomato bacterial spot management extension",
    },
    "Tomato___Septoria_leaf_spot": {
        "summary": "A fungal leaf-spot disease that can cause numerous small lesions and leaf drop.",
        "management": ["Remove affected lower leaves where practical.", "Avoid overhead irrigation.", "Improve airflow and remove plant debris.", "Follow local extension guidance for approved control products."],
        "search": "tomato Septoria leaf spot management extension",
    },
    "Tomato___Leaf_Mold": {
        "summary": "A fungal disease favored by high humidity and poor air circulation.",
        "management": ["Increase ventilation and canopy airflow.", "Avoid prolonged leaf wetness.", "Remove severely affected leaves where practical.", "Follow local extension guidance for approved control products."],
        "search": "tomato leaf mold management extension",
    },
    "Pepper,_bell___Bacterial_spot": {
        "summary": "A bacterial disease that can affect pepper leaves and fruit.",
        "management": ["Avoid handling plants while wet.", "Remove severely affected material where practical.", "Use clean planting material and maintain field sanitation.", "Follow local extension guidance for management."],
        "search": "pepper bacterial spot management extension",
    },
    "Peach___Bacterial_spot": {
        "summary": "A bacterial disease that can affect peach leaves and fruit.",
        "management": ["Remove affected material where practical.", "Maintain good canopy airflow.", "Avoid prolonged wetness.", "Follow local extension guidance for approved management options."],
        "search": "peach bacterial spot management extension",
    },
})

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




def fetch_nearby_places(location, query):
    """Fetch nearby place results using OpenStreetMap's public search service."""
    params = urllib.parse.urlencode({
        "q": f"{query}, {location}",
        "format": "jsonv2",
        "limit": 8,
        "addressdetails": 1,
    })
    url = "https://nominatim.openstreetmap.org/search?" + params
    request = urllib.request.Request(
        url,
        headers={"User-Agent": "PlantDiseaseDetection/1.0 educational project"},
    )
    with urllib.request.urlopen(request, timeout=10) as response:
        return json.loads(response.read().decode("utf-8"))


def render_resource_cards():
    st.markdown('<div class="section-title">Trusted agricultural resources</div>', unsafe_allow_html=True)
    resources = [
        ("🇮🇳 Kisan Call Centre", "Agricultural support in local languages", "1800-180-1551"),
        ("🌱 Tamil Nadu Horticulture", "Official state horticulture department contacts", "Government resource"),
        ("👨‍🌾 Agricultural extension", "Connect with qualified agricultural professionals", "Expert support"),
    ]
    for title, description, detail in resources:
        st.markdown(
            f"""
            <div class="result-card" style="margin-bottom:0.8rem;">
                <div class="result-name">{title}</div>
                <div style="margin-top:0.35rem;">{description}</div>
                <div class="result-label" style="margin-top:0.6rem;">{detail}</div>
            </div>
            """,
            unsafe_allow_html=True,
        )


def render_internal_page(page):
    if page == "🩺 Disease Details":
        st.markdown('<div class="hero"><h1>🩺 Disease Details</h1><p>Understand the AI result and recommended next steps.</p></div>', unsafe_allow_html=True)
        prediction = st.session_state.get("prediction")
        confidence = st.session_state.get("confidence")
        if not prediction:
            st.info("Upload a leaf image in Detection first to view disease-specific details.")
            return
        guidance = get_guidance(prediction)
        st.markdown(f"### {display_class_name(prediction)}")
        if confidence is not None:
            st.metric("AI confidence", f"{confidence:.2f}%")
        st.markdown(f'<div class="info-card"><b>Overview:</b> {guidance["summary"]}</div>', unsafe_allow_html=True)
        st.markdown("### Management")
        for item in guidance["management"]:
            st.markdown(f"- {item}")
        st.warning("AI screening is not a confirmed diagnosis. Verify important treatment decisions with a qualified agricultural professional.")

    elif page == "💊 Treatment & Products":
        st.markdown('<div class="hero"><h1>💊 Treatment & Products</h1><p>General management information and safer product guidance.</p></div>', unsafe_allow_html=True)
        prediction = st.session_state.get("prediction")
        if prediction:
            guidance = get_guidance(prediction)
            st.markdown(f"### For: {display_class_name(prediction)}")
            for item in guidance["management"]:
                st.markdown(f"- {item}")
        st.info("We do not provide AI-generated pesticide dosages. Use only products legally approved for the crop and disease in your area, and follow the product label and agricultural extension advice.")
        st.markdown("### What to check before buying a product")
        for item in [
            "Crop and disease listed on the product label",
            "Registration/approval applicable in your area",
            "Label directions, precautions and application instructions",
            "Advice from a qualified agricultural professional when symptoms are severe",
        ]:
            st.markdown(f"- {item}")
        st.markdown("### Product information")
        st.write("Enter a crop, disease or product name to research it:")
        term = st.text_input("Search term", placeholder="Example: tomato early blight")
        if term.strip():
            query = urllib.parse.quote_plus(term + " agriculture disease management")
            st.markdown(f"🔎 [Open agricultural information search](https://www.google.com/search?q={query})")

    elif page == "📍 Nearby Agri Shops":
        st.markdown('<div class="hero"><h1>📍 Nearby Agri Shops</h1><p>Find agriculture-related businesses around a location.</p></div>', unsafe_allow_html=True)
        location = st.text_input("Enter town, district or PIN code", placeholder="Example: Chennai, Tamil Nadu")
        shop_type = st.selectbox("What are you looking for?", ["Agricultural shop", "Nursery", "Seed store", "Fertilizer store"])
        if st.button("🔎 Find nearby", type="primary") and location.strip():
            try:
                results = fetch_nearby_places(location.strip(), shop_type)
                if not results:
                    st.warning("No matching places were returned for this location.")
                for place in results:
                    name = place.get("display_name", "Unnamed place").split(",")[0]
                    address = place.get("display_name", "Address unavailable")
                    lat, lon = place.get("lat"), place.get("lon")
                    st.markdown(
                        f"""
                        <div class="result-card" style="margin-bottom:0.8rem;">
                            <div class="result-name">{name}</div>
                            <div style="margin-top:0.4rem;">{address}</div>
                            <div style="margin-top:0.6rem;">
                                <a href="https://www.google.com/maps/search/?api=1&query={lat},{lon}" target="_blank">📍 Open location in Maps</a>
                            </div>
                        </div>
                        """,
                        unsafe_allow_html=True,
                    )
            except Exception as exc:
                st.error(f"Could not fetch nearby places right now: {exc}")

    elif page == "👨‍🌾 Agricultural Experts":
        st.markdown('<div class="hero"><h1>👨‍🌾 Agricultural Experts</h1><p>Verified agricultural support and official contacts.</p></div>', unsafe_allow_html=True)
        st.markdown("### 🇮🇳 Kisan Call Centre")
        st.markdown('<div class="info-card"><b>1800-180-1551</b><br>Government agricultural support available in local languages.</div>', unsafe_allow_html=True)
        st.markdown("### 🌱 Tamil Nadu Horticulture")
        st.write("Official district horticulture contacts can be used to reach the appropriate agricultural office.")
        st.link_button("Open Tamil Nadu Horticulture contacts", "https://www.tnhorticulture.tn.gov.in/administration-details")
        st.markdown("### When to seek expert help")
        for item in ["Symptoms are spreading quickly", "The AI confidence is low", "The crop has significant damage", "You are considering a chemical treatment"]:
            st.markdown(f"- {item}")

    elif page == "📚 Resources":
        st.markdown('<div class="hero"><h1>📚 Agriculture Resources</h1><p>Useful official and educational resources.</p></div>', unsafe_allow_html=True)
        render_resource_cards()
        st.link_button("🇮🇳 Kisan Call Centre information", "https://www.dackkms.gov.in/Account/aboutus.aspx")
        st.link_button("🌱 Tamil Nadu Horticulture Department", "https://www.tnhorticulture.tn.gov.in/administration-details")

    elif page == "💬 Expert Help":
        st.markdown('<div class="hero"><h1>💬 Expert Help</h1><p>Get human verification when the AI result is uncertain.</p></div>', unsafe_allow_html=True)
        st.markdown("### Kisan Call Centre")
        st.markdown("**1800-180-1551**")
        st.write("Government agricultural support is available through the Kisan Call Centre.")
        st.link_button("Open official Kisan Call Centre", "https://www.dackkms.gov.in/Account/aboutus.aspx")
        st.markdown("### Tamil Nadu")
        st.write("For Tamil Nadu users, the state Horticulture Department publishes district contacts.")
        st.link_button("Find district horticulture contacts", "https://www.tnhorticulture.tn.gov.in/administration-details")


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


# Internal pages render inside the same Streamlit application.
if selected_page != "🌿 Detection":
    render_internal_page(selected_page)
    st.markdown('<div class="footer">Plant Disease Detection • AI Agriculture Assistance</div>', unsafe_allow_html=True)
    st.stop()

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
    st.markdown("### Navigate")
    selected_page = st.radio(
        "Open page",
        [
            "🌿 Detection",
            "🩺 Disease Details",
            "💊 Treatment & Products",
            "📍 Nearby Agri Shops",
            "👨‍🌾 Agricultural Experts",
            "📚 Resources",
            "💬 Expert Help",
        ],
        label_visibility="collapsed",
    )

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
        st.session_state["prediction"] = prediction
        st.session_state["confidence"] = confidence

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
