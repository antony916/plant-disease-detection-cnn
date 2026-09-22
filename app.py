import os,torch,streamlit as st
from PIL import Image
from torchvision import transforms
from src.model import build_model
st.set_page_config(page_title="Plant Disease Detection",page_icon="🌿"); st.title("🌿 Plant Disease Detection Using CNN")
MODEL="artifacts/plant_disease_mobilenetv3.pth"; CLASSES="artifacts/class_names.txt"
if not os.path.exists(MODEL): st.warning("Train first: python src/train.py"); st.stop()
names=open(CLASSES,encoding="utf-8").read().splitlines(); dev="cuda" if torch.cuda.is_available() else "cpu"
model=build_model(len(names)); model.load_state_dict(torch.load(MODEL,map_location=dev)); model.to(dev); model.eval()
tf=transforms.Compose([transforms.Resize((224,224)),transforms.ToTensor(),transforms.Normalize([.485,.456,.406],[.229,.224,.225])])
f=st.file_uploader("Upload a leaf image",type=["jpg","jpeg","png"])
if f:
    im=Image.open(f).convert("RGB"); st.image(im,caption="Uploaded leaf",use_container_width=True)
    with torch.no_grad(): p=torch.softmax(model(tf(im).unsqueeze(0).to(dev)),1)[0]
    v,i=torch.topk(p,3); st.success(f"{names[i[0].item()]} — {v[0].item()*100:.2f}%")
    for score,idx in zip(v,i): st.write(f"{names[idx.item()]}: {score.item()*100:.2f}%")
    st.caption("AI screening aid; confirm important diagnoses with an agricultural expert.")
