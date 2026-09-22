import os,torch
from torch import nn
from torch.utils.data import DataLoader
from datasets import load_dataset
from config import *
from src.model import build_model
from src.data import HFImageDataset,split_rows

def run_epoch(model,loader,loss_fn,opt,device,training):
    model.train(training); total=correct=0; loss_sum=0
    for x,y in loader:
        x,y=x.to(device),y.to(device)
        if training: opt.zero_grad()
        out=model(x); loss=loss_fn(out,y)
        if training: loss.backward(); opt.step()
        loss_sum+=loss.item()*len(y); correct+=(out.argmax(1)==y).sum().item(); total+=len(y)
    return loss_sum/total,correct/total

def main():
    os.makedirs(ARTIFACT_DIR,exist_ok=True)
    ds=load_dataset(DATASET_NAME,DATASET_CONFIG,split="train")
    names=ds.features["label"].names
    open(CLASS_NAMES_PATH,"w",encoding="utf-8").write("\n".join(names))
    tr,va,te=split_rows(ds,MAX_IMAGES_PER_CLASS)
    train_dl=DataLoader(HFImageDataset(tr,IMAGE_SIZE,True),BATCH_SIZE,shuffle=True,num_workers=NUM_WORKERS)
    val_dl=DataLoader(HFImageDataset(va,IMAGE_SIZE),BATCH_SIZE,num_workers=NUM_WORKERS)
    test_dl=DataLoader(HFImageDataset(te,IMAGE_SIZE),BATCH_SIZE,num_workers=NUM_WORKERS)
    device="cuda" if torch.cuda.is_available() else "cpu"; model=build_model(len(names)).to(device)
    opt=torch.optim.AdamW(model.parameters(),lr=LEARNING_RATE); loss=nn.CrossEntropyLoss(); best=0
    for e in range(EPOCHS):
        _,ta=run_epoch(model,train_dl,loss,opt,device,True); _,va_acc=run_epoch(model,val_dl,loss,opt,device,False)
        print(f"Epoch {e+1}/{EPOCHS} train={ta:.4f} val={va_acc:.4f}")
        if va_acc>best: best=va_acc; torch.save(model.state_dict(),MODEL_PATH)
    model.load_state_dict(torch.load(MODEL_PATH,map_location=device)); _,test_acc=run_epoch(model,test_dl,loss,opt,device,False)
    print("Test accuracy:",test_acc); print("Model:",MODEL_PATH)

if __name__=="__main__": main()
