# Plant Disease Detection Using CNN

An end-to-end AI mini-project that classifies plant leaf images into disease categories using **PyTorch + MobileNetV3-Large transfer learning** and exposes the trained model through a **Streamlit** application.

## Project stack

- Python 3.12
- PyTorch + Torchvision
- MobileNetV3-Large
- Hugging Face Datasets
- Scikit-learn
- Matplotlib
- Streamlit
- GitHub for source control
- Notion for project documentation and tracking
- Figma is reserved for the final UI/UX design-reference stage after the technical projects are completed

## Dataset

The project uses the curated Hugging Face dataset:

`geraldmc/plantvillage-full`

Dataset characteristics used by this project:

- 54,304 images
- 38 disease/healthy classes
- RGB leaf images
- The dataset provides an explicit `split` metadata field
- The project filters that field into training and test subsets
- Test set used for the final evaluation: **10,948 images**

The training configuration caps the number of images per class at 300 for the completed mini-project experiment.

## Model

The classifier uses **MobileNetV3-Large** with ImageNet-pretrained weights. The final classifier layer is replaced with a 38-class output layer.

Training configuration:

| Parameter | Value |
|---|---:|
| Input size | 224 × 224 |
| Batch size | 32 |
| Epochs | 10 |
| Learning rate | 3e-4 |
| Optimizer | AdamW |
| Loss | Cross Entropy |
| Device | NVIDIA RTX 5060 Laptop GPU (CUDA) |
| Classes | 38 |

## Final test results

The final evaluation was performed on the held-out test set of 10,948 images.

| Metric | Result |
|---|---:|
| Accuracy | **98.72%** |
| Weighted Precision | **98.75%** |
| Weighted Recall | **98.72%** |
| Weighted F1-score | **98.72%** |

Evaluation artifacts are generated under `outputs/` when `src/evaluate.py` is run.

## Project pipeline

`Leaf Image → Resize/Normalize → MobileNetV3-Large → Class Probabilities → Predicted Disease → Streamlit Result`

The Streamlit application also displays the top-5 predicted classes and their confidence values.

## Repository structure

```text
plant-disease-detection-cnn/
├── app.py
├── config.py
├── requirements.txt
├── TRAINING_GUIDE.md
├── ACADEMIC_MATERIALS/
│   ├── ppt_outline.md
│   ├── report_outline.md
│   └── viva_questions.md
├── src/
│   ├── data.py
│   ├── evaluate.py
│   ├── model.py
│   └── train.py
├── artifacts/              # generated locally; model files are not committed
└── outputs/                # generated locally during evaluation
```

## Setup

From the repository root:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

For the verified local setup, Python 3.12.10, PyTorch 2.11.0+cu128 and torchvision 0.26.0+cu128 were used with CUDA available on the RTX 5060 Laptop GPU.

## Train

Run from the repository root so that `config.py` and `src/` resolve correctly:

```powershell
$env:PYTHONPATH="."
.\.venv\Scripts\python.exe src\train.py
```

The best validation model is written to:

`artifacts/plant_disease_mobilenetv3.pth`

and the class mapping is written to:

`artifacts/class_names.txt`

## Evaluate

```powershell
$env:PYTHONPATH="."
.\.venv\Scripts\python.exe src\evaluate.py
```

This creates:

- `outputs/classification_report.txt`
- `outputs/confusion_matrix.csv`
- `outputs/confusion_matrix.png`

## Run the Streamlit app

After training has produced the model artifact:

```powershell
.\.venv\Scripts\streamlit.exe run app.py
```

Then upload a JPG, JPEG or PNG leaf image.

The application:

1. Loads the trained MobileNetV3 model.
2. Applies the same image preprocessing used by the model.
3. Produces class probabilities.
4. Displays the predicted class and confidence.
5. Displays the top-5 predictions.
6. Shows an educational-use disclaimer.

## Important interpretation note

A prediction from a user-uploaded image is an AI classification result, not a medical/agricultural diagnosis. Confidence is the model's probability estimate over its trained classes and should not be treated as certainty, especially for images outside the training distribution.

## Completed technical work

- [x] Dataset integration and split handling
- [x] MobileNetV3-Large transfer-learning model
- [x] GPU training on RTX 5060
- [x] Model training
- [x] Held-out test evaluation
- [x] Classification report and confusion matrix generation
- [x] Streamlit inference application
- [x] GitHub source repository
- [x] Academic PPT/report/viva outlines
- [x] Local end-to-end demo verification
- [ ] Final Figma UI/UX design reference — intentionally deferred until both mini-projects are technically complete

## Academic use

This repository is structured for an AI & Data Science mini-project and can support the project report, presentation and viva. Use the measured test metrics above rather than validation metrics when reporting final model performance.
