# Plant Disease Detection Using CNN

Complete AI mini-project for plant disease classification from leaf images.

## Stack
Python, PyTorch, Torchvision, Hugging Face Datasets, MobileNetV3-Large transfer learning and Streamlit.

## Dataset
Hugging Face: `mohanty/PlantVillage` using the color configuration.

## Run
```bash
pip install -r requirements.txt
python src/train.py
streamlit run app.py
```

The initial experiment limits each class to 300 images. Set `MAX_IMAGES_PER_CLASS=None` in `config.py` for the full training set. Model weights are generated after training.
