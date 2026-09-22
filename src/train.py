import os, torch
from torch import nn
from torch.utils.data import DataLoader
from datasets import load_dataset
from config import *
from src.model import build_model
from src.data import HFImageDataset, make_label_map, rows_from_dataset

def run_epoch(model, loader, loss_fn, opt, device, training):
    model.train(training); total=correct=0; loss_sum=0.0
    for x,y in loader:
        x,y=x.to(device),y.to(device)
        if training: opt.zero_grad()
        out=model(x); loss=loss_fn(out,y)
        if training: loss.backward(); opt.step()
        loss_sum += loss.item()*len(y); correct += (out.argmax(1)==y).sum().item(); total += len(y)
    return loss_sum/total, correct/total

def main():
    os.makedirs(ARTIFACT_DIR,exist_ok=True)
    # The curated PlantVillage release has one HF "train" split.
    # Its train/test assignment is stored in the "split" metadata column.
    dataset=load_dataset(DATASET_NAME,revision=DATASET_REVISION,split="train")
    train_ds=dataset.filter(lambda x: x["split"]=="train")
    test_ds=dataset.filter(lambda x: x["split"]=="test")
    label_map,names=make_label_map(train_ds)
    open(CLASS_NAMES_PATH,"w",encoding="utf-8").write("\n".join(names))
    rows=rows_from_dataset(train_ds,label_map,MAX_IMAGES_PER_CLASS)
    test_rows=rows_from_dataset(test_ds,label_map)
    cut=int(.9*len(rows)); tr_rows,va_rows=rows[:cut],rows[cut:]
    train_dl=DataLoader(HFImageDataset(tr_rows,IMAGE_SIZE,True),BATCH_SIZE,shuffle=True,num_workers=NUM_WORKERS)
    val_dl=DataLoader(HFImageDataset(va_rows,IMAGE_SIZE),BATCH_SIZE,num_workers=NUM_WORKERS)
    test_dl=DataLoader(HFImageDataset(test_rows,IMAGE_SIZE),BATCH_SIZE,num_workers=NUM_WORKERS)
    device="cuda" if torch.cuda.is_available() else "cpu"
    print("Device:",device)
    if device=="cuda": print("GPU:",torch.cuda.get_device_name(0))
    model=build_model(len(names)).to(device)
    opt=torch.optim.AdamW(model.parameters(),lr=LEARNING_RATE); loss=nn.CrossEntropyLoss(); best=0.0
    for e in range(EPOCHS):
        _,ta=run_epoch(model,train_dl,loss,opt,device,True); _,va=run_epoch(model,val_dl,loss,opt,device,False)
        print(f"Epoch {e+1}/{EPOCHS} train={ta:.4f} val={va:.4f}")
        if va>best: best=va; torch.save(model.state_dict(),MODEL_PATH)
    model.load_state_dict(torch.load(MODEL_PATH,map_location=device)); _,test_acc=run_epoch(model,test_dl,loss,opt,device,False)
    print("Test accuracy:",test_acc); print("Model:",MODEL_PATH)

if __name__=="__main__": main()
