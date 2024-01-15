#!/bin/bash 
echo "update system..."
sudo apt update -y && sudo apt upgrade -y
echo "install python3-dev build-essential git"
sudo apt install python3-dev build-essential git -y

echo "check rocm"
AMD_ROCM="amdgpu-install_5.6.50600-1_all.deb"
if [ -d "$AMD_ROCM" ]; then
  echo "update rocm"
else
  echo "install rocm"
  wget https://repo.radeon.com/amdgpu-install/5.6/ubuntu/jammy/amdgpu-install_5.6.50600-1_all.deb
  sudo apt install ./amdgpu-install_5.6.50600-1_all.deb
fi

sudo amdgpu-install --usecase=rocm
  
echo "git clone stable-diffusion-webui"
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
echo "create python venv"
cd stable-diffusion-webui
VENV_DIR="venv"
if [ -d "$VENV_DIR" ]; then
  echo "activate python virtual machine"
else
  echo "${VENV_DIR} not found. create python virtual machine"
  python -m venv venv
fi

echo "source venv/bin/activate && pip list"
source venv/bin/activate && pip list
echo "pip install rocm"
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm5.6
echo "pip install -r requirements.txt"
pip install -r requirements.txt
MAGIC_MODEL="models/Stable-diffusion/majicmixRealistic_v7.safetensors"
if test -f "$MAGIC_MODEL"; then
  echo "majicmixRealistic_v7.safetensors exist"
else
  echo "${MAGIC_MODEL} not found. create python virtual download model"
  
wget -O models/Stable-diffusion/majicmixRealistic_v7.safetensors https://civitai.com/api/download/models/176425 
fi
echo "start"
gnome-terminal -- watch rocm-smi
HSA_OVERRIDE_GFX_VERSION=10.3.0 ./webui.sh --listen --lowvram
