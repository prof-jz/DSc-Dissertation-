# GPU Golden Path — PyTorch on Ubuntu

## Purpose
Deterministic, GPU-enabled PyTorch setup on Ubuntu with modern NVIDIA GPUs.

## Golden Path
```bash
conda create -n hai-torch-gpu python=3.12 pip -y
conda activate hai-torch-gpu

pip install --upgrade pip
pip install --index-url https://download.pytorch.org/whl/cu128 torch torchvision torchaudio
pip install numpy pandas scipy scikit-learn joblib matplotlib jupyterlab ipykernel
```

## Validation
```python
import torch
print(torch.cuda.is_available())
print(torch.cuda.get_device_name(0))
```
