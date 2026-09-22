from collections import defaultdict
import random
from torch.utils.data import Dataset
from torchvision import transforms

class HFImageDataset(Dataset):
    def __init__(self,rows,image_size=224,train=False):
        self.rows=rows
        ops=[transforms.Resize((image_size,image_size))]
        if train: ops += [transforms.RandomHorizontalFlip(),transforms.RandomRotation(12),transforms.ColorJitter(.15,.15,.15,.05)]
        ops += [transforms.ToTensor(),transforms.Normalize([.485,.456,.406],[.229,.224,.225])]
        self.transform=transforms.Compose(ops)
    def __len__(self): return len(self.rows)
    def __getitem__(self,i):
        image,label=self.rows[i]
        return self.transform(image.convert("RGB")),label

def split_rows(dataset,max_per_class=None,seed=42):
    rows=[(x["image"],int(x["label"])) for x in dataset]
    if max_per_class:
        buckets=defaultdict(list)
        for r in rows: buckets[r[1]].append(r)
        rng=random.Random(seed); rows=[]
        for items in buckets.values(): rng.shuffle(items); rows.extend(items[:max_per_class])
    random.Random(seed).shuffle(rows)
    n=len(rows); a=int(.8*n); b=int(.9*n)
    return rows[:a],rows[a:b],rows[b:]
