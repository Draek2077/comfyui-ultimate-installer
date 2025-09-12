@echo off
setlocal enabledelayedexpansion

:: =============================================================================
:: Draekz Ultimate ComfyUI Installation Wizard
:: =============================================================================
:: This script provides a comprehensive toolkit for installing and managing
:: a portable ComfyUI instance, including custom nodes, models, and performance
:: enhancements like Triton and Sage Attention.
::
:: Version: 3.0.0 (Size Estimation Update)
:: =============================================================================

:: -----------------------------------------------------------------------------
:: Section 1: Initial Setup and Configuration
:: -----------------------------------------------------------------------------
title Draekz Ultimate ComfyUI Installation Wizard

:: Color setup for a better user interface
for /f "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "ESC=%%b"
set "RESET=!ESC![0m"
set "BLUE=!ESC![94m"
set "WHITE=!ESC![97m"
set "GREEN=!ESC![92m"
set "YELLOW=!ESC![93m"
set "PURPLE=!ESC![95m"
set "RED=!ESC![91m"

:: --- Last Action Message Initialization ---
set "LAST_ACTION_MSG=!GREEN!Welcome, please select an option to begin.!RESET!"

:: --- Status Flags for UI Checkmarks ---
set "STATUS_COMFYUI=0"
set "STATUS_MODELS=0"
set "STATUS_NODES=0"
set "STATUS_TRITON=0"
set "STATUS_LIBS=0"
set "SELECTED_QUALITY_NAME=None"

:: --- Size Calculation Variables ---
set "SIZE_COMFYUI_GB=6.5"
set "SIZE_MODELS_GB=0.0"
set "SIZE_TOTAL_GB=0.0"

:: --- Model Selection Flags ---
for /l %%G in (1,1,99) do (
    set "num=0%%G" & set "num=!num:~-2!"
    set "SELECT_MODEL_!num!=0"
)

:: --- Toggles Options ---
set "INSTALL_SERVER_MANAGER=1" :: Set to 1 to install, 0 to skip
set "INSTALL_CLIENT_WRAPPER=1" :: Set to 1 to install, 0 to skip

:: --- Core Configuration ---
set "COMFYUI_DIR=ComfyUI_windows_portable"
set "CUSTOM_NODES_DIR=%COMFYUI_DIR%\ComfyUI\custom_nodes"
set "MODELS_DIR=%COMFYUI_DIR%\ComfyUI\models"
set "PYTHON_EXE=%CD%\%COMFYUI_DIR%\python_embeded\python.exe"
set "COMFY_VER=0.3.49"
set "GIT_VER=2.45.0.windows.1"
set "SEVEN_VER=22.01"

:: --- Download URLs ---
set "COMFY_RELEASE_URL=https://github.com/comfyanonymous/ComfyUI/releases/download/v%COMFY_VER%/ComfyUI_windows_portable_nvidia.7z"
set "HF_BASE_URL=https://huggingface.co/Aitrepreneur"
set "HF_FLX_URL=%HF_BASE_URL%/FLX/resolve/main"
set "SERVER_MANAGER_URL=https://github.com/Draek2077/comfyui-server-manager/releases/download/v1.0.1/ComfyUIServerManagerInstaller.msi"
set "SERVER_MANAGER_MSI_NAME=ComfyUIServerManagerInstaller.msi"
set "CLIENT_WRAPPER_URL=https://github.com/Draek2077/comfyui-client-wrapper/releases/download/v1.0.1/ComfyUIClientWrapperInstaller.msi"
set "CLIENT_WRAPPER_MSI_NAME=ComfyUIClientWrapperInstaller.msi"

:: --- Model Catalog Configuration ---
:: To add/change models, edit this section. The menus will update automatically.
:: ---
:: For each option, define NAME, FILE, TYPE, and a full direct download URL.
:: ---
:: Model 1: FLUXDev
set "MODEL_01_NAME=FLUX-Dev"
set "MODEL_01_OPT_1_NAME=Q4_K_S (GGUF, <12GB VRAM)"       & set "MODEL_01_OPT_1_FILE=flux1-dev-Q4_K_S.gguf"     & set "MODEL_01_OPT_1_TYPE=gguf_flux"       & set "MODEL_01_OPT_1_URL=%HF_FLX_URL%/flux1-dev-Q4_K_S.gguf"
set "MODEL_01_OPT_2_NAME=Q5_K_S (GGUF, 12-16GB VRAM)"     & set "MODEL_01_OPT_2_FILE=flux1-dev-Q5_K_S.gguf"     & set "MODEL_01_OPT_2_TYPE=gguf_flux"       & set "MODEL_01_OPT_2_URL=%HF_FLX_URL%/flux1-dev-Q5_K_S.gguf"
set "MODEL_01_OPT_3_NAME=Q6_K   (GGUF, ~16GB VRAM)"       & set "MODEL_01_OPT_3_FILE=flux1-dev-Q6_K.gguf"       & set "MODEL_01_OPT_3_TYPE=gguf_flux"       & set "MODEL_01_OPT_3_URL=https://huggingface.co/city96/FLUX.1-dev-gguf/resolve/main/flux1-dev-Q6_K.gguf?download=true"
set "MODEL_01_OPT_4_NAME=Q8_0   (GGUF, >16GB VRAM)"       & set "MODEL_01_OPT_4_FILE=flux1-dev-Q8_0.gguf"       & set "MODEL_01_OPT_4_TYPE=gguf_flux"       & set "MODEL_01_OPT_4_URL=%HF_FLX_URL%/flux1-dev-Q8_0.gguf"
set "MODEL_01_OPT_5_NAME=FP8    (Safetensor, >24GB VRAM)" & set "MODEL_01_OPT_5_FILE=flux1-dev-fp8.safetensors" & set "MODEL_01_OPT_5_TYPE=diffusion_model" & set "MODEL_01_OPT_5_URL=%HF_FLX_URL%/flux1-dev-fp8.safetensors"
set "MODEL_01_OPT_6_NAME=FP16   (Safetensor, >32GB VRAM)" & set "MODEL_01_OPT_6_FILE=flux1-dev.safetensors"             & set "MODEL_01_OPT_6_TYPE=diffusion_model" & set "MODEL_01_OPT_6_URL=%HF_FLX_URL%/flux1-dev.sft"
:: Model 2: FLUXFillDev
set "MODEL_02_NAME=FLUX-Fill-Dev"
set "MODEL_02_OPT_1_NAME=Q4_K_S (GGUF, <12GB VRAM)"       & set "MODEL_02_OPT_1_FILE=flux1-fill-dev-Q4_K_S.gguf"     & set "MODEL_02_OPT_1_TYPE=gguf_flux"       & set "MODEL_02_OPT_1_URL=%HF_FLX_URL%/flux1-fill-dev-Q4_K_S.gguf"
set "MODEL_02_OPT_2_NAME=Q5_K_S (GGUF, 12-16GB VRAM)"     & set "MODEL_02_OPT_2_FILE=flux1-fill-dev-Q5_K_S.gguf"     & set "MODEL_02_OPT_2_TYPE=gguf_flux"       & set "MODEL_02_OPT_2_URL=%HF_FLX_URL%/flux1-fill-dev-Q5_K_S.gguf"
set "MODEL_02_OPT_3_NAME=Q6     (GGUF, ~16GB VRAM)"       & set "MODEL_02_OPT_3_FILE=flux1-fill-dev-Q5_K_S.gguf"     & set "MODEL_02_OPT_3_TYPE=gguf_flux"       & set "MODEL_02_OPT_3_URL=%HF_FLX_URL%/flux1-fill-dev-Q5_K_S.gguf"
set "MODEL_02_OPT_4_NAME=Q8_0   (GGUF, >16GB VRAM)"       & set "MODEL_02_OPT_4_FILE=flux1-fill-dev-Q8_0.gguf"       & set "MODEL_02_OPT_4_TYPE=gguf_flux"       & set "MODEL_02_OPT_4_URL=%HF_FLX_URL%/flux1-fill-dev-Q8_0.gguf"
set "MODEL_02_OPT_5_NAME=FP8    (Safetensor, >24GB VRAM)" & set "MODEL_02_OPT_5_FILE=flux1-fill-dev_fp8.safetensors" & set "MODEL_02_OPT_5_TYPE=diffusion_model" & set "MODEL_02_OPT_5_URL=%HF_FLX_URL%/flux1-fill-dev_fp8.safetensors"
:: Model 3: FLUXSchnell
set "MODEL_03_NAME=FLUX-Schnell"
set "MODEL_03_OPT_1_NAME=Q4_K_S (GGUF, <12GB VRAM)"        & set "MODEL_03_OPT_1_FILE=flux1-schnell-Q4_K_S.gguf"     & set "MODEL_03_OPT_1_TYPE=gguf" & set "MODEL_03_OPT_1_URL=%HF_FLX_URL%/flux1-schnell-Q4_K_S.gguf"
set "MODEL_03_OPT_2_NAME=Q5_K_S (GGUF, 12-16GB VRAM)"      & set "MODEL_03_OPT_2_FILE=flux1-schnell-Q5_K_S.gguf"     & set "MODEL_03_OPT_2_TYPE=gguf" & set "MODEL_03_OPT_2_URL=%HF_FLX_URL%/flux1-schnell-Q5_K_S.gguf"
set "MODEL_03_OPT_3_NAME=Q6_K   (GGUF, ~16GB VRAM)"        & set "MODEL_03_OPT_3_FILE=flux1-schnell-Q6_K.gguf"       & set "MODEL_03_OPT_3_TYPE=gguf" & set "MODEL_03_OPT_3_URL=https://huggingface.co/city96/FLUX.1-schnell-gguf/resolve/main/flux1-schnell-Q6_K.gguf?download=true"
set "MODEL_03_OPT_4_NAME=Q8_0   (GGUF, >16GB VRAM)"        & set "MODEL_03_OPT_4_FILE=flux1-schnell-Q8_0.gguf"       & set "MODEL_03_OPT_4_TYPE=gguf" & set "MODEL_03_OPT_4_URL=%HF_FLX_URL%/flux1-schnell-Q8_0.gguf"
set "MODEL_03_OPT_5_NAME=FP8    (Safetensors, >24GB VRAM)" & set "MODEL_03_OPT_5_FILE=flux1-schnell-fp8.safetensors" & set "MODEL_03_OPT_5_TYPE=diffusion_model" & set "MODEL_03_OPT_5_URL=%HF_FLX_URL%/flux1-schnell-fp8.safetensors"
set "MODEL_03_OPT_6_NAME=FP16   (Safetensors, >32GB VRAM)" & set "MODEL_03_OPT_6_FILE=flux1-schnell.safetensors"     & set "MODEL_03_OPT_6_TYPE=diffusion_model" & set "MODEL_03_OPT_6_URL=https://huggingface.co/OlafCC/flux1-schnell.safetensors/resolve/main/flux1-schnell.safetensors?download=true"
:: Model 4: FLUX Kontext
set "MODEL_04_NAME=FLUX-Kontext"
set "MODEL_04_OPT_1_NAME=Q4_K_S (GGUF, <12GB VRAM)"       & set "MODEL_04_OPT_1_FILE=flux1-kontext-dev-Q4_K_S.gguf"            & set "MODEL_04_OPT_1_TYPE=gguf" & set "MODEL_04_OPT_1_URL=%HF_FLX_URL%/flux1-kontext-dev-Q4_K_S.gguf"
set "MODEL_04_OPT_2_NAME=Q5_K_S (GGUF, 12-24GB VRAM)"     & set "MODEL_04_OPT_2_FILE=flux1-kontext-dev-Q5_K_S.gguf"            & set "MODEL_04_OPT_2_TYPE=gguf" & set "MODEL_04_OPT_2_URL=%HF_FLX_URL%/flux1-kontext-dev-Q5_K_S.gguf"
set "MODEL_04_OPT_3_NAME=Q6_K   (GGUF, ~24GB VRAM)"       & set "MODEL_04_OPT_3_FILE=flux1-kontext-dev-Q6_K.gguf"              & set "MODEL_04_OPT_3_TYPE=gguf" & set "MODEL_04_OPT_3_URL=https://huggingface.co/QuantStack/FLUX.1-Kontext-dev-GGUF/resolve/main/flux1-kontext-dev-Q6_K.gguf?download=true"
set "MODEL_04_OPT_4_NAME=Q8_0   (GGUF, >24GB VRAM)"       & set "MODEL_04_OPT_4_FILE=flux1-kontext-dev-Q8_0.gguf"              & set "MODEL_04_OPT_4_TYPE=gguf" & set "MODEL_04_OPT_4_URL=%HF_FLX_URL%/flux1-kontext-dev-Q8_0.gguf"
set "MODEL_04_OPT_5_NAME=FP8    (Safetensor, >24GB VRAM)" & set "MODEL_04_OPT_5_FILE=flux1-kontext-dev-fp8-e4m3fn.safetensors" & set "MODEL_04_OPT_5_TYPE=diffusion_model" & set "MODEL_04_OPT_5_URL=%HF_FLX_URL%/flux1-kontext-dev-fp8-e4m3fn.safetensors"
:: Model 5: Qwen Image
set "MODEL_05_NAME=Qwen-Image"
set "MODEL_05_OPT_1_NAME=Q4_K_S (GGUF, <12GB VRAM)"       & set "MODEL_05_OPT_1_FILE=Qwen_Image_Distill-Q4_K_S.gguf"    & set "MODEL_05_OPT_1_TYPE=gguf" & set "MODEL_05_OPT_1_URL=%HF_FLX_URL%/Qwen_Image_Distill-Q4_K_S.gguf"
set "MODEL_05_OPT_2_NAME=Q5_K_S (GGUF, 12-24GB VRAM)"     & set "MODEL_05_OPT_2_FILE=Qwen_Image_Distill-Q5_K_S.gguf"    & set "MODEL_05_OPT_2_TYPE=gguf" & set "MODEL_05_OPT_2_URL=%HF_FLX_URL%/Qwen_Image_Distill-Q5_K_S.gguf"
set "MODEL_05_OPT_3_NAME=Q6_K   (GGUF, ~24GB VRAM)"       & set "MODEL_05_OPT_3_FILE=Qwen_Image_Distill-Q6_K.gguf"      & set "MODEL_05_OPT_3_TYPE=gguf" & set "MODEL_05_OPT_3_URL=https://huggingface.co/QuantStack/Qwen-Image-Distill-GGUF/resolve/main/Qwen_Image_Distill-Q6_K.gguf?download=true"
set "MODEL_05_OPT_4_NAME=Q8_0   (GGUF, >24GB VRAM)"       & set "MODEL_05_OPT_4_FILE=Qwen_Image_Distill-Q8_0.gguf"      & set "MODEL_05_OPT_4_TYPE=gguf" & set "MODEL_05_OPT_4_URL=%HF_FLX_URL%/Qwen_Image_Distill-Q8_0.gguf"
set "MODEL_05_OPT_5_NAME=FP8    (Safetensor, >24GB VRAM)" & set "MODEL_05_OPT_5_FILE=qwen_image_fp8_e4m3fn.safetensors" & set "MODEL_05_OPT_5_TYPE=diffusion_model" & set "MODEL_05_OPT_5_URL=https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/diffusion_models/qwen_image_fp8_e4m3fn.safetensors?download=true"
set "MODEL_05_OPT_6_NAME=BF16   (Safetensor, >32GB VRAM)" & set "MODEL_05_OPT_6_FILE=qwen_image_bf16.safetensors"       & set "MODEL_05_OPT_6_TYPE=diffusion_model" & set "MODEL_05_OPT_6_URL=https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/diffusion_models/qwen_image_bf16.safetensors?download=true"
:: Model 6: Qwen Edit
set "MODEL_06_NAME=Qwen-Edit"
set "MODEL_06_OPT_1_NAME=Q4_K_S (GGUF, <12GB VRAM)"       & set "MODEL_06_OPT_1_FILE=Qwen_Image_Edit-Q4_K_S.gguf"            & set "MODEL_06_OPT_1_TYPE=gguf" & set "MODEL_06_OPT_1_URL=%HF_FLX_URL%/Qwen_Image_Edit-Q4_K_S.gguf"
set "MODEL_06_OPT_2_NAME=Q5_K_S (GGUF, 12-24GB VRAM)"     & set "MODEL_06_OPT_2_FILE=Qwen_Image_Edit-Q5_K_S.gguf"            & set "MODEL_06_OPT_2_TYPE=gguf" & set "MODEL_06_OPT_2_URL=%HF_FLX_URL%/Qwen_Image_Edit-Q5_K_S.gguf"
set "MODEL_06_OPT_3_NAME=Q6_K   (GGUF, ~24GB VRAM)"       & set "MODEL_06_OPT_3_FILE=Qwen_Image_Edit-Q6_K.gguf"              & set "MODEL_06_OPT_3_TYPE=gguf" & set "MODEL_06_OPT_3_URL=https://huggingface.co/QuantStack/Qwen-Image-Edit-GGUF/resolve/main/Qwen_Image_Edit-Q6_K.gguf?download=true"
set "MODEL_06_OPT_4_NAME=Q8_0   (GGUF, >24GB VRAM)"       & set "MODEL_06_OPT_4_FILE=Qwen_Image_Edit-Q8_0.gguf"              & set "MODEL_06_OPT_4_TYPE=gguf" & set "MODEL_06_OPT_4_URL=%HF_FLX_URL%/Qwen_Image_Edit-Q8_0.gguf"
set "MODEL_06_OPT_5_NAME=FP8    (Safetensor, >24GB VRAM)" & set "MODEL_06_OPT_5_FILE=qwen_image_edit_fp8_e4m3fn.safetensors" & set "MODEL_06_OPT_5_TYPE=diffusion_model" & set "MODEL_06_OPT_5_URL=https://huggingface.co/Comfy-Org/Qwen-Image-Edit_ComfyUI/resolve/main/split_files/diffusion_models/qwen_image_edit_fp8_e4m3fn.safetensors?download=true"
set "MODEL_06_OPT_6_NAME=BF16   (Safetensor, >32GB VRAM)" & set "MODEL_06_OPT_6_FILE=qwen_image_edit_bf16.safetensors"       & set "MODEL_06_OPT_6_TYPE=diffusion_model" & set "MODEL_06_OPT_6_URL=https://huggingface.co/Comfy-Org/Qwen-Image-Edit_ComfyUI/resolve/main/split_files/diffusion_models/qwen_image_edit_bf16.safetensors?download=true"
:: Model 7: HiDream
set "MODEL_07_NAME=HiDream"
set "MODEL_07_OPT_1_NAME=Q4_K_S (GGUF, <12GB VRAM)"       & set "MODEL_07_OPT_1_FILE=hidream-i1-dev-Q4_K_S.gguf"      & set "MODEL_07_OPT_1_TYPE=gguf" & set "MODEL_07_OPT_1_URL=%HF_FLX_URL%/hidream-i1-dev-Q4_K_S.gguf"
set "MODEL_07_OPT_2_NAME=Q5_K_S (GGUF, 12-16GB VRAM)"     & set "MODEL_07_OPT_2_FILE=hidream-i1-dev-Q5_K_S.gguf"      & set "MODEL_07_OPT_2_TYPE=gguf" & set "MODEL_07_OPT_2_URL=%HF_FLX_URL%/hidream-i1-dev-Q5_K_S.gguf"
set "MODEL_07_OPT_3_NAME=Q6_K   (GGUF, ~16GB VRAM)"       & set "MODEL_07_OPT_3_FILE=hidream-i1-dev-Q6_K.gguf"        & set "MODEL_07_OPT_3_TYPE=gguf" & set "MODEL_07_OPT_3_URL=https://huggingface.co/city96/HiDream-I1-Dev-gguf/resolve/main/hidream-i1-dev-Q6_K.gguf?download=true"
set "MODEL_07_OPT_4_NAME=Q8_0   (GGUF, >16GB VRAM)"       & set "MODEL_07_OPT_4_FILE=hidream-i1-dev-Q8_0.gguf"        & set "MODEL_07_OPT_4_TYPE=gguf" & set "MODEL_07_OPT_4_URL=%HF_FLX_URL%/hidream-i1-dev-Q8_0.gguf"
set "MODEL_07_OPT_5_NAME=FP8    (Safetensor, >24GB VRAM)" & set "MODEL_07_OPT_5_FILE=hidream_i1_dev_fp8.safetensors"  & set "MODEL_07_OPT_5_TYPE=diffusion_model" & set "MODEL_07_OPT_5_URL=%HF_FLX_URL%/hidream_i1_dev_fp8.safetensors"
set "MODEL_07_OPT_6_NAME=BF16   (Safetensor, >32GB VRAM)" & set "MODEL_07_OPT_6_FILE=hidream_i1_dev_bf16.safetensors" & set "MODEL_07_OPT_6_TYPE=diffusion_model" & set "MODEL_07_OPT_6_URL=https://huggingface.co/Comfy-Org/HiDream-I1_ComfyUI/resolve/main/split_files/diffusion_models/hidream_i1_dev_bf16.safetensors?download=true"
:: Model 8: SD1.5
set "MODEL_08_NAME=SD1.5"
set "MODEL_08_OPT_1_NAME=Full (Safetensor, 12GB VRAM)" & set "MODEL_08_OPT_1_FILE=v1-5-pruned-emaonly-fp16.safetensors" & set "MODEL_08_OPT_1_TYPE=checkpoint" & set "MODEL_08_OPT_1_URL=https://huggingface.co/Comfy-Org/stable-diffusion-v1-5-archive/resolve/main/v1-5-pruned-emaonly-fp16.safetensors?download=true"
:: Model 9: SDXL
set "MODEL_09_NAME=SDXL"
set "MODEL_09_OPT_1_NAME=Base (Safetensor, 12GB VRAM)" & set "MODEL_09_OPT_1_FILE=sd_xl_base_1.0_0.9vae.safetensors" & set "MODEL_09_OPT_1_TYPE=checkpoint" & set "MODEL_09_OPT_1_URL=%HF_FLX_URL%/sd_xl_base_1.0_0.9vae.safetensors"
:: Model 10: SD3
set "MODEL_10_NAME=SD3"
set "MODEL_10_OPT_1_NAME=Medium 2B      (Safetensor, 6-8GB VRAM)"   & set "MODEL_10_OPT_1_FILE=sd3.5_medium.safetensors"      & set "MODEL_10_OPT_1_TYPE=diffusion_model" & set "MODEL_10_OPT_1_URL=%HF_FLX_URL%/sd3.5_medium.safetensors"
set "MODEL_10_OPT_2_NAME=Large Turbo 8B (Safetensor, 16-24GB VRAM)" & set "MODEL_10_OPT_2_FILE=sd3.5_large_turbo.safetensors" & set "MODEL_10_OPT_2_TYPE=checkpoints"     & set "MODEL_10_OPT_2_URL=https://huggingface.co/calcuis/sd3.5-large-turbo/resolve/main/sd3.5_large_turbo.safetensors?download=true"
set "MODEL_10_OPT_3_NAME=Large 8B FP8   (Safetensor, 16-24GB VRAM)" & set "MODEL_10_OPT_3_FILE=sd3.5_large_fp8_scaled.safetensors"        & set "MODEL_10_OPT_3_TYPE=checkpoints"     & set "MODEL_10_OPT_3_URL=https://huggingface.co/Comfy-Org/stable-diffusion-3.5-fp8/resolve/main/sd3.5_large_fp8_scaled.safetensors?download=true"
set "MODEL_10_OPT_4_NAME=Large 8B       (Safetensor, 16-24GB VRAM)" & set "MODEL_10_OPT_4_FILE=sd3.5_large.safetensors"       & set "MODEL_10_OPT_4_TYPE=diffusion_model" & set "MODEL_10_OPT_4_URL=%HF_FLX_URL%/sd3.5_large.safetensors"
:: Model 11: WAN2.1T2V
set "MODEL_11_NAME=WAN2.1-T2V"
set "MODEL_11_OPT_1_NAME=Q4_K_S (GGUF, <12GB VRAM)"        & set "MODEL_11_OPT_1_FILE=wan2.1-t2v-14b-Q4_K_S.gguf"            & set "MODEL_11_OPT_1_TYPE=gguf" & set "MODEL_11_OPT_1_URL=%HF_FLX_URL%/wan2.1-t2v-14b-Q4_K_S.gguf"
set "MODEL_11_OPT_2_NAME=Q5_K_S (GGUF, 12-16GB VRAM)"      & set "MODEL_11_OPT_2_FILE=wan2.1-t2v-14b-Q5_K_S.gguf"            & set "MODEL_11_OPT_2_TYPE=gguf" & set "MODEL_11_OPT_2_URL=%HF_FLX_URL%/wan2.1-t2v-14b-Q5_K_S.gguf"
set "MODEL_11_OPT_3_NAME=Q6_K   (GGUF, ~16GB VRAM)"        & set "MODEL_11_OPT_3_FILE=wan2.1-t2v-14b-Q6_K.gguf"              & set "MODEL_11_OPT_3_TYPE=gguf" & set "MODEL_11_OPT_3_URL=https://huggingface.co/city96/Wan2.1-T2V-14B-gguf/resolve/main/wan2.1-t2v-14b-Q6_K.gguf?download=true"
set "MODEL_11_OPT_4_NAME=Q8_0   (GGUF, >16GB VRAM)"        & set "MODEL_11_OPT_4_FILE=wan2.1-t2v-14b-Q8_0.gguf"              & set "MODEL_11_OPT_4_TYPE=gguf" & set "MODEL_11_OPT_4_URL=%HF_FLX_URL%/wan2.1-t2v-14b-Q8_0.gguf"
set "MODEL_11_OPT_5_NAME=FP8    (Safetensors, >24GB VRAM)" & set "MODEL_11_OPT_5_FILE=wan2.1_t2v_14B_fp8_e4m3fn.safetensors" & set "MODEL_11_OPT_5_TYPE=diffusion_model" & set "MODEL_11_OPT_5_URL=https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_t2v_14B_fp8_e4m3fn.safetensors?download=true"
set "MODEL_11_OPT_6_NAME=BF16   (Safetensors, >32GB VRAM)" & set "MODEL_11_OPT_6_FILE=wan2.1_t2v_14B_bf16.safetensors"       & set "MODEL_11_OPT_6_TYPE=diffusion_model" & set "MODEL_11_OPT_6_URL=%HF_FLX_URL%/wan2.1_t2v_14B_bf16.safetensors"
:: Model 12: WAN2.1I2V
set "MODEL_12_NAME=WAN2.1-I2V-480"
set "MODEL_12_OPT_1_NAME=Q4_K_S (GGUF, <12GB VRAM)"        & set "MODEL_12_OPT_1_FILE=wan2.1-i2v-14b-480p-Q4_K_S.gguf"            & set "MODEL_12_OPT_1_TYPE=gguf" & set "MODEL_12_OPT_1_URL=%HF_FLX_URL%/wan2.1-i2v-14b-480p-Q4_K_S.gguf"
set "MODEL_12_OPT_2_NAME=Q5_K_S (GGUF, 12-16GB VRAM)"      & set "MODEL_12_OPT_2_FILE=wan2.1-i2v-14b-480p-Q5_K_S.gguf"            & set "MODEL_12_OPT_2_TYPE=gguf" & set "MODEL_12_OPT_2_URL=%HF_FLX_URL%/wan2.1-i2v-14b-480p-Q5_K_S.gguf"
set "MODEL_12_OPT_3_NAME=Q6_K   (GGUF, ~16GB VRAM)"        & set "MODEL_12_OPT_3_FILE=wan2.1-i2v-14b-480p-Q6_K.gguf"              & set "MODEL_12_OPT_3_TYPE=gguf" & set "MODEL_12_OPT_3_URL=https://huggingface.co/city96/Wan2.1-I2V-14B-480P-gguf/resolve/main/wan2.1-i2v-14b-480p-Q6_K.gguf?download=true"
set "MODEL_12_OPT_4_NAME=Q8_0   (GGUF, >16GB VRAM)"        & set "MODEL_12_OPT_4_FILE=wan2.1-i2v-14b-480p-Q8_0.gguf"              & set "MODEL_12_OPT_4_TYPE=gguf" & set "MODEL_12_OPT_4_URL=%HF_FLX_URL%/wan2.1-i2v-14b-480p-Q8_0.gguf"
set "MODEL_12_OPT_5_NAME=FP8    (Safetensors, >24GB VRAM)" & set "MODEL_12_OPT_5_FILE=wan2.1_i2v_480p_14B_fp8_e4m3fn.safetensors" & set "MODEL_12_OPT_5_TYPE=diffusion_model" & set "MODEL_12_OPT_5_URL=https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_i2v_480p_14B_fp8_e4m3fn.safetensors?download=true"
set "MODEL_12_OPT_6_NAME=BF16   (Safetensors, >32GB VRAM)" & set "MODEL_12_OPT_6_FILE=wan2.1_i2v_480p_14B_bf16.safetensors"       & set "MODEL_12_OPT_6_TYPE=diffusion_model" & set "MODEL_12_OPT_6_URL=%HF_FLX_URL%/wan2.1_i2v_480p_14B_bf16.safetensors"
:: Model 13: WAN2.1I2V
set "MODEL_13_NAME=WAN2.1-I2V-720"
set "MODEL_13_OPT_1_NAME=Q4_K_S (GGUF, <12GB VRAM)"        & set "MODEL_13_OPT_1_FILE=wan2.1-i2v-14b-720p-Q4_K_S.gguf"            & set "MODEL_13_OPT_1_TYPE=gguf" & set "MODEL_13_OPT_1_URL=%HF_FLX_URL%/wan2.1-i2v-14b-720p-Q4_K_S.gguf"
set "MODEL_13_OPT_2_NAME=Q5_K_S (GGUF, 12-16GB VRAM)"      & set "MODEL_13_OPT_2_FILE=wan2.1-i2v-14b-720p-Q5_K_S.gguf"            & set "MODEL_13_OPT_2_TYPE=gguf" & set "MODEL_13_OPT_2_URL=%HF_FLX_URL%/wan2.1-i2v-14b-720p-Q5_K_S.gguf"
set "MODEL_13_OPT_3_NAME=Q6_K   (GGUF, ~16GB VRAM)"        & set "MODEL_13_OPT_3_FILE=wan2.1-i2v-14b-720p-Q6_K.gguf"              & set "MODEL_13_OPT_3_TYPE=gguf" & set "MODEL_13_OPT_3_URL=https://huggingface.co/city96/Wan2.1-I2V-14B-720P-gguf/resolve/main/wan2.1-i2v-14b-720p-Q6_K.gguf?download=true"
set "MODEL_13_OPT_4_NAME=Q8_0   (GGUF, >16GB VRAM)"        & set "MODEL_13_OPT_4_FILE=wan2.1-i2v-14b-720p-Q8_0.gguf"              & set "MODEL_13_OPT_4_TYPE=gguf" & set "MODEL_13_OPT_4_URL=%HF_FLX_URL%/wan2.1-i2v-14b-720p-Q8_0.gguf"
set "MODEL_13_OPT_5_NAME=FP8    (Safetensors, >24GB VRAM)" & set "MODEL_13_OPT_5_FILE=wan2.1_i2v_720p_14B_fp8_e4m3fn.safetensors" & set "MODEL_13_OPT_5_TYPE=diffusion_model" & set "MODEL_13_OPT_5_URL=https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_i2v_720p_14B_fp8_e4m3fn.safetensors?download=true"
set "MODEL_13_OPT_6_NAME=BF16   (Safetensors, >32GB VRAM)" & set "MODEL_13_OPT_6_FILE=wan2.1_i2v_720p_14B_bf16.safetensors"       & set "MODEL_13_OPT_6_TYPE=diffusion_model" & set "MODEL_13_OPT_6_URL=%HF_FLX_URL%/wan2.1_i2v_720p_14B_bf16.safetensors"
:: Model 14: WAN2.1T2VFusionX
set "MODEL_14_NAME=WAN2.1-T2V-FusionX"
set "MODEL_14_OPT_1_NAME=Q4_K_S (GGUF, <13GB VRAM)"   & set "MODEL_14_OPT_1_FILE=Wan14BT2VFusionX-Q4_K_S.gguf" & set "MODEL_14_OPT_1_TYPE=gguf" & set "MODEL_14_OPT_1_URL=%HF_FLX_URL%/Wan14BT2VFusionX-Q4_K_S.gguf"
set "MODEL_14_OPT_2_NAME=Q5_K_S (GGUF, 13-16GB VRAM)" & set "MODEL_14_OPT_2_FILE=Wan14BT2VFusionX-Q5_K_S.gguf" & set "MODEL_14_OPT_2_TYPE=gguf" & set "MODEL_14_OPT_2_URL=%HF_FLX_URL%/Wan14BT2VFusionX-Q5_K_S.gguf"
set "MODEL_14_OPT_3_NAME=Q6_K   (GGUF, ~16GB VRAM)"   & set "MODEL_14_OPT_3_FILE=Wan14BT2VFusionX-Q6_K.gguf"   & set "MODEL_14_OPT_3_TYPE=gguf" & set "MODEL_14_OPT_3_URL=https://huggingface.co/QuantStack/Wan2.1_T2V_14B_FusionX-GGUF/resolve/main/Wan2.1_T2V_14B_FusionX-Q6_K.gguf?download=true"
set "MODEL_14_OPT_4_NAME=Q8_0   (GGUF, >16GB VRAM)"   & set "MODEL_14_OPT_4_FILE=Wan14BT2VFusionX-Q8_0.gguf"   & set "MODEL_14_OPT_4_TYPE=gguf" & set "MODEL_14_OPT_4_URL=%HF_FLX_URL%/Wan14BT2VFusionX-Q8_0.gguf"
:: Model 15: WAN2.1FusionXVace
set "MODEL_15_NAME=WAN2.1-T2V-FusionX-Vace"
set "MODEL_15_OPT_1_NAME=Q4_K_S (GGUF, <12GB VRAM)"   & set "MODEL_15_OPT_1_FILE=Wan2.1_T2V_14B_FusionX_VACE-Q4_K_S.gguf" & set "MODEL_15_OPT_1_TYPE=gguf" & set "MODEL_15_OPT_1_URL=%HF_FLX_URL%/Wan2.1_T2V_14B_FusionX_VACE-Q4_K_S.gguf"
set "MODEL_15_OPT_2_NAME=Q5_K_S (GGUF, 12-16GB VRAM)" & set "MODEL_15_OPT_2_FILE=Wan2.1_T2V_14B_FusionX_VACE-Q5_K_S.gguf" & set "MODEL_15_OPT_2_TYPE=gguf" & set "MODEL_15_OPT_2_URL=%HF_FLX_URL%/Wan2.1_T2V_14B_FusionX_VACE-Q5_K_S.gguf"
set "MODEL_15_OPT_3_NAME=Q6_K   (GGUF, ~16GB VRAM)"   & set "MODEL_15_OPT_3_FILE=Wan2.1_T2V_14B_FusionX_VACE-Q6_K.gguf"   & set "MODEL_15_OPT_3_TYPE=gguf" & set "MODEL_15_OPT_3_URL=https://huggingface.co/QuantStack/Wan2.1_T2V_14B_FusionX-GGUF/resolve/main/Wan2.1_T2V_14B_FusionX-Q6_K.gguf?download=true"
set "MODEL_15_OPT_4_NAME=Q8_0   (GGUF, >16GB VRAM)"   & set "MODEL_15_OPT_4_FILE=Wan2.1_T2V_14B_FusionX_VACE-Q8_0.gguf"   & set "MODEL_15_OPT_4_TYPE=gguf" & set "MODEL_15_OPT_4_URL=%HF_FLX_URL%/Wan2.1_T2V_14B_FusionX_VACE-Q8_0.gguf"
:: Model 16: WAN2.1Vace
set "MODEL_16_NAME=WAN2.1-Vace"
set "MODEL_16_OPT_1_NAME=Q4_K_S (GGUF, <12GB VRAM)"        & set "MODEL_16_OPT_1_FILE=Wan2.1-VACE-14B-Q4_K_S.gguf"            & set "MODEL_16_OPT_1_TYPE=gguf" & set "MODEL_16_OPT_1_URL=%HF_FLX_URL%/Wan2.1-VACE-14B-Q4_K_S.gguf"
set "MODEL_16_OPT_2_NAME=Q5_K_S (GGUF, 12-16GB VRAM)"      & set "MODEL_16_OPT_2_FILE=Wan2.1-VACE-14B-Q5_K_S.gguf"            & set "MODEL_16_OPT_2_TYPE=gguf" & set "MODEL_16_OPT_2_URL=%HF_FLX_URL%/Wan2.1-VACE-14B-Q5_K_S.gguf"
set "MODEL_16_OPT_3_NAME=Q6_K   (GGUF, ~16GB VRAM)"        & set "MODEL_16_OPT_3_FILE=Wan2.1-VACE-14B-Q6_K.gguf"              & set "MODEL_16_OPT_3_TYPE=gguf" & set "MODEL_16_OPT_3_URL=https://huggingface.co/QuantStack/Wan2.1_14B_VACE-GGUF/resolve/main/Wan2.1_14B_VACE-Q6_K.gguf?download=true"
set "MODEL_16_OPT_4_NAME=Q8_0   (GGUF, >16GB VRAM)"        & set "MODEL_16_OPT_4_FILE=Wan2.1-VACE-14B-Q8_0.gguf"              & set "MODEL_16_OPT_4_TYPE=gguf" & set "MODEL_16_OPT_4_URL=%HF_FLX_URL%/Wan2.1-VACE-14B-Q8_0.gguf"
set "MODEL_16_OPT_5_NAME=FP8    (Safetensors, >24GB VRAM)" & set "MODEL_16_OPT_5_FILE=wan2.1_vace_14B_fp8_e4m3fn.safetensors" & set "MODEL_16_OPT_5_TYPE=diffusion_model" & set "MODEL_16_OPT_5_URL=https://huggingface.co/Kamikaze-88/Wan2.1-VACE-14B-fp8/resolve/main/wan2.1_vace_14B_fp8_e4m3fn.safetensors?download=true"
set "MODEL_16_OPT_6_NAME=FP16   (Safetensors, >32GB VRAM)" & set "MODEL_16_OPT_6_FILE=wan2.1_vace_14B_fp16.safetensors"       & set "MODEL_16_OPT_6_TYPE=diffusion_model" & set "MODEL_16_OPT_6_URL=https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_vace_14B_fp16.safetensors?download=true"
:: Model 17: WAN2.2I2VL
set "MODEL_17_NAME=WAN2.2-I2V-L"
set "MODEL_17_OPT_1_NAME=Low Q4_K_S  (GGUF, <12GB VRAM)"        & set "MODEL_17_OPT_1_FILE=Wan2.2-I2V-A14B-LowNoise-Q4_K_S.gguf"            & set "MODEL_17_OPT_1_TYPE=gguf" & set "MODEL_17_OPT_1_URL=%HF_FLX_URL%/Wan2.2-I2V-A14B-LowNoise-Q4_K_S.gguf"
set "MODEL_17_OPT_2_NAME=Low Q5_K_S  (GGUF, 12-16GB VRAM)"      & set "MODEL_17_OPT_2_FILE=Wan2.2-I2V-A14B-LowNoise-Q5_K_S.gguf"            & set "MODEL_17_OPT_2_TYPE=gguf" & set "MODEL_17_OPT_2_URL=%HF_FLX_URL%/Wan2.2-I2V-A14B-LowNoise-Q5_K_S.gguf"
set "MODEL_17_OPT_3_NAME=Low Q6_K    (GGUF, ~16GB VRAM)"        & set "MODEL_17_OPT_3_FILE=Wan2.2-I2V-A14B-LowNoise-Q6_K.gguf"              & set "MODEL_17_OPT_3_TYPE=gguf" & set "MODEL_17_OPT_3_URL=https://huggingface.co/QuantStack/Wan2.2-I2V-A14B-GGUF/resolve/main/LowNoise/Wan2.2-I2V-A14B-LowNoise-Q6_K.gguf?download=true"
set "MODEL_17_OPT_4_NAME=Low Q8_0    (GGUF, >16GB VRAM)"        & set "MODEL_17_OPT_4_FILE=Wan2.2-I2V-A14B-LowNoise-Q8_0.gguf"              & set "MODEL_17_OPT_4_TYPE=gguf" & set "MODEL_17_OPT_4_URL=%HF_FLX_URL%/Wan2.2-I2V-A14B-LowNoise-Q8_0.gguf"
set "MODEL_17_OPT_5_NAME=Low FP8     (Safetensors, >24GB VRAM)" & set "MODEL_17_OPT_5_FILE=wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors" & set "MODEL_17_OPT_5_TYPE=diffusion_model" & set "MODEL_17_OPT_5_URL=https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors?download=true"
set "MODEL_17_OPT_6_NAME=Low FP16    (Safetensors, >32GB VRAM)" & set "MODEL_17_OPT_6_FILE=wan2.2_i2v_low_noise_14B_fp16.safetensors"       & set "MODEL_17_OPT_6_TYPE=diffusion_model" & set "MODEL_17_OPT_6_URL=https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_low_noise_14B_fp16.safetensors?download=true"
:: Model 18: WAN2.2I2VH
set "MODEL_18_NAME=WAN2.2-I2V-H"
set "MODEL_18_OPT_1_NAME=High Q4_K_S (GGUF, <12GB VRAM)"        & set "MODEL_18_OPT_1_FILE=Wan2.2-I2V-A14B-HighNoise-Q4_K_S.gguf"            & set "MODEL_18_OPT_1_TYPE=gguf" & set "MODEL_18_OPT_1_URL=%HF_FLX_URL%/Wan2.2-I2V-A14B-HighNoise-Q4_K_S.gguf"
set "MODEL_18_OPT_2_NAME=High Q5_K_S (GGUF, 12-16GB VRAM)"      & set "MODEL_18_OPT_2_FILE=Wan2.2-I2V-A14B-HighNoise-Q5_K_S.gguf"            & set "MODEL_18_OPT_2_TYPE=gguf" & set "MODEL_18_OPT_2_URL=%HF_FLX_URL%/Wan2.2-I2V-A14B-HighNoise-Q5_K_S.gguf"
set "MODEL_18_OPT_3_NAME=High Q6_K   (GGUF, ~16GB VRAM)"        & set "MODEL_18_OPT_3_FILE=Wan2.2-I2V-A14B-HighNoise-Q6_K.gguf"              & set "MODEL_18_OPT_3_TYPE=gguf" & set "MODEL_18_OPT_3_URL=https://huggingface.co/QuantStack/Wan2.2-I2V-A14B-GGUF/resolve/main/HighNoise/Wan2.2-I2V-A14B-HighNoise-Q6_K.gguf?download=true"
set "MODEL_18_OPT_4_NAME=High Q8_0   (GGUF, >16GB VRAM)"        & set "MODEL_18_OPT_4_FILE=Wan2.2-I2V-A14B-HighNoise-Q8_0.gguf"              & set "MODEL_18_OPT_4_TYPE=gguf" & set "MODEL_18_OPT_4_URL=%HF_FLX_URL%/Wan2.2-I2V-A14B-HighNoise-Q8_0.gguf"
set "MODEL_18_OPT_5_NAME=High FP8    (Safetensors, >24GB VRAM)" & set "MODEL_18_OPT_5_FILE=wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors" & set "MODEL_18_OPT_5_TYPE=diffusion_model" & set "MODEL_18_OPT_5_URL=https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors?download=true"
set "MODEL_18_OPT_6_NAME=High FP16   (Safetensors, >32GB VRAM)" & set "MODEL_18_OPT_6_FILE=wan2.2_i2v_high_noise_14B_fp16.safetensors"       & set "MODEL_18_OPT_6_TYPE=diffusion_model" & set "MODEL_18_OPT_6_URL=https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_high_noise_14B_fp16.safetensors?download=true"
:: Model 19: WAN2.2T2VL
set "MODEL_19_NAME=WAN2.2-T2V-L"
set "MODEL_19_OPT_1_NAME=Low Q4_K_S  (GGUF, <12GB VRAM)"        & set "MODEL_19_OPT_1_FILE=Wan2.2-T2V-A14B-LowNoise-Q4_K_S.gguf"            & set "MODEL_19_OPT_1_TYPE=gguf" & set "MODEL_19_OPT_1_URL=%HF_FLX_URL%/Wan2.2-T2V-A14B-LowNoise-Q4_K_S.gguf"
set "MODEL_19_OPT_2_NAME=Low Q5_K_S  (GGUF, 12-16GB VRAM)"      & set "MODEL_19_OPT_2_FILE=Wan2.2-T2V-A14B-LowNoise-Q5_K_S.gguf"            & set "MODEL_19_OPT_2_TYPE=gguf" & set "MODEL_19_OPT_2_URL=%HF_FLX_URL%/Wan2.2-T2V-A14B-LowNoise-Q5_K_S.gguf"
set "MODEL_19_OPT_3_NAME=Low Q6_K    (GGUF, ~16GB VRAM)"        & set "MODEL_19_OPT_3_FILE=Wan2.2-T2V-A14B-LowNoise-Q6_K.gguf"              & set "MODEL_19_OPT_3_TYPE=gguf" & set "MODEL_19_OPT_3_URL=https://huggingface.co/QuantStack/Wan2.2-T2V-A14B-GGUF/resolve/main/LowNoise/Wan2.2-T2V-A14B-LowNoise-Q6_K.gguf?download=true"
set "MODEL_19_OPT_4_NAME=Low Q8_0    (GGUF, >16GB VRAM)"        & set "MODEL_19_OPT_4_FILE=Wan2.2-T2V-A14B-LowNoise-Q8_0.gguf"              & set "MODEL_19_OPT_4_TYPE=gguf" & set "MODEL_19_OPT_4_URL=%HF_FLX_URL%/Wan2.2-T2V-A14B-LowNoise-Q8_0.gguf"
set "MODEL_19_OPT_5_NAME=Low FP8     (Safetensors, >24GB VRAM)" & set "MODEL_19_OPT_5_FILE=wan2.2_t2v_low_noise_14B_fp8_scaled.safetensors" & set "MODEL_19_OPT_5_TYPE=diffusion_model" & set "MODEL_19_OPT_5_URL=https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_t2v_low_noise_14B_fp8_scaled.safetensors?download=true"
set "MODEL_19_OPT_6_NAME=Low FP16    (Safetensors, >32GB VRAM)" & set "MODEL_19_OPT_6_FILE=wan2.2_t2v_low_noise_14B_fp16.safetensors"       & set "MODEL_19_OPT_6_TYPE=diffusion_model" & set "MODEL_19_OPT_6_URL=https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_t2v_low_noise_14B_fp16.safetensors?download=true"
:: Model 20: WAN2.2T2VH
set "MODEL_20_NAME=WAN2.2-T2V-H"
set "MODEL_20_OPT_1_NAME=High Q4_K_S (GGUF, <12GB VRAM)"        & set "MODEL_20_OPT_1_FILE=Wan2.2-T2V-A14B-HighNoise-Q4_K_S.gguf"            & set "MODEL_20_OPT_1_TYPE=gguf" & set "MODEL_20_OPT_1_URL=%HF_FLX_URL%/Wan2.2-T2V-A14B-HighNoise-Q4_K_S.gguf"
set "MODEL_20_OPT_2_NAME=High Q5_K_S (GGUF, 12-16GB VRAM)"      & set "MODEL_20_OPT_2_FILE=Wan2.2-T2V-A14B-HighNoise-Q5_K_S.gguf"            & set "MODEL_20_OPT_2_TYPE=gguf" & set "MODEL_20_OPT_2_URL=%HF_FLX_URL%/Wan2.2-T2V-A14B-HighNoise-Q5_K_S.gguf"
set "MODEL_20_OPT_3_NAME=High Q6_K   (GGUF, ~16GB VRAM)"        & set "MODEL_20_OPT_3_FILE=Wan2.2-T2V-A14B-HighNoise-Q6_K.gguf"              & set "MODEL_20_OPT_3_TYPE=gguf" & set "MODEL_20_OPT_3_URL=https://huggingface.co/QuantStack/Wan2.2-T2V-A14B-GGUF/resolve/main/HighNoise/Wan2.2-T2V-A14B-HighNoise-Q6_K.gguf?download=true"
set "MODEL_20_OPT_4_NAME=High Q8_0   (GGUF, >16GB VRAM)"        & set "MODEL_20_OPT_4_FILE=Wan2.2-T2V-A14B-HighNoise-Q8_0.gguf"              & set "MODEL_20_OPT_4_TYPE=gguf" & set "MODEL_20_OPT_4_URL=%HF_FLX_URL%/Wan2.2-T2V-A14B-HighNoise-Q8_0.gguf"
set "MODEL_20_OPT_5_NAME=High FP8    (Safetensors, >24GB VRAM)" & set "MODEL_20_OPT_5_FILE=wan2.2_t2v_high_noise_14B_fp8_scaled.safetensors" & set "MODEL_20_OPT_5_TYPE=diffusion_model" & set "MODEL_20_OPT_5_URL=https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_t2v_high_noise_14B_fp8_scaled.safetensors?download=true"
set "MODEL_20_OPT_6_NAME=High FP16   (Safetensors, >32GB VRAM)" & set "MODEL_20_OPT_6_FILE=wan2.2_t2v_high_noise_14B_fp16.safetensors"       & set "MODEL_20_OPT_6_TYPE=diffusion_model" & set "MODEL_20_OPT_6_URL=https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_t2v_high_noise_14B_fp16.safetensors?download=true"
:: Model 21: WAN2.2TI2V
set "MODEL_21_NAME=WAN2.2-TI2V"
set "MODEL_21_OPT_1_NAME=Q4_K_S  (GGUF, <12GB VRAM)"        & set "MODEL_21_OPT_1_FILE=Wan2.2-TI2V-5B-Q4_K_S.gguf"      & set "MODEL_21_OPT_1_TYPE=gguf" & set "MODEL_21_OPT_1_URL=%HF_FLX_URL%/Wan2.2-TI2V-5B-Q4_K_S.gguf"
set "MODEL_21_OPT_2_NAME=Q5_K_S  (GGUF, 12-16GB VRAM)"      & set "MODEL_21_OPT_2_FILE=Wan2.2-TI2V-5B-Q5_K_S.gguf"      & set "MODEL_21_OPT_2_TYPE=gguf" & set "MODEL_21_OPT_2_URL=%HF_FLX_URL%/Wan2.2-TI2V-5B-Q5_K_S.gguf"
set "MODEL_21_OPT_3_NAME=Q6_K    (GGUF, ~16GB VRAM)"        & set "MODEL_21_OPT_3_FILE=Wan2.2-TI2V-5B-Q6_K.gguf"        & set "MODEL_21_OPT_3_TYPE=gguf" & set "MODEL_21_OPT_3_URL=https://huggingface.co/QuantStack/Wan2.2-TI2V-5B-GGUF/resolve/main/Wan2.2-TI2V-5B-Q6_K.gguf?download=true"
set "MODEL_21_OPT_4_NAME=Q8_0    (GGUF, >16GB VRAM)"        & set "MODEL_21_OPT_4_FILE=Wan2.2-TI2V-5B-Q8_0.gguf"        & set "MODEL_21_OPT_4_TYPE=gguf" & set "MODEL_21_OPT_4_URL=%HF_FLX_URL%/Wan2.2-TI2V-5B-Q8_0.gguf"
set "MODEL_21_OPT_5_NAME=FP16    (Safetensors, >32GB VRAM)" & set "MODEL_21_OPT_5_FILE=wan2.2_ti2v_5B_fp16.safetensors" & set "MODEL_21_OPT_5_TYPE=diffusion_model" & set "MODEL_21_OPT_5_URL=https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_ti2v_5B_fp16.safetensors?download=true"

:: --- Shared/Extra Model Configuration ---
:: This is the single source of truth for all supporting models.
:: FLAG: The model family this file depends on (e.g., FLUX, SD3). Use "ALWAYS" for files that should always be downloaded.
:: PATH: The subdirectory within the 'models' folder (e.g., vae, upscale_models).
:: FILE: The filename.
:: URL:  The direct download URL.
:: ---
:: --- FLUX Extras (17) ---
set "EXTRA_001_FLAG=FLUX"   & set "EXTRA_001_PATH=diffusion_models" & set "EXTRA_001_FILE=svdq-fp4_r32-flux.1-kontext-dev.safetensors" & set "EXTRA_001_URL=%HF_FLX_URL%/svdq-fp4_r32-flux.1-kontext-dev.safetensors?download=true"
set "EXTRA_002_FLAG=FLUX"   & set "EXTRA_002_PATH=diffusion_models" & set "EXTRA_002_FILE=svdq-int4_r32-flux.1-kontext-dev.safetensors" & set "EXTRA_002_URL=%HF_FLX_URL%/svdq-int4_r32-flux.1-kontext-dev.safetensors?download=true"
set "EXTRA_003_FLAG=FLUX"   & set "EXTRA_003_PATH=text_encoders"    & set "EXTRA_003_FILE=umt5-xxl-encoder-Q5_K_S.gguf"              & set "EXTRA_003_URL=%HF_FLX_URL%/umt5-xxl-encoder-Q5_K_S.gguf?download=true"
set "EXTRA_004_FLAG=FLUX"   & set "EXTRA_004_PATH=text_encoders"    & set "EXTRA_004_FILE=t5xxl_fp16.safetensors"                   & set "EXTRA_004_URL=%HF_FLX_URL%/t5xxl_fp16.safetensors?download=true"
set "EXTRA_005_FLAG=FLUX"   & set "EXTRA_005_PATH=text_encoders"    & set "EXTRA_005_FILE=t5xxl_fp8_e4m3fn.safetensors"             & set "EXTRA_005_URL=%HF_FLX_URL%/t5xxl_fp8_e4m3fn.safetensors?download=true"
set "EXTRA_006_FLAG=FLUX"   & set "EXTRA_006_PATH=text_encoders"    & set "EXTRA_006_FILE=t5xxl_fp8_e4m3fn_scaled.safetensors"      & set "EXTRA_006_URL=%HF_FLX_URL%/t5xxl_fp8_e4m3fn_scaled.safetensors?download=true"
set "EXTRA_007_FLAG=FLUX"   & set "EXTRA_007_PATH=pulid"            & set "EXTRA_007_FILE=pulid_flux_v0.9.1.safetensors"            & set "EXTRA_007_URL=https://huggingface.co/guozinan/PuLID/resolve/main/pulid_flux_v0.9.1.safetensors?download=true"
set "EXTRA_008_FLAG=FLUX"   & set "EXTRA_008_PATH=controlnet"       & set "EXTRA_008_FILE=FLUX1-dev-ControlNet-Union-Pro.safetensors" & set "EXTRA_008_URL=%HF_FLX_URL%/Shakker-LabsFLUX1-dev-ControlNet-Union-Pro.safetensors?download=true"
set "EXTRA_009_FLAG=FLUX"   & set "EXTRA_009_PATH=controlnet"       & set "EXTRA_009_FILE=FLUX1-dev-ControlNet-Depth.safetensors"     & set "EXTRA_009_URL=https://huggingface.co/Shakker-Labs/FLUX.1-dev-ControlNet-Depth/resolve/main/diffusion_pytorch_model.safetensors?download=true"
set "EXTRA_010_FLAG=FLUX"   & set "EXTRA_010_PATH=xlabs\ipadapters" & set "EXTRA_010_FILE=ip_adapter.safetensors"                   & set "EXTRA_010_URL=https://huggingface.co/XLabs-AI/flux-ip-adapter-v2/resolve/main/ip_adapter.safetensors?download=true"
set "EXTRA_011_FLAG=FLUX"   & set "EXTRA_011_PATH=xlabs\controlnets"& set "EXTRA_011_FILE=flux-canny-controlnet-v3.safetensors"       & set "EXTRA_011_URL=https://huggingface.co/XLabs-AI/flux-controlnet-canny-v3/resolve/main/flux-canny-controlnet-v3.safetensors?download=true"
set "EXTRA_012_FLAG=FLUX"   & set "EXTRA_012_PATH=xlabs\controlnets"& set "EXTRA_012_FILE=flux-depth-controlnet-v3.safetensors"       & set "EXTRA_012_URL=https://huggingface.co/XLabs-AI/flux-controlnet-depth-v3/resolve/main/flux-depth-controlnet-v3.safetensors?download=true"
set "EXTRA_013_FLAG=FLUX"   & set "EXTRA_013_PATH=xlabs\controlnets"& set "EXTRA_013_FILE=flux-hed-controlnet-v3.safetensors"         & set "EXTRA_013_URL=https://huggingface.co/XLabs-AI/flux-controlnet-hed-v3/resolve/main/flux-hed-controlnet-v3.safetensors?download=true"
set "EXTRA_014_FLAG=FLUX"   & set "EXTRA_014_PATH=clip_vision"      & set "EXTRA_014_FILE=model.safetensors"                        & set "EXTRA_014_URL=https://huggingface.co/openai/clip-vit-large-patch14/resolve/main/model.safetensors?download=true"
set "EXTRA_015_FLAG=FLUX"   & set "EXTRA_015_PATH=style_models"     & set "EXTRA_015_FILE=flux1-redux-dev.safetensors"              & set "EXTRA_015_URL=https://huggingface.co/Runware/FLUX.1-Redux-dev/resolve/main/flux1-redux-dev.safetensors?download=true"
set "EXTRA_016_FLAG=FLUX"   & set "EXTRA_016_PATH=vae_approx"       & set "EXTRA_016_FILE=taef1_decoder.pth"                        & set "EXTRA_016_URL=https://github.com/madebyollin/taesd/raw/main/taef1_decoder.pth"
set "EXTRA_017_FLAG=FLUX"   & set "EXTRA_017_PATH=vae_approx"       & set "EXTRA_017_FILE=taef1_encoder.pth"                        & set "EXTRA_017_URL=https://github.com/madebyollin/taesd/raw/main/taef1_encoder.pth"
:: --- QWEN Extras (10) ---
set "EXTRA_018_FLAG=QWEN"   & set "EXTRA_018_PATH=text_encoders"    & set "EXTRA_018_FILE=Qwen2.5-VL-7B-Instruct-UD-Q4_K_S.gguf"    & set "EXTRA_018_URL=%HF_FLX_URL%/Qwen2.5-VL-7B-Instruct-UD-Q4_K_S.gguf?download=true"
set "EXTRA_019_FLAG=QWEN"   & set "EXTRA_019_PATH=text_encoders"    & set "EXTRA_019_FILE=Qwen2.5-VL-7B-Instruct-UD-Q4_K_XL.gguf"   & set "EXTRA_019_URL=%HF_FLX_URL%/Qwen2.5-VL-7B-Instruct-UD-Q4_K_XL.gguf?download=true"
set "EXTRA_020_FLAG=QWEN"   & set "EXTRA_020_PATH=text_encoders"    & set "EXTRA_020_FILE=Qwen2.5-VL-7B-Instruct-UD-Q5_K_S.gguf"    & set "EXTRA_020_URL=%HF_FLX_URL%/Qwen2.5-VL-7B-Instruct-UD-Q5_K_S.gguf?download=true"
set "EXTRA_021_FLAG=QWEN"   & set "EXTRA_021_PATH=text_encoders"    & set "EXTRA_021_FILE=Qwen2.5-VL-7B-Instruct-UD-Q8_0.gguf"      & set "EXTRA_021_URL=%HF_FLX_URL%/Qwen2.5-VL-7B-Instruct-UD-Q8_0.gguf?download=true"
set "EXTRA_022_FLAG=QWEN"   & set "EXTRA_022_PATH=text_encoders"    & set "EXTRA_022_FILE=Qwen2.5-VL-7B-Instruct-mmproj-BF16.gguf" & set "EXTRA_022_URL=%HF_FLX_URL%/Qwen2.5-VL-7B-Instruct-mmproj-BF16.gguf?download=true"
set "EXTRA_023_FLAG=QWEN"   & set "EXTRA_023_PATH=text_encoders"    & set "EXTRA_023_FILE=qwen_2.5_vl_7b_fp8_scaled.safetensors"      & set "EXTRA_023_URL=https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors?download=true"
set "EXTRA_024_FLAG=QWEN"   & set "EXTRA_024_PATH=vae"              & set "EXTRA_024_FILE=qwen_image_vae.safetensors"               & set "EXTRA_024_URL=%HF_FLX_URL%/qwen_image_vae.safetensors?download=true"
set "EXTRA_025_FLAG=QWEN"   & set "EXTRA_025_PATH=loras"            & set "EXTRA_025_FILE=Qwen-Image-Lightning-8steps-V1.0.safetensors" & set "EXTRA_025_URL=https://huggingface.co/lightx2v/Qwen-Image-Lightning/resolve/main/Qwen-Image-Lightning-8steps-V1.0.safetensors?download=true"
set "EXTRA_026_FLAG=QWEN"   & set "EXTRA_026_PATH=loras"            & set "EXTRA_026_FILE=Qwen-Image-Lightning-4steps-V1.0.safetensors" & set "EXTRA_026_URL=https://huggingface.co/lightx2v/Qwen-Image-Lightning/resolve/main/Qwen-Image-Lightning-4steps-V1.0.safetensors?download=true"
set "EXTRA_027_FLAG=QWEN"   & set "EXTRA_027_PATH=loras"            & set "EXTRA_027_FILE=qwen_image_union_diffsynth_lora.safetensors"& set "EXTRA_027_URL=https://huggingface.co/Comfy-Org/Qwen-Image-DiffSynth-ControlNets/resolve/main/split_files/loras/qwen_image_union_diffsynth_lora.safetensors?download=true"
:: --- HIDREAM Extras (2) ---
set "EXTRA_028_FLAG=HIDREAM"& set "EXTRA_028_PATH=text_encoders"    & set "EXTRA_028_FILE=clip_g_hidream.safetensors"               & set "EXTRA_028_URL=%HF_FLX_URL%/clip_g_hidream.safetensors?download=true"
set "EXTRA_029_FLAG=HIDREAM"& set "EXTRA_029_PATH=text_encoders"    & set "EXTRA_029_FILE=clip_l_hidream.safetensors"               & set "EXTRA_029_URL=%HF_FLX_URL%/clip_l_hidream.safetensors?download=true"
:: --- SD1.5 Extras (2) ---
set "EXTRA_030_FLAG=SD15"   & set "EXTRA_030_PATH=vae_approx"       & set "EXTRA_030_FILE=taesd_decoder.pth"                        & set "EXTRA_030_URL=https://github.com/madebyollin/taesd/raw/main/taesd_decoder.pth"
set "EXTRA_031_FLAG=SD15"   & set "EXTRA_031_PATH=vae_approx"       & set "EXTRA_031_FILE=taesd_encoder.pth"                        & set "EXTRA_031_URL=https://github.com/madebyollin/taesd/raw/main/taesd_encoder.pth"
:: --- SD3 Extras (8) ---
set "EXTRA_032_FLAG=SD3"    & set "EXTRA_032_PATH=text_encoders"    & set "EXTRA_032_FILE=clip_g.safetensors"                       & set "EXTRA_032_URL=https://huggingface.co/Comfy-Org/stable-diffusion-3.5-fp8/resolve/main/text_encoders/clip_g.safetensors?download=true"
set "EXTRA_033_FLAG=SD3"    & set "EXTRA_033_PATH=text_encoders"    & set "EXTRA_033_FILE=clip_l.safetensors"                       & set "EXTRA_033_URL=https://huggingface.co/Comfy-Org/stable-diffusion-3.5-fp8/resolve/main/text_encoders/clip_l.safetensors?download=true"
set "EXTRA_034_FLAG=SD3"    & set "EXTRA_034_PATH=vae"              & set "EXTRA_034_FILE=sd35_vae.safetensors"                     & set "EXTRA_034_URL=https://civitai.com/api/download/models/985137?type=Model^&format=SafeTensor"
set "EXTRA_035_FLAG=SD3"    & set "EXTRA_035_PATH=vae_approx"       & set "EXTRA_035_FILE=taesd3_decoder.pth"                       & set "EXTRA_035_URL=https://github.com/madebyollin/taesd/raw/main/taesd3_decoder.pth"
set "EXTRA_036_FLAG=SD3"    & set "EXTRA_036_PATH=vae_approx"       & set "EXTRA_036_FILE=taesd3_encoder.pth"                       & set "EXTRA_036_URL=https://github.com/madebyollin/taesd/raw/main/taesd3_encoder.pth"
set "EXTRA_037_FLAG=SD3"    & set "EXTRA_037_PATH=controlnet"       & set "EXTRA_037_FILE=sd3.5_large_controlnet_depth.safetensors" & set "EXTRA_037_URL=https://huggingface.co/stabilityai/stable-diffusion-3.5-controlnets/resolve/main/sd3.5_large_controlnet_depth.safetensors?download=true"
set "EXTRA_038_FLAG=SD3"    & set "EXTRA_038_PATH=controlnet"       & set "EXTRA_038_FILE=sd3.5_large_controlnet_canny.safetensors" & set "EXTRA_038_URL=https://huggingface.co/stabilityai/stable-diffusion-3.5-controlnets/resolve/main/sd3.5_large_controlnet_canny.safetensors?download=true"
set "EXTRA_039_FLAG=SD3"    & set "EXTRA_039_PATH=controlnet"       & set "EXTRA_039_FILE=sd3.5_large_controlnet_blur.safetensors"  & set "EXTRA_039_URL=https://huggingface.co/stabilityai/stable-diffusion-3.5-controlnets/resolve/main/sd3.5_large_controlnet_blur.safetensors?download=true"
:: --- SDXL Extras (8) ---
set "EXTRA_040_FLAG=SDXL"   & set "EXTRA_040_PATH=vae"              & set "EXTRA_040_FILE=sdxl_vae.safetensors"                     & set "EXTRA_040_URL=https://huggingface.co/stabilityai/sdxl-vae/resolve/main/sdxl_vae.safetensors?download=true"
set "EXTRA_041_FLAG=SDXL"   & set "EXTRA_041_PATH=checkpoints"      & set "EXTRA_041_FILE=sd_xl_refiner_1.0_0.9vae.safetensors"     & set "EXTRA_041_URL=https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0_0.9vae.safetensors?download=true"
set "EXTRA_042_FLAG=SDXL"   & set "EXTRA_042_PATH=controlnet"       & set "EXTRA_042_FILE=controlnet-union-sdxl-1.0.safetensors"    & set "EXTRA_042_URL=https://huggingface.co/xinsir/controlnet-union-sdxl-1.0/resolve/main/diffusion_pytorch_model_promax.safetensors?download=true"
set "EXTRA_043_FLAG=SDXL"   & set "EXTRA_043_PATH=controlnet"       & set "EXTRA_043_FILE=diffusers_xl_canny_full.safetensors"      & set "EXTRA_043_URL=https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/diffusers_xl_canny_full.safetensors?download=true"
set "EXTRA_044_FLAG=SDXL"   & set "EXTRA_044_PATH=controlnet"       & set "EXTRA_044_FILE=diffusers_xl_depth_full.safetensors"      & set "EXTRA_044_URL=https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/diffusers_xl_depth_full.safetensors?download=true"
set "EXTRA_045_FLAG=SDXL"   & set "EXTRA_045_PATH=controlnet"       & set "EXTRA_045_FILE=thibaud_xl_openpose.safetensors"          & set "EXTRA_045_URL=https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/thibaud_xl_openpose.safetensors?download=true"
set "EXTRA_046_FLAG=SDXL"   & set "EXTRA_046_PATH=vae_approx"       & set "EXTRA_046_FILE=taesdxl_decoder.pth"                      & set "EXTRA_046_URL=https://github.com/madebyollin/taesd/raw/main/taesdxl_decoder.pth"
set "EXTRA_047_FLAG=SDXL"   & set "EXTRA_047_PATH=vae_approx"       & set "EXTRA_047_FILE=taesdxl_encoder.pth"                      & set "EXTRA_047_URL=https://github.com/madebyollin/taesd/raw/main/taesdxl_encoder.pth"
:: --- WAN2.1 Extras (5) ---
set "EXTRA_048_FLAG=WAN21"  & set "EXTRA_048_PATH=vae"              & set "EXTRA_048_FILE=wan_2.1_vae.safetensors"                  & set "EXTRA_048_URL=%HF_FLX_URL%/wan_2.1_vae.safetensors?download=true"
set "EXTRA_049_FLAG=WAN21"  & set "EXTRA_049_PATH=loras"            & set "EXTRA_049_FILE=Wan2.1_T2V_14B_FusionX_LoRA.safetensors"  & set "EXTRA_049_URL=%HF_FLX_URL%/Wan2.1_T2V_14B_FusionX_LoRA.safetensors?download=true"
set "EXTRA_050_FLAG=WAN21"  & set "EXTRA_050_PATH=loras"            & set "EXTRA_050_FILE=Wan21_T2V_14B_lightx2v_cfg_step_distill_lora_rank32.safetensors" & set "EXTRA_050_URL=%HF_FLX_URL%/Wan21_T2V_14B_lightx2v_cfg_step_distill_lora_rank32.safetensors?download=true"
set "EXTRA_051_FLAG=WAN21"  & set "EXTRA_051_PATH=vae"              & set "EXTRA_051_FILE=ae.safetensors"                           & set "EXTRA_051_URL=%HF_FLX_URL%/ae.safetensors?download=true"
set "EXTRA_052_FLAG=WAN21"  & set "EXTRA_052_PATH=clip_vision"      & set "EXTRA_052_FILE=clip_vision_h.safetensors"                & set "EXTRA_052_URL=https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors?download=true"
:: --- WAN2.2 Extras (10) ---
set "EXTRA_053_FLAG=WAN22"  & set "EXTRA_053_PATH=vae"              & set "EXTRA_053_FILE=wan_2.2_vae.safetensors"                  & set "EXTRA_053_URL=https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/vae/wan2.2_vae.safetensors?download=true"
set "EXTRA_054_FLAG=WAN22"  & set "EXTRA_054_PATH=loras"            & set "EXTRA_054_FILE=Wan2.2-Lightning_T2V-v1.1-A14B-4steps-lora_LOW_fp16.safetensors"  & set "EXTRA_054_URL=%HF_FLX_URL%/Wan2.2-Lightning_T2V-v1.1-A14B-4steps-lora_LOW_fp16.safetensors?download=true"
set "EXTRA_055_FLAG=WAN22"  & set "EXTRA_055_PATH=loras"            & set "EXTRA_055_FILE=Wan2.2-Lightning_T2V-v1.1-A14B-4steps-lora_HIGH_fp16.safetensors" & set "EXTRA_055_URL=%HF_FLX_URL%/Wan2.2-Lightning_T2V-v1.1-A14B-4steps-lora_HIGH_fp16.safetensors?download=true"
set "EXTRA_056_FLAG=WAN22"  & set "EXTRA_056_PATH=loras"            & set "EXTRA_056_FILE=wan2.2_t2v_lightx2v_4steps_lora_v1.1_high_noise.safetensors"      & set "EXTRA_056_URL=https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_t2v_lightx2v_4steps_lora_v1.1_high_noise.safetensors?download=true"
set "EXTRA_057_FLAG=WAN22"  & set "EXTRA_057_PATH=loras"            & set "EXTRA_057_FILE=wan2.2_t2v_lightx2v_4steps_lora_v1.1_low_noise.safetensors"       & set "EXTRA_057_URL=https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_t2v_lightx2v_4steps_lora_v1.1_low_noise.safetensors?download=true"
set "EXTRA_058_FLAG=WAN22"  & set "EXTRA_058_PATH=loras"            & set "EXTRA_058_FILE=Wan2.2-Lightning_I2V-A14B-4steps-lora_LOW_fp16.safetensors"   & set "EXTRA_058_URL=%HF_FLX_URL%/Wan2.2-Lightning_I2V-A14B-4steps-lora_LOW_fp16.safetensors?download=true"
set "EXTRA_059_FLAG=WAN22"  & set "EXTRA_059_PATH=loras"            & set "EXTRA_059_FILE=Wan2.2-Lightning_I2V-A14B-4steps-lora_HIGH_fp16.safetensors"  & set "EXTRA_059_URL=%HF_FLX_URL%/Wan2.2-Lightning_I2V-A14B-4steps-lora_HIGH_fp16.safetensors?download=true"
set "EXTRA_060_FLAG=WAN22"  & set "EXTRA_060_PATH=loras"            & set "EXTRA_060_FILE=wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors"       & set "EXTRA_060_URL=https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors?download=true"
set "EXTRA_061_FLAG=WAN22"  & set "EXTRA_061_PATH=loras"            & set "EXTRA_061_FILE=wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors"        & set "EXTRA_061_URL=https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors?download=true"
set "EXTRA_062_FLAG=WAN22"  & set "EXTRA_062_PATH=text_encoders"    & set "EXTRA_062_FILE=umt5_xxl_fp8_e4m3fn_scaled.safetensors"       & set "EXTRA_062_URL=https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors?download=true"
:: --- ALWAYS Download (19) ---
set "EXTRA_063_FLAG=ALWAYS" & set "EXTRA_063_PATH=upscale_models"   & set "EXTRA_063_FILE=4x-ClearRealityV1.pth"                      & set "EXTRA_063_URL=%HF_FLX_URL%/4x-ClearRealityV1.pth?download=true"
set "EXTRA_064_FLAG=ALWAYS" & set "EXTRA_064_PATH=upscale_models"   & set "EXTRA_064_FILE=4x-UltraSharp.pth"                          & set "EXTRA_064_URL=https://huggingface.co/uwg/upscaler/resolve/main/ESRGAN/4x-UltraSharp.pth?download=true"
set "EXTRA_065_FLAG=ALWAYS" & set "EXTRA_065_PATH=upscale_models"   & set "EXTRA_065_FILE=ESRGAN_4x.pth"                              & set "EXTRA_065_URL=https://huggingface.co/Afizi/ESRGAN_4x.pth/resolve/main/ESRGAN_4x.pth?download=true"
set "EXTRA_066_FLAG=ALWAYS" & set "EXTRA_066_PATH=upscale_models"   & set "EXTRA_066_FILE=RealESRGAN_x2.pth"                          & set "EXTRA_066_URL=https://huggingface.co/ai-forever/Real-ESRGAN/resolve/main/RealESRGAN_x2.pth?download=true"
set "EXTRA_067_FLAG=ALWAYS" & set "EXTRA_067_PATH=upscale_models"   & set "EXTRA_067_FILE=RealESRGAN_x4.pth"                          & set "EXTRA_067_URL=https://huggingface.co/ai-forever/Real-ESRGAN/resolve/main/RealESRGAN_x4.pth?download=true"
set "EXTRA_068_FLAG=ALWAYS" & set "EXTRA_068_PATH=upscale_models"   & set "EXTRA_068_FILE=RealESRGAN_x8.pth"                          & set "EXTRA_068_URL=https://huggingface.co/ai-forever/Real-ESRGAN/resolve/main/RealESRGAN_x8.pth?download=true"
set "EXTRA_069_FLAG=ALWAYS" & set "EXTRA_069_PATH=upscale_models"   & set "EXTRA_069_FILE=RealESRGAN_x4plus_anime_6B.pth"             & set "EXTRA_069_URL=%HF_FLX_URL%/RealESRGAN_x4plus_anime_6B.pth?download=true"
set "EXTRA_070_FLAG=ALWAYS" & set "EXTRA_070_PATH=upscale_models"   & set "EXTRA_070_FILE=4x_NMKD-Siax_200k.pth"                       & set "EXTRA_070_URL=https://huggingface.co/uwg/upscaler/resolve/main/ESRGAN/4x_NMKD-Siax_200k.pth"
set "EXTRA_071_FLAG=ALWAYS" & set "EXTRA_071_PATH=upscale_models"   & set "EXTRA_071_FILE=4x_foolhardy_Remacri.pth"                   & set "EXTRA_071_URL=https://huggingface.co/uwg/upscaler/resolve/main/ESRGAN/4x_foolhardy_Remacri.pth?download=true"
set "EXTRA_072_FLAG=ALWAYS" & set "EXTRA_072_PATH=upscale_models"   & set "EXTRA_072_FILE=4x_NMKD-Superscale-SP_178000_G.pth"        & set "EXTRA_072_URL=https://huggingface.co/uwg/upscaler/resolve/main/ESRGAN/4x_NMKD-Superscale-SP_178000_G.pth?download=true"
set "EXTRA_073_FLAG=ALWAYS" & set "EXTRA_073_PATH=upscale_models"   & set "EXTRA_073_FILE=4xNomos8kDAT.pth"                           & set "EXTRA_073_URL=https://huggingface.co/uwg/upscaler/resolve/main/ESRGAN/4xNomos8kDAT.pth?download=true"
set "EXTRA_074_FLAG=ALWAYS" & set "EXTRA_074_PATH=sams"             & set "EXTRA_074_FILE=sam_vit_b_01ec64.pth"                       & set "EXTRA_074_URL=%HF_FLX_URL%/sam_vit_b_01ec64.pth?download=true"
set "EXTRA_075_FLAG=ALWAYS" & set "EXTRA_075_PATH=ultralytics\bbox" & set "EXTRA_075_FILE=hand_yolov8s.pt"                          & set "EXTRA_075_URL=https://huggingface.co/xingren23/comfyflow-models/resolve/976de8449674de379b02c144d0b3cfa2b61482f2/ultralytics/bbox/hand_yolov8s.pt?download=true"
set "EXTRA_076_FLAG=ALWAYS" & set "EXTRA_076_PATH=ultralytics\bbox" & set "EXTRA_076_FILE=face_yolov8m.pt"                          & set "EXTRA_076_URL=https://huggingface.co/xingren23/comfyflow-models/resolve/976de8449674de379b02c144d0b3cfa2b61482f2/ultralytics/bbox/face_yolov8m.pt?download=true"
set "EXTRA_077_FLAG=ALWAYS" & set "EXTRA_077_PATH=ultralytics\segm" & set "EXTRA_077_FILE=person_yolov8m-seg.pt"                    & set "EXTRA_077_URL=https://huggingface.co/xingren23/comfyflow-models/resolve/976de8449674de379b02c144d0b3cfa2b61482f2/ultralytics/segm/person_yolov8m-seg.pt?download=true"
set "EXTRA_078_FLAG=ALWAYS" & set "EXTRA_078_PATH=text_encoders"    & set "EXTRA_078_FILE=llama_3.1_8b_instruct_fp8_scaled.safetensors" & set "EXTRA_078_URL=%HF_FLX_URL%/llama_3.1_8b_instruct_fp8_scaled.safetensors?download=true"
set "EXTRA_079_FLAG=ALWAYS" & set "EXTRA_079_PATH=clip_vision"      & set "EXTRA_079_FILE=sigclip_vision_patch14_384.safetensors"     & set "EXTRA_079_URL=%HF_FLX_URL%/sigclip_vision_patch14_384.safetensors?download=true"
set "EXTRA_080_FLAG=ALWAYS" & set "EXTRA_080_PATH=clip"             & set "EXTRA_080_FILE=ViT-L-14-TEXT-detail-improved-hiT-GmP-TE-only-HF.safetensors" & set "EXTRA_080_URL=%HF_FLX_URL%/ViT-L-14-TEXT-detail-improved-hiT-GmP-TE-only-HF.safetensors?download=true"
set "EXTRA_081_FLAG=ALWAYS" & set "EXTRA_081_PATH=llm_gguf"         & set "EXTRA_081_FILE=Hermes-3-Llama-3.1-8B.Q8_0.gguf"            & set "EXTRA_081_URL=https://huggingface.co/NousResearch/Hermes-3-Llama-3.1-8B-GGUF/resolve/main/Hermes-3-Llama-3.1-8B.Q8_0.gguf?download=true"

:: --- Custom Node Repositories (Robust Method) ---
set "NODE_URL_01=https://github.com/ltdrdata/ComfyUI-Manager.git"
set "NODE_URL_02=https://codeberg.org/Gourieff/comfyui-reactor-node.git"
set "NODE_URL_03=https://github.com/ltdrdata/ComfyUI-Impact-Pack.git"
set "NODE_URL_04=https://github.com/ltdrdata/ComfyUI-Impact-Subpack.git"
set "NODE_URL_05=https://github.com/Fannovel16/comfyui_controlnet_aux.git"
set "NODE_URL_06=https://github.com/city96/ComfyUI-GGUF.git"
set "NODE_URL_07=https://github.com/rgthree/rgthree-comfy.git"
set "NODE_URL_08=https://github.com/yolain/ComfyUI-Easy-Use.git"
set "NODE_URL_09=https://github.com/kijai/ComfyUI-KJNodes.git"
set "NODE_URL_10=https://github.com/ssitu/ComfyUI_UltimateSDUpscale.git"
set "NODE_URL_11=https://github.com/cubiq/ComfyUI_essentials.git"
set "NODE_URL_12=https://github.com/wallish77/wlsh_nodes.git"
set "NODE_URL_13=https://github.com/vrgamegirl19/comfyui-vrgamedevgirl.git"
set "NODE_URL_14=https://github.com/ClownsharkBatwing/RES4LYF.git"
set "NODE_URL_15=https://github.com/kijai/ComfyUI-LivePortraitKJ.git"
set "NODE_URL_16=https://github.com/PowerHouseMan/ComfyUI-AdvancedLivePortrait.git"
set "NODE_URL_17=https://github.com/kijai/ComfyUI-Florence2.git"
set "NODE_URL_18=https://github.com/sipie800/ComfyUI-PuLID-Flux-Enhanced.git"
set "NODE_URL_19=https://github.com/kijai/ComfyUI-HunyuanVideoWrapper.git"
set "NODE_URL_20=https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git"
set "NODE_URL_21=https://github.com/WASasquatch/was-node-suite-comfyui.git"
set "NODE_URL_22=https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git"
set "NODE_URL_23=https://github.com/TinyTerra/ComfyUI_tinyterraNodes.git"
set "NODE_URL_24=https://github.com/Derfuu/Derfuu_ComfyUI_ModdedNodes.git"
set "NODE_URL_25=https://github.com/Smirnov75/ComfyUI-mxToolkit.git"
set "NODE_URL_26=https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes.git"
set "NODE_URL_27=https://github.com/chrisgoringe/cg-use-everywhere.git"
set "NODE_URL_28=https://github.com/XLabs-AI/x-flux-comfyui.git"
set "NODE_URL_29=https://github.com/logtd/ComfyUI-LTXTricks.git"
set "NODE_URL_30=https://github.com/SeaArtLab/ComfyUI-Long-CLIP.git"
set "NODE_URL_31=https://github.com/jamesWalker55/comfyui-various.git"
set "NODE_URL_32=https://github.com/JPS-GER/ComfyUI_JPS-Nodes.git"
set "NODE_URL_33=https://github.com/Jonseed/ComfyUI-Detail-Daemon.git"
set "NODE_URL_34=https://github.com/kijai/ComfyUI-WanVideoWrapper.git"
set "NODE_URL_35=https://github.com/Zehong-Ma/ComfyUI-MagCache.git"
set "NODE_URL_36=https://github.com/Fannovel16/ComfyUI-Frame-Interpolation.git"
set "NODE_URL_37=https://github.com/mit-han-lab/ComfyUI-nunchaku.git"
set "NODE_URL_38=https://github.com/ChenDarYen/ComfyUI-NAG.git"
set "NODE_URL_39=https://github.com/Draek2077/comfyui-draekz-nodez.git"
set "NODE_URL_40=https://github.com/crystian/ComfyUI-Crystools.git"
set "NODE_URL_41=https://github.com/sipherxyz/comfyui-art-venture.git"
set "NODE_URL_42=https://github.com/digitaljohn/comfyui-propost.git"
set "NODE_URL_43=https://github.com/miaoshouai/ComfyUI-Miaoshouai-Tagger.git"
set "NODE_URL_44=https://github.com/jags111/efficiency-nodes-comfyui.git"
set "NODE_URL_45=https://github.com/1038lab/ComfyUI-JoyCaption.git"
set "NODE_URL_46=https://github.com/fairy-root/Flux-Prompt-Generator"
set "NODE_URL_47=https://github.com/marduk191/ComfyUI-Fluxpromptenhancer"
set "NODE_URL_48=https://github.com/lquesada/ComfyUI-Inpaint-CropAndStitch"

:: Run initial verification silently to check for existing components and calculate initial size
call :silent_verify_all
call :calculate_total_size

:: -----------------------------------------------------------------------------
:: Section 2: Main Menu
:: -----------------------------------------------------------------------------
:main_menu
:: --- Check available disk space (robust PowerShell method) ---
set "FREE_SPACE_GB=?"
set "DISK_SPACE_DISPLAY="

:: Get free space and convert to GB in a single command, rounding to 1 decimal place
for /f "delims=" %%s in ('powershell -NoProfile -Command "$drive = '%~d0'; $freeBytes = (Get-Volume -DriveLetter $drive[0]).SizeRemaining; $gb = [Math]::Round($freeBytes / 1GB, 1); $gb.ToString([System.Globalization.CultureInfo]::InvariantCulture)"') do set "FREE_SPACE_GB=%%s"
:: This part of your code below remains the same
if defined FREE_SPACE_GB (
    :: Compare with required size (integer part only for simplicity)
    set "SIZE_TOTAL_INT=0" & for /f "delims=." %%i in ("!SIZE_TOTAL_GB!") do set "SIZE_TOTAL_INT=%%i"

    if !FREE_SPACE_GB! GTR !SIZE_TOTAL_INT! (
        set "DISK_SPACE_DISPLAY=%GREEN% / !FREE_SPACE_GB! GB available%RESET%"
    ) else (
        set "DISK_SPACE_DISPLAY=%RED% / !FREE_SPACE_GB! GB available%RESET%"
    )
) else (
     set "DISK_SPACE_DISPLAY=%RED% / Space Check Failed%RESET%"
)

cls

:: --- Set Status Checkmarks ---
if "!STATUS_COMFYUI!"=="1" ( set "CHECK_COMFYUI=%GREEN%[X]%RESET%" ) else ( set "CHECK_COMFYUI=%RED%[ ]%RESET%" )
if "!STATUS_MODELS!"=="1" ( set "CHECK_MODELS=%GREEN%[X]%RESET%" ) else ( set "CHECK_MODELS=%RED%[ ]%RESET%" )
if "!STATUS_NODES!"=="1" ( set "CHECK_NODES=%GREEN%[X]%RESET%" ) else ( set "CHECK_NODES=%RED%[ ]%RESET%" )
if "!STATUS_TRITON!"=="1" ( set "CHECK_TRITON=%GREEN%[X]%RESET%" ) else ( set "CHECK_TRITON=%RED%[ ]%RESET%" )
if "!STATUS_LIBS!"=="1" ( set "CHECK_LIBS=%GREEN%[X]%RESET%" ) else ( set "CHECK_LIBS=%RED%[ ]%RESET%" )

:: Build model selection status string for the menu using a more robust method
set "MODEL_SELECTION_STATUS="
set "any_model_selected=false"
set "separator="
for /l %%G in (1,1,99) do (
    set "num=0%%G" & set "num=!num:~-2!"
    if defined MODEL_!num!_NAME (
        call set "is_selected=%%SELECT_MODEL_!num!%%"
        if "!is_selected!"=="1" (
            set "any_model_selected=true"
            call set "MODEL_NAME=%%MODEL_!num!_NAME%%"
            set "MODEL_SELECTION_STATUS=!MODEL_SELECTION_STATUS!!separator!!MODEL_NAME!"
            set "separator=, "
        )
    )
)

if "!any_model_selected!"=="true" (
    if not "!SELECTED_QUALITY_NAME!"=="None" (
        set "MODEL_SELECTION_STATUS=[!MODEL_SELECTION_STATUS! - !SELECTED_QUALITY_NAME!]"
    ) else (
        set "MODEL_SELECTION_STATUS=[!MODEL_SELECTION_STATUS! - No Quality Selected]"
    )
) else (
    set "MODEL_SELECTION_STATUS=[None]"
)

echo.
echo %BLUE%======================================================================%RESET%
echo %BLUE%          Draekz Ultimate ComfyUI Installation Wizard                 %RESET%
echo %BLUE%======================================================================%RESET%
echo.
echo %YELLOW%[ Main Actions ]%RESET%
echo %WHITE%  S^) Select Models ^& Quality %PURPLE%!MODEL_SELECTION_STATUS!%RESET%
echo %WHITE%  I^) Install Everything ^(Approx. %PURPLE%!SIZE_TOTAL_GB! GB needed!DISK_SPACE_DISPLAY!^)%RESET%
echo %WHITE%  V^) Verify Installation ^(updates status checks below^)%RESET%
echo.
echo %YELLOW%[ Installation Status ^& Manual Steps ]%RESET%
echo %WHITE%  1^) !CHECK_COMFYUI! Install ComfyUI ^(Approx. %PURPLE%6.5 GB%RESET%^)%RESET%
echo %WHITE%  2^) !CHECK_MODELS! Install Selected Models ^(Approx. %PURPLE%!SIZE_MODELS_GB! GB needed%RESET%^)%RESET%
echo %WHITE%  3^) !CHECK_NODES! Install Custom Nodes%RESET%
echo %WHITE%  4^) !CHECK_TRITON! Install Triton ^& Sage Attention%RESET%
echo %WHITE%  5^) !CHECK_LIBS! Install Python Include Libs%RESET%
echo.
echo %YELLOW%[ Optional Tools ^& Diagnostics ]%RESET%
if "!INSTALL_SERVER_MANAGER!"=="1" (
    echo %WHITE%  6^) Install Server Manager %GREEN%[X]%RESET%
) else (
    echo %WHITE%  6^) Install Server Manager %RED%[ ]%RESET%
)
if "!INSTALL_CLIENT_WRAPPER!"=="1" (
    echo %WHITE%  7^) Install Client Wrapper %GREEN%[X]%RESET%
) else (
    echo %WHITE%  7^) Install Client Wrapper %RED%[ ]%RESET%
)
echo %WHITE%  Y^) Verify Prerequisites%RESET%
echo.
echo %WHITE%  X^) Quit%RESET%
echo.
echo %BLUE%======================================================================%RESET%
echo.
if defined LAST_ACTION_MSG echo  Last Action: !LAST_ACTION_MSG!
echo.
set /p "main_choice=%WHITE%Enter your choice and press ENTER: %RESET%"

if /i "%main_choice%"=="s" goto :model_selection_entry
if /i "%main_choice%"=="i" goto :full_install
if "%main_choice%"=="6" goto :toggle_server_manager
if "%main_choice%"=="7" goto :toggle_client_wrapper
if "%main_choice%"=="1" goto :install_comfyui_standalone
if "%main_choice%"=="2" goto :install_models_standalone
if "%main_choice%"=="3" goto :install_nodes_standalone
if "%main_choice%"=="4" goto :install_triton_sage_standalone
if "%main_choice%"=="5" goto :setup_python_libs_standalone
if /i "%main_choice%"=="v" goto :verify_all
if /i "%main_choice%"=="y" goto :verify_prereqs_menu
if /i "%main_choice%"=="x" goto :exit_script

set "LAST_ACTION_MSG=%RED%Invalid choice. Please try again.%RESET%"
goto :main_menu


:: -----------------------------------------------------------------------------
:: Section 3: Core Logic and Subroutines
:: -----------------------------------------------------------------------------

:: --- Standalone wrappers for menu options ---
:install_comfyui_standalone
call :install_comfyui
call :calculate_total_size
goto :main_menu

:install_models_standalone
call :install_models
call :calculate_total_size
goto :main_menu

:install_nodes_standalone
call :install_nodes
call :calculate_total_size
goto :main_menu

:install_triton_sage_standalone
call :install_triton_sage
call :calculate_total_size
goto :main_menu

:setup_python_libs_standalone
call :setup_python_libs
call :calculate_total_size
goto :main_menu

:: --- Toggle Server Manager ---
:toggle_server_manager
if "%INSTALL_SERVER_MANAGER%"=="1" (
    set "INSTALL_SERVER_MANAGER=0"
    set "LAST_ACTION_MSG=%GREEN%Server Manager installation DISABLED.%RESET%"
) else (
    set "INSTALL_SERVER_MANAGER=1"
    set "LAST_ACTION_MSG=%GREEN%Server Manager installation ENABLED.%RESET%"
)
goto :main_menu

:: --- Toggle Client Wrapper ---
:toggle_client_wrapper
if "%INSTALL_CLIENT_WRAPPER%"=="1" (
    set "INSTALL_CLIENT_WRAPPER=0"
    set "LAST_ACTION_MSG=%GREEN%Client Wrapper installation DISABLED.%RESET%"
) else (
    set "INSTALL_CLIENT_WRAPPER=1"
    set "LAST_ACTION_MSG=%GREEN%Client Wrapper installation ENABLED.%RESET%"
)
goto :main_menu

:: --- Full Installation ---
:full_install
if "!SELECTED_QUALITY_NAME!"=="None" (
    set "LAST_ACTION_MSG=%RED%Please select model families and quality (Option S) before installing.%RESET%"
    goto :main_menu
)

echo %YELLOW%[INFO] Starting full installation sequence based on '!SELECTED_QUALITY_NAME!' quality...%RESET%
call :check_prereqs
call :install_comfyui
if %errorlevel% neq 0 (
    set "LAST_ACTION_MSG=%RED%ComfyUI installation failed. Aborting full install.%RESET%"
    goto :main_menu
)

if defined COMFYUI_ALREADY_EXISTS (
    echo %PURPLE%[INFO] Skipping Core Python Packages as ComfyUI already exists.%RESET%
) else (
    call :install_core_python_packages
)

call :install_nodes
call :install_models
call :setup_python_libs
call :install_triton_sage
echo.
echo %GREEN%======================================================================%RESET%
echo %GREEN%           [X] Full Installation Complete!                            %RESET%
echo %GREEN%======================================================================%RESET%
echo.
set "LAST_ACTION_MSG=%GREEN%Full Installation completed successfully!%RESET%"
call :calculate_total_size
pause
goto :main_menu

:: --- Model Selection Entry Point ---
:model_selection_entry
goto :model_family_selection_menu


:: --- Select Model Families Menu ---
:model_family_selection_menu
set "family_selection_cancelled="
:model_family_selection_loop
cls
echo.
echo %BLUE%======================================================================%RESET%
echo %BLUE%                   Step 1: Select Model Families                      %RESET%
echo %BLUE%======================================================================%RESET%
echo.
echo %YELLOW%Toggle which model families you want to install. [X] = selected.%RESET%
echo.

for /l %%G in (1,1,99) do (
    set "num=0%%G" & set "num=!num:~-2!"
    if defined MODEL_!num!_NAME (
        call set "IS_SELECTED=%%SELECT_MODEL_!num!%%"
        call set "MODEL_NAME=%%MODEL_!num!_NAME%%"
        if "!IS_SELECTED!"=="1" (
            echo %GREEN%  %%G^) [X] !MODEL_NAME!%RESET%
        ) else (
            echo %WHITE%  %%G^) [ ] !MODEL_NAME!%RESET%
        )
    )
)

echo.
echo %WHITE%  C) Continue to Quality Selection%RESET%
echo %WHITE%  A) Select ALL Models%RESET%
echo %WHITE%  N) Select NONE%RESET%
echo %WHITE%  X) Cancel and return to Main Menu%RESET%
echo.
set /p "family_choice=%WHITE%Enter number to toggle, or a letter for other options: %RESET%"

if /i "%family_choice%"=="C" goto :select_quality_menu
if /i "%family_choice%"=="A" (
    for /l %%G in (1,1,99) do (
        set "num=0%%G" & set "num=!num:~-2!"
        if defined MODEL_!num!_NAME set "SELECT_MODEL_!num!=1"
    )
    goto :model_family_selection_loop
)
if /i "%family_choice%"=="N" (
    for /l %%G in (1,1,99) do (
        set "num=0%%G" & set "num=!num:~-2!"
        if defined MODEL_!num!_NAME set "SELECT_MODEL_!num!=0"
    )
    goto :model_family_selection_loop
)

if /i "%family_choice%"=="X" (
    set "LAST_ACTION_MSG=%PURPLE%Model selection cancelled.%RESET%"
    goto :main_menu
)

rem Toggle logic
set "choice_num=0%family_choice%" & set "choice_num=!choice_num:~-2!"
if defined MODEL_!choice_num!_NAME (
    call set "CURRENT_SELECTION=%%SELECT_MODEL_!choice_num!%%"
    if "!CURRENT_SELECTION!"=="1" (
        set "SELECT_MODEL_!choice_num!=0"
    ) else (
        set "SELECT_MODEL_!choice_num!=1"
    )
)

goto :model_family_selection_loop


:: --- Select Model Quality Menu ---
:select_quality_menu
cls
echo.
echo %BLUE%======================================================================%RESET%
echo %BLUE%                 Step 2: Select Model Quality Level                   %RESET%
echo %BLUE%======================================================================%RESET%
echo.
echo %YELLOW%This selection determines which version of each selected model will be downloaded.%RESET%
echo.
echo %PURPLE%--- GGUF ^(Recommended for Broad Compatibility^) ---%RESET%
echo %WHITE%  1^) Q4 GGUF - Basic Quality ^(Lowest VRAM, ~8GB+^)%RESET%
echo %WHITE%  2^) Q5 GGUF - Good Quality ^(Balanced, ~12GB+^)%RESET%
echo %WHITE%  3^) Q6 GGUF - Better Quality ^(Good Balance, ~16GB+^)%RESET%
echo %WHITE%  4^) Q8 GGUF - High Quality ^(High VRAM, ^>16GB+^)%RESET%
echo.
echo %PURPLE%--- SafeTensors ^(May Require More VRAM^) ---%RESET%
echo %WHITE%  5^) FP8 SafeTensors - Best Quality ^(Very High VRAM, ~24GB+^)%RESET%
echo %WHITE%  6^) Full SafeTensors - Maximum Quality ^(Highest VRAM, ~32GB+^)%RESET%
echo.
echo %WHITE%  X^) Cancel and return to Main Menu%RESET%
echo.
set /p "quality_choice=%WHITE%Enter your choice and press ENTER: %RESET%"

if /i "%quality_choice%"=="X" (
    set "LAST_ACTION_MSG=%PURPLE%Model quality selection cancelled.%RESET%"
    goto :main_menu
)

set "is_valid="
if "%quality_choice%"=="1" set "is_valid=1"
if "%quality_choice%"=="2" set "is_valid=1"
if "%quality_choice%"=="3" set "is_valid=1"
if "%quality_choice%"=="4" set "is_valid=1"
if "%quality_choice%"=="5" set "is_valid=1"
if "%quality_choice%"=="6" set "is_valid=1"

if defined is_valid (
    if "%quality_choice%"=="1" set "SELECTED_QUALITY_NAME=Q4 GGUF"
    if "%quality_choice%"=="2" set "SELECTED_QUALITY_NAME=Q5 GGUF"
    if "%quality_choice%"=="3" set "SELECTED_QUALITY_NAME=Q6 GGUF"
    if "%quality_choice%"=="4" set "SELECTED_QUALITY_NAME=Q8 GGUF"
    if "%quality_choice%"=="5" set "SELECTED_QUALITY_NAME=FP8 SafeTensors"
    if "%quality_choice%"=="6" set "SELECTED_QUALITY_NAME=Full SafeTensors"

    call :set_models_by_quality %quality_choice%
    call :calculate_total_size
    echo.
    echo %YELLOW%Selections set. Automatically running verification...%RESET%
    timeout /t 2 >nul
    call :silent_verify_all
    set "LAST_ACTION_MSG=%GREEN%Model selections set and verification complete.%RESET%"
    goto :main_menu
) else (
    echo %RED%Invalid selection. Please try again.%RESET%
    timeout /t 2 >nul
    goto :select_quality_menu
)

:set_models_by_quality
set "quality_choice=%1"
echo %YELLOW%Configuring model selections based on chosen families and quality...%RESET%

:: Clear any previous INSTALL selections
for /l %%G in (1,1,99) do (
    set "num=0%%G"
    set "num=!num:~-2!"
    if defined MODEL_!num!_NAME (
        for /l %%H in (1,1,9) do (
            set "MODEL_!num!_OPT_%%H_INSTALL="
        )
    )
)

:: FIX: Use a local variable for quality_choice to allow for correct delayed expansion inside the loops below.
set "local_quality_choice=%quality_choice%"

:: Loop through all potential models (01-99)
for /l %%G in (1,1,99) do (
    :: Format number with leading zero (e.g., 1 -> 01)
    set "num=0%%G"
    set "num=!num:~-2!"

    :: Check if the current model was selected by the user
    call set "is_selected=%%SELECT_MODEL_!num!%%"
    if "!is_selected!"=="1" (

        :: Flag to ensure we only install one quality level per model
        set "found_quality_for_model=false"

        :: Loop downwards from the user's quality choice to find the best available option
        for /l %%H in (!local_quality_choice!,-1,1) do (

            :: If we haven't found a suitable quality level for this model yet...
            if "!found_quality_for_model!"=="false" (

                :: ...check if the current quality level (%%H) exists for this model (!num!)
                if defined MODEL_!num!_OPT_%%H_NAME (

                    :: If it exists, flag it for installation
                    set "MODEL_!num!_OPT_%%H_INSTALL=1"

                    :: Set the flag to true to stop searching for lower quality levels
                    set "found_quality_for_model=true"
                )
            )
        )
    )
)

echo %GREEN%Model selection complete.%RESET%
timeout /t 1 >nul
goto :eof

:verify_prereqs_menu
cls
echo.
echo %BLUE%======================================================================%RESET%
echo %BLUE%                System Prerequisites Status Report                    %RESET%
echo %BLUE%======================================================================%RESET%
echo.
call :ensure_winget >nul
winget --version >nul 2>&1 && (echo %GREEN%[OK] Winget is installed.%RESET%) || (echo %RED%[FAIL] Winget not found.%RESET%)
git --version >nul 2>&1 && (echo %GREEN%[OK] Git is installed.%RESET%) || (echo %RED%[FAIL] Git not found.%RESET%)
call :find_7zip
if !errorlevel! equ 0 (
    echo %GREEN%[OK] 7-Zip found at: !SEVEN_ZIP_PATH!%RESET%
) else (
    echo %RED%[FAIL] 7-Zip not found.%RESET%
)
echo.
set "LAST_ACTION_MSG=%GREEN%Prerequisites check complete.%RESET%"
pause
goto :main_menu

:check_prereqs
echo.
echo %BLUE%======================================================================%RESET%
echo %BLUE%                  Checking System Prerequisites                       %RESET%
echo %BLUE%======================================================================%RESET%
echo.
call :ensure_winget
call :ensure_git
call :ensure_7zip
call :install_vcredist_buildtools
echo %GREEN%All prerequisites are installed or installation has been initiated.%RESET%
goto :eof

:: --- ComfyUI Core Installation ---
:install_comfyui
echo.
echo %BLUE%======================================================================%RESET%
echo %BLUE%                     Installing ComfyUI Core                          %RESET%
echo %BLUE%======================================================================%RESET%
echo.
set "COMFYUI_ALREADY_EXISTS="
if exist "%COMFYUI_DIR%\run_nvidia_gpu.bat" (
    echo %GREEN%ComfyUI appears to be already installed.%RESET%
    set "COMFYUI_ALREADY_EXISTS=1"
    set "LAST_ACTION_MSG=%GREEN%ComfyUI was already installed.%RESET%"
    set "STATUS_COMFYUI=1"
    goto :eof
)
echo %YELLOW%Downloading ComfyUI v%COMFY_VER%...%RESET%
call :grab "ComfyUI_portable.7z" "%COMFY_RELEASE_URL%"
if %errorlevel% neq 0 (
    echo %RED%ComfyUI download failed. Aborting.%RESET%
    set "LAST_ACTION_MSG=%RED%ComfyUI download failed.%RESET%"
    pause
    exit /b 1
)
echo.
echo %YELLOW%Extracting ComfyUI...%RESET%
"%SEVEN_ZIP_PATH%" x "ComfyUI_portable.7z" -aoa -o"%CD%" -bsp1
if not exist "%COMFYUI_DIR%" (
    echo %RED%Extraction failed. Aborting.%RESET%
    set "LAST_ACTION_MSG=%RED%ComfyUI extraction failed.%RESET%"
    pause
    exit /b 1
)
echo %GREEN%ComfyUI Core extracted successfully.%RESET%
call :update_comfyui
call :configure_comfyui
call :install_server_manager
call :install_client_wrapper
set "LAST_ACTION_MSG=%GREEN%ComfyUI Core installed successfully.%RESET%"
set "STATUS_COMFYUI=1"
goto :eof

:configure_comfyui
:: Define the full output file path and a temporary file for decoding
SET "OUTPUT_FILE=%COMFYUI_DIR%\ComfyUI\user\default\comfy.settings.json"
SET "OUTPUT_FILE2=%COMFYUI_DIR%\ComfyUI\user\default\ComfyUI-Manager\config.ini"
SET "TEMP_B64_FILE=%TEMP%\comfy_settings.b64"
SET "TEMP_B64_FILE2=%TEMP%\comfy_manager_settings.b64"

echo.
echo %YELLOW%Creating default settings files...%RESET%

:: Ensure the target directory exists before creating the file
IF NOT EXIST "%COMFYUI_DIR%\ComfyUI\user\default\" mkdir "%COMFYUI_DIR%\ComfyUI\user\default\"
IF NOT EXIST "%COMFYUI_DIR%\ComfyUI\user\default\ComfyUI-Manager\" mkdir "%COMFYUI_DIR%\ComfyUI\user\default\ComfyUI-Manager\"

:: Write the Base64 string to a temporary file.
(echo ew0KICAgICJDb21meS5WYWxpZGF0aW9uLldvcmtmbG93cyI6IHRydWUsDQogICAgIkNvbWZ5LkV4dGVuc2lvbi5EaXNhYmxlZCI6IFsNCiAgICAgICAgInB5c3Nzc3MuTG9ja2luZyIsDQogICAgICAgICJweXNzc3NzLlNuYXBUb0dyaWQiLA0KICAgICAgICAicHlzc3Nzcy5JbWFnZUZlZWQiLA0KICAgICAgICAicHlzc3Nzcy5TaG93SW1hZ2VPbk1lbnUiLA0KICAgICAgICAicmd0aHJlZS5Ub3BNZW51Ig0KICAgIF0sDQogICAgInB5c3Nzc3MuTW9kZWxJbmZvLkNoZWNrcG9pbnROb2RlcyI6ICJDaGVja3BvaW50TG9hZGVyLmNrcHR_bmFtZSxDaGVja3BvaW50TG9hZGVyU2ltcGxlLENoZWNrcG9pbnRMb2FkZXJ8cHlzc3NzcyxFZmZpY2llbnQgTG9hZGVyLEVmZi4gTG9hZGVyIFNEWEwsdHROIHBpcGVMb2FkZXJfdjIsdHROIHBpcGVMb2FkZXJTRFhMX3YyLHR0TiB0aW55TG9hZGVyIiwNCiAgICAicHlzc3Nzcy5Nb2RlbEluZm8uTG9yYU5vZGVzIjogIkxvcmFMb2FkZXIubG9yYV9uYW1lLExvcmFMb2FkZXJ8cHlzc3NzcyxMb3JhTG9hZGVyTW9kZWxPbmx5LmxvcmFfbmFtZSxMb1JBIFN0YWNrZXIubG9yYV9uYW1lLiosdHROIEtTYW1wbGVyX3YyLHR0TiBwaXBlS1NhbXBsZXJfdjIsdHROIHBpcGVLU2FtcGxlckFkdmFuY2VkX3YyLHR0TiBwaXBlS1NhbXBsZXJTRFhMX3YyIiwNCiAgICAiQ29tZnkuU2lkZWJhci5TaXplIjogInNtYWxsIiwNCiAgICAiQ29tZnkuVXNlTmV3TWVudSI6ICJUb3AiLA0KICAgICJDb21meS5NaW5pbWFwLlZpc2libGUiOiBmYWxzZSwNCiAgICAiQ29tZnkuTW9kZWxMaWJyYXJ5Lk5hbWVGb3JtYXQiOiAidGl0bGUiLA0KICAgICJDb21meS5Xb3JrZmxvdy5Xb3JrZmxvd1RhYnNQb3NpdGlvbiI6ICJTaWRlYmFyIiwNCiAgICAiQ29tZnkuU25hcFRvR3JpZC5HcmlkU2l6ZSI6IDIwLA0KICAgICJweXNzc3NzLlNuYXBUb0dyaWQiOiB0cnVlLA0KICAgICJMaXRlR3JhcGguQ2FudmFzLkxvd1F1YWxpdHlSZW5kZXJpbmdab29tVGhyZXNob2xkIjogMC40LA0KICAgICJDb21meS5HcmFwaC5DYW52YXNJbmZvIjogZmFsc2UsDQogICAgIkNvbWZ5LkxpbmtSZW5kZXJNb2RlIjogMCwNCiAgICAiQ29tZnkuR3JhcGguTGlua01hcmtlcnMiOiAyLA0KICAgICJDb21meS5UZXh0YXJlYVdpZGdldC5Gb250U2l6ZSI6IDEyLA0KICAgICJDb21meS5TaWRlYmFyLlVuaWZpZWRXaWR0aCI6IHRydWUsDQogICAgInB5c3Nzc3MuTW9kZWxJbmZvLk5zZndMZXZlbCI6ICJYWFgiLA0KICAgICJLSk5vZGVzLmJyb3dzZXJTdGF0dXMiOiB0cnVlLA0KICAgICJDcnlzdG9vbHMuTW9uaXRvckhlaWdodCI6IDI4LA0KICAgICJDcnlzdG9vbHMuU2hvd0hkZCI6IHRydWUsDQogICAgIkNyeXN0b29scy5XaGljaEhkZCI6ICJDOlxcIg0KfQ==)>"%TEMP_B64_FILE%"
(echo W2RlZmF1bHRdCnByZXZpZXdfbWV0aG9kID0gdGFlc2QKZ2l0X2V4ZSA9IAp1c2VfdXYgPSBGYWxzZQpjaGFubmVsX3VybCA9IGh0dHBzOi8vcmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbS9sdGRyZGF0YS9Db21meVVJLU1hbmFnZXIvbWFpbgpzaGFyZV9vcHRpb24gPSBhbGwKYnlwYXNzX3NzbCA9IEZhbHNlCmZpbGVfbG9naW5nID0gVHJ1ZQpjb21wb25lbnRfcG9saWN5ID0gd29ya2Zsb3cKdXBkYXRlX3BvbGljeSA9IHN0YWJsZS1jb21meXVpCndpbmRvd3Nfc2VsZWN0b3JfZXZlbnRfbG9vcF9wb2xpY3kgPSBGYWxzZQptb2RlbF9kb3dubG9hZF9ieV9hZ2VudCA9IEZhbHNlCmRvd25ncmFkZV9ibGFja2xpc3QgPSAKc2VjdXJpdHlfbGV2ZWwgPSBub3JtYWwKYWx3YXlzX2xhenlfaW5zdGFsbCA9IEZhbHNlCm5ldHdvcmtfbW9kZSA9IHB1YmxpYwpkYl9tb2RlID0gY2FjaGU=)>"%TEMP_B64_FILE2%"

:: Use certutil to decode the temp file
certutil -f -decode "%TEMP_B64_FILE%" "%OUTPUT_FILE%" >nul
certutil -f -decode "%TEMP_B64_FILE2%" "%OUTPUT_FILE2%" >nul

:: Clean up
del "%TEMP_B64_FILE%"
del "%TEMP_B64_FILE2%"

SET ABSOLUTE_COMFYUI_DIR=%~dp0%COMFYUI_DIR%
SET TARGET_URL=http://127.0.0.1:8188/
SET TARGET_EXE=%ABSOLUTE_COMFYUI_DIR%\run_nvidia_gpu_fast_fp16_accumulation.bat
SET SERVER_ICON_FILE=%ABSOLUTE_COMFYUI_DIR%\ComfyUI\Comfy_Logo.ico
SET CLIENT_ICON_FILE=%ABSOLUTE_COMFYUI_DIR%\ComfyUI\Comfy_Client.ico
SET SERVER_SHORTCUT_NAME=ComfyUI Server.lnk
SET CLIENT_SHORTCUT_NAME=ComfyUI Client.lnk
SET EDGE_PATH=C:\Progra~2\Microsoft\Edge\Application\msedge.exe

:: --- Create Server Shortcuts (only if Server Manager is NOT installed) ---
if "%INSTALL_SERVER_MANAGER%"=="0" (
    echo.
    echo %YELLOW%Creating Server Desktop and Start Menu shortcuts...%RESET%

    call :grab "%SERVER_ICON_FILE%" "https://github.com/Comfy-Org/desktop/raw/refs/heads/main/assets/UI/Comfy_Logo.ico"

    powershell.exe -NoProfile -Command "$ws = New-Object -ComObject WScript.Shell; $DesktopPath = [Environment]::GetFolderPath('Desktop'); $ShortcutPath = Join-Path -Path $DesktopPath -ChildPath '%SERVER_SHORTCUT_NAME%'; $s = $ws.CreateShortcut($ShortcutPath); $s.TargetPath = 'C:\Windows\System32\cmd.exe'; $s.Arguments = '/c \"%TARGET_EXE%\"'; $s.WorkingDirectory = '%ABSOLUTE_COMFYUI_DIR%'; $s.IconLocation = '%SERVER_ICON_FILE%,0'; $s.WindowStyle = 7; $s.Save()"
    powershell.exe -NoProfile -Command "$ws = New-Object -ComObject WScript.Shell; $StartMenuPath = [Environment]::GetFolderPath('Programs'); $ShortcutPath = Join-Path -Path $StartMenuPath -ChildPath '%SERVER_SHORTCUT_NAME%'; $s = $ws.CreateShortcut($ShortcutPath); $s.TargetPath = 'C:\Windows\System32\cmd.exe'; $s.Arguments = '/c \"%TARGET_EXE%\"'; $s.WorkingDirectory = '%ABSOLUTE_COMFYUI_DIR%'; $s.IconLocation = '%SERVER_ICON_FILE%,0'; $s.WindowStyle = 7; $s.Save()"
) else (
    echo.
    echo %PURPLE%[INFO] Skipping server shortcut creation because the Server Manager is being installed.%RESET%
)

:: --- Create Client Shortcuts (only if Client Wrapper is NOT installed) ---
if "%INSTALL_CLIENT_WRAPPER%"=="0" (
    echo.
    echo %YELLOW%Creating Client Desktop and Start Menu shortcuts...%RESET%
    call :grab "%CLIENT_ICON_FILE%" "https://drive.usercontent.google.com/download?id=1ehBRfElOe-v-zHQTKoCRInkzL8HBtYBZ&export=download&authuser=0&confirm=t&uuid=bc713c44-c765-4a89-a212-1b2ba8016a15&at=AN8xHoqQo2CQKoir69Qmh2iGscvg:1756246657739"

    powershell.exe -NoProfile -Command "$ws = New-Object -ComObject WScript.Shell; $DesktopPath = [Environment]::GetFolderPath('Desktop'); $ShortcutPath = Join-Path -Path $DesktopPath -ChildPath '%CLIENT_SHORTCUT_NAME%'; $s = $ws.CreateShortcut($ShortcutPath); $s.TargetPath = '%EDGE_PATH%'; $s.Arguments = '--app=%TARGET_URL%'; $s.IconLocation = '%CLIENT_ICON_FILE%'; $s.Save()"
    powershell.exe -NoProfile -Command "$ws = New-Object -ComObject WScript.Shell; $StartMenuPath = [Environment]::GetFolderPath('Programs'); $ShortcutPath = Join-Path -Path $StartMenuPath -ChildPath '%CLIENT_SHORTCUT_NAME%'; $s = $ws.CreateShortcut($ShortcutPath); $s.TargetPath = '%EDGE_PATH%'; $s.Arguments = '--app=%TARGET_URL%'; $s.IconLocation = '%CLIENT_ICON_FILE%'; $s.Save()"
) else (
    echo.
    echo %PURPLE%[INFO] Skipping server shortcut creation because the Server Manager is being installed.%RESET%
)

echo %GREEN%ComfyUI configuration complete!%RESET%
echo.
set "LAST_ACTION_MSG=%GREEN%ComfyUI configuration complete!%RESET%
goto :eof

:: --- Install Server Manager ---
:install_server_manager
if "%INSTALL_SERVER_MANAGER%"=="0" (
    echo %PURPLE%[INFO] Skipping Server Manager installation as per user setting.%RESET%
    goto :eof
)
echo.
echo %BLUE%======================================================================%RESET%
echo %BLUE%                 Installing ComfyUI Server Manager                    %RESET%
echo %BLUE%======================================================================%RESET%
echo.
echo %YELLOW%Downloading Server Manager installer...%RESET%
call :grab "%SERVER_MANAGER_MSI_NAME%" "%SERVER_MANAGER_URL%"
if %errorlevel% neq 0 (
    echo %RED%Server Manager download failed. Skipping installation.%RESET%
    set "LAST_ACTION_MSG=%RED%Server Manager download failed.%RESET%"
    goto :eof
)

echo %YELLOW%Starting Server Manager installation (will run in background)...%RESET%
cmd /c start "MSI Installer" msiexec /i "%SERVER_MANAGER_MSI_NAME%" /qb

echo %GREEN%Server Manager installation has been launched.%RESET%
echo %PURPLE%You may need to approve a UAC prompt for the installation.%RESET%
goto :eof

:: --- Install Client Wrapper ---
:install_client_wrapper
if "%INSTALL_CLIENT_WRAPPER%"=="0" (
    echo %PURPLE%[INFO] Skipping Client Wrapper installation as per user setting.%RESET%
    goto :eof
)
echo.
echo %BLUE%======================================================================%RESET%
echo %BLUE%                 Installing ComfyUI Client Wrapper                    %RESET%
echo %BLUE%======================================================================%RESET%
echo.
echo %YELLOW%Downloading Client Wrapper installer...%RESET%
call :grab "%CLIENT_WRAPPER_MSI_NAME%" "%CLIENT_WRAPPER_URL%"
if %errorlevel% neq 0 (
    echo %RED%Client Wrapper download failed. Skipping installation.%RESET%
    set "LAST_ACTION_MSG=%RED%Client Wrapper download failed.%RESET%"
    goto :eof
)

echo %YELLOW%Starting Client Wrapper installation (will run in background)...%RESET%
cmd /c start "MSI Installer" msiexec /i "%CLIENT_WRAPPER_MSI_NAME%" /qb

echo %GREEN%Client Wrapper installation has been launched.%RESET%
echo %PURPLE%You may need to approve a UAC prompt for the installation.%RESET%
goto :eof

:: --- ComfyUI Update Function ---
:update_comfyui
echo.
echo %BLUE%======================================================================%RESET%
echo %BLUE%                Updating ComfyUI to the latest version                %RESET%
echo %BLUE%======================================================================%RESET%
echo.
if not exist "%COMFYUI_DIR%\update\update_comfyui.bat" (
    echo %PURPLE%[WARN] Update script not found. Skipping update.%RESET%
    goto :eof
)
pushd "%COMFYUI_DIR%\update"
call update_comfyui.bat
popd
echo %GREEN%ComfyUI update process complete.%RESET%
goto :eof

:: --- Python Packages Installation ---
:install_core_python_packages
echo.
echo %BLUE%======================================================================%RESET%
echo %BLUE%            Installing Core Python Packages (InsightFace, etc.)       %RESET%
echo %BLUE%======================================================================%RESET%
echo.
if not exist "%PYTHON_EXE%" (
    echo %RED%ComfyUI not found. Please run Core Install first.%RESET%
    set "LAST_ACTION_MSG=%RED%Python not found. Could not install packages.%RESET%"
    pause
    goto :main_menu
)
pushd "%COMFYUI_DIR%\python_embeded"

echo %YELLOW%Determining Python version...%RESET%
for /f "tokens=2 delims= " %%A in ('python.exe --version') do set "PYTHON_VERSION=%%A"
for /f "tokens=1,2 delims=." %%a in ("!PYTHON_VERSION!") do set "PYTHON_MAJOR_MINOR=%%a.%%b"
echo %YELLOW%Detected Python version: !PYTHON_MAJOR_MINOR!%RESET%

set "PYTHON_VER_STRIPPED=!PYTHON_MAJOR_MINOR:.=!"
set "WHL_FILE=insightface-0.7.3-cp!PYTHON_VER_STRIPPED!-cp!PYTHON_VER_STRIPPED!-win_amd64.whl"
set "WHL_URL=https://huggingface.co/hanamizuki-ai/insightface-releases/resolve/main/!WHL_FILE!"

echo %YELLOW%Downloading !WHL_FILE!...%RESET%
call :grab "!WHL_FILE!" "!WHL_URL!"
if %errorlevel% neq 0 ( echo %RED%Download failed.%RESET% & popd & goto :eof )

echo %YELLOW%Installing packages...%RESET%
python.exe -m pip install --upgrade pip
python.exe -m pip install cython
python.exe -m pip install --use-pep517 facexlib
python.exe -m pip install git+https://github.com/rodjjo/filterpy.git
python.exe -m pip install onnxruntime onnxruntime-gpu "!WHL_FILE!"
python.exe -m pip uninstall -y opencv-python opencv-python-headless
python.exe -m pip install opencv-python opencv-python-headless
python.exe -m pip install xformers torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu128
python.exe -m pip install https://github.com/nunchaku-tech/nunchaku/releases/download/v1.0.0dev20250823/nunchaku-1.0.0.dev20250823+torch2.8-cp312-cp312-win_amd64.whl
python.exe -m pip install https://github.com/eswarthammana/llama-cpp-wheels/releases/download/v0.3.16/llama_cpp_python-0.3.16-cp312-cp312-win_amd64.whl

echo %YELLOW%Cleaning up files...%RESET%
del "!WHL_FILE!"
del "%SERVER_MANAGER_MSI_NAME%" 2>nul
del "%CLIENT_WRAPPER_MSI_NAME%" 2>nul

popd
echo %GREEN%Core Python packages installed.%RESET%
goto :eof

:: --- Custom Nodes Installation ---
:install_nodes
echo.
echo %BLUE%======================================================================%RESET%
echo %BLUE%                     Installing Custom Nodes                          %RESET%
echo %BLUE%======================================================================%RESET%
echo.
if not exist "%CUSTOM_NODES_DIR%" (
    echo %RED%Custom nodes directory not found. Is ComfyUI installed?%RESET%
    set "LAST_ACTION_MSG=%RED%Could not install nodes: ComfyUI not found.%RESET%"
    pause
    goto :eof
)
pushd "%CUSTOM_NODES_DIR%"

for /l %%G in (1,1,99) do (
    set "num=0%%G"
    set "num=!num:~-2!"
    if defined NODE_URL_!num! (
        call set "CURRENT_URL=%%NODE_URL_!num!%%"
        call :clone_and_install_reqs
    )
)

popd

echo %YELLOW%Applying numpy version constraint...%RESET%
"%PYTHON_EXE%" -m pip install "numpy<2"

echo %GREEN%Custom node installation process complete.%RESET%
echo.
set "LAST_ACTION_MSG=%GREEN%Custom Nodes installation process finished.%RESET%"
set "STATUS_NODES=1"
goto :eof

:: --- Model Installation Logic ---
:install_models
set "models_were_selected=false"
for /l %%G in (1,1,99) do (
    set "num=0%%G"
    set "num=!num:~-2!"
    if defined MODEL_!num!_NAME (
        for /l %%H in (1,1,9) do (
            if defined MODEL_!num!_OPT_%%H_INSTALL set "models_were_selected=true"
        )
    )
)
if "!models_were_selected!"=="false" (
    echo %PURPLE%No models selected. Please use Option 'S' from the main menu to select models and quality first.%RESET%
    set "LAST_ACTION_MSG=%PURPLE%Model installation skipped: No models or quality were selected.%RESET%"
    pause
    goto :eof
)
call :download_selected_models
call :silent_verify_all
goto :eof

:download_selected_models
echo.
echo %BLUE%======================================================================%RESET%
echo %BLUE%                  Downloading All Selected Models                     %RESET%
echo %BLUE%======================================================================%RESET%
echo.
pushd "%MODELS_DIR%"
echo %YELLOW%This may take a very long time. Please be patient...%RESET%
echo.

:: ============================================================================
:: Section to set flags based on selected model families
:: ============================================================================
set "FLAG_FLUX_SELECTED="
set "FLAG_QWEN_SELECTED="
set "FLAG_HIDREAM_SELECTED="
set "FLAG_SD15_SELECTED="
set "FLAG_SDXL_SELECTED="
set "FLAG_SD3_SELECTED="
set "FLAG_WAN21_SELECTED="
set "FLAG_WAN22_SELECTED="

for /l %%G in (1,1,99) do (
    set "num=0%%G"
    set "num=!num:~-2!"
    if defined MODEL_!num!_NAME (
        set "family_member_selected=false"
        for /l %%H in (1,1,9) do (
            if defined MODEL_!num!_OPT_%%H_INSTALL set "family_member_selected=true"
        )
        if "!family_member_selected!"=="true" (
            call set "MODEL_FAMILY_NAME=%%MODEL_!num!_NAME%%"
            echo !MODEL_FAMILY_NAME! | findstr /i "FLUX" >nul   && set "FLAG_FLUX_SELECTED=1"
            echo !MODEL_FAMILY_NAME! | findstr /i "Qwen" >nul   && set "FLAG_QWEN_SELECTED=1"
            echo !MODEL_FAMILY_NAME! | findstr /i "HiDream" >nul&& set "FLAG_HIDREAM_SELECTED=1"
            echo !MODEL_FAMILY_NAME! | findstr /i "SD1.5" >nul&& set "FLAG_SD15_SELECTED=1"
            echo !MODEL_FAMILY_NAME! | findstr /i "SDXL" >nul   && set "FLAG_SDXL_SELECTED=1"
            echo !MODEL_FAMILY_NAME! | findstr /i "SD3" >nul    && set "FLAG_SD3_SELECTED=1"
            echo !MODEL_FAMILY_NAME! | findstr /i "WAN2.1" >nul && set "FLAG_WAN21_SELECTED=1"
            echo !MODEL_FAMILY_NAME! | findstr /i "WAN2.2" >nul && set "FLAG_WAN22_SELECTED=1"
        )
    )
)
echo.
:: ============================================================================

for /l %%G in (1,1,99) do (
    set "num=0%%G"
    set "num=!num:~-2!"
    if defined MODEL_!num!_NAME (
        rem -- Use %%I for the inner loop to avoid conflict with 'H' in variable names --
        for /l %%I in (1,1,9) do (
            if defined MODEL_!num!_OPT_%%I_INSTALL (
                call set "MODEL_NAME=%%MODEL_!num!_NAME%%"
                call set "FILENAME=%%MODEL_!num!_OPT_%%I_FILE%%"
                call set "FILETYPE=%%MODEL_!num!_OPT_%%I_TYPE%%"
                call set "DOWNLOAD_URL=%%MODEL_!num!_OPT_%%I_URL%%"

                set "display_msg=!YELLOW!Downloading !MODEL_NAME!...%RESET%"
                for /f "delims=" %%p in ("!display_msg!") do echo(%%p

                if "!FILETYPE!"=="gguf" (
                    call :grab "unet\!FILENAME!" "!DOWNLOAD_URL!"
                )
                if "!FILETYPE!"=="gguf_flux" (
                    call :grab "unet\!FILENAME!" "!DOWNLOAD_URL!"
                    rem Also grab the associated text encoder for Flux models
                    call set "FLUX_ENCODER=%%MODEL_01_OPT_%%I_ENC%%"
                    if defined FLUX_ENCODER call :grab "clip\t5-v1_1-xxl-encoder-!FLUX_ENCODER!.gguf" "%HF_FLX_URL%/t5-v1_1-xxl-encoder-!FLUX_ENCODER!.gguf?download=true"
                )
                if "!FILETYPE!"=="checkpoint" (
                    call :grab "checkpoints\!FILENAME!" "!DOWNLOAD_URL!"
                )
                 if "!FILETYPE!"=="checkpoints" (
                    call :grab "checkpoints\!FILENAME!" "!DOWNLOAD_URL!"
                )
                if "!FILETYPE!"=="diffusion_model" (
                    call :grab "diffusion_models\!FILENAME!" "!DOWNLOAD_URL!"
                )
                 if "!FILETYPE!"=="lora" (
                    call :grab "loras\!FILENAME!" "!DOWNLOAD_URL!"
                )
            )
        )
    )
)
call :download_shared_models
popd
echo %GREEN%Model download process complete.%RESET%
set "LAST_ACTION_MSG=%GREEN%Selected models were downloaded successfully.%RESET%"
set "STATUS_MODELS=1"
goto :eof

:download_shared_models
echo.
echo %BLUE%======================================================================%RESET%
echo %BLUE%        Downloading Supporting Models (VAEs, Upscalers, etc.)         %RESET%
echo %BLUE%======================================================================%RESET%
echo.

:: --- Loop through the shared/extra models configuration ---
for /l %%E in (1,1,999) do (
    set "num=00%%E" & set "num=!num:~-3!"
    if defined EXTRA_!num!_FLAG (
        call set "MODEL_FLAG=%%EXTRA_!num!_FLAG%%"
        set "is_needed=false"

        :: Check if the model should always be downloaded
        if "!MODEL_FLAG!"=="ALWAYS" (
            set "is_needed=true"
        ) else (
            :: Check if the flag for the corresponding model family is set
            set "FAMILY_FLAG_VAR=FLAG_!MODEL_FLAG!_SELECTED"
            if defined !FAMILY_FLAG_VAR! (
                set "is_needed=true"
            )
        )

        :: If the model is needed, download it
        if "!is_needed!"=="true" (
            call set "DEST_SUBDIR=%%EXTRA_!num!_PATH%%"
            call set "FILENAME=%%EXTRA_!num!_FILE%%"
            call set "DOWNLOAD_URL=%%EXTRA_!num!_URL%%"

            echo %YELLOW%--- Downloading support file for !MODEL_FLAG!: !FILENAME!%RESET%
            call :grab "!DEST_SUBDIR!\!FILENAME!" "!DOWNLOAD_URL!"
        )
    )
)

echo.
echo %YELLOW%--- Cloning Repo-based Models (InsightFace, Florence, etc.)...%RESET%
if not exist "insightface" git clone %HF_BASE_URL%/insightface
if not exist "llm\Florence-2-base" git clone %HF_BASE_URL%/Florence-2-base LLM\Florence-2-base
if not exist "llm\Florence-2-large" git clone %HF_BASE_URL%/Florence-2-large LLM\Florence-2-large

goto :eof

:: --- Triton and Sage Attention Installation ---
:install_triton_sage
echo.
echo %BLUE%======================================================================%RESET%
echo %BLUE%                Installing Triton and Sage Attention                  %RESET%
echo %BLUE%======================================================================%RESET%
echo.
if not exist "%PYTHON_EXE%" (
    echo %RED%ComfyUI not found. Please run Core Install first.%RESET%
    set "LAST_ACTION_MSG=%RED%Triton/Sage install failed: ComfyUI not found.%RESET%"
    pause
    goto :eof
)
echo %YELLOW%Checking for Visual C++ Redistributable...%RESET%
reg query "HKLM\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64" /v Version >nul 2>&1
if %errorlevel% neq 0 (
    echo %PURPLE%[WARN] VC++ Redistributable not detected. If Triton fails, please ensure prerequisites are installed.%RESET%
)
echo %YELLOW%Upgrading pip...%RESET%
"%PYTHON_EXE%" -m pip install --upgrade pip
echo %YELLOW%Installing Triton...%RESET%
"%PYTHON_EXE%" -m pip install -U --pre triton-windows
if %errorlevel% neq 0 (
    echo %RED%Triton installation failed. Please ensure VC++ Redistributable is installed.%RESET%
    set "LAST_ACTION_MSG=%RED%Triton installation failed.%RESET%"
    pause
    goto :eof
)
echo %YELLOW%Installing Sage Attention...%RESET%
"%PYTHON_EXE%" -m pip install -U https://github.com/woct0rdho/SageAttention/releases/download/v2.2.0-windows.post2/sageattention-2.2.0+cu128torch2.8.0.post2-cp39-abi3-win_amd64.whl
if %errorlevel% neq 0 (
    echo %RED%Sage Attention installation failed.%RESET%
    set "LAST_ACTION_MSG=%RED%Sage Attention installation failed.%RESET%"
    pause
    goto :eof
)
echo %GREEN%Triton and Sage Attention installed successfully.%RESET%
echo.
echo %YELLOW%Applying '--use-sage-attention' flag to run scripts...%RESET%
call :update_run_scripts
echo.
set "LAST_ACTION_MSG=%GREEN%Triton and Sage Attention installed and enabled.%RESET%"
set "STATUS_TRITON=1"
goto :eof


:: --- Python Libs/Includes Setup ---
:setup_python_libs
echo.
echo %BLUE%======================================================================%RESET%
echo %BLUE%                  Setting up Python Include Libs                      %RESET%
echo %BLUE%======================================================================%RESET%
echo.
if not exist "%COMFYUI_DIR%" (
    echo %RED%ComfyUI not found. Please run Core Install first.%RESET%
    set "LAST_ACTION_MSG=%RED%Python Libs setup failed: ComfyUI not found.%RESET%"
    pause
    goto :eof
)
pushd "%COMFYUI_DIR%"
echo %YELLOW%Downloading include and libs folders...%RESET%
powershell -Command "Invoke-WebRequest -Uri 'https://github.com/woct0rdho/triton-windows/releases/download/v3.0.0-windows.post1/python_3.12.7_include_libs.zip' -OutFile 'libs_include.zip'; Expand-Archive -Path 'libs_include.zip' -DestinationPath 'python_embeded' -Force; Remove-Item 'libs_include.zip'"
if exist "python_embeded\libs" if exist "python_embeded\include" (
    echo %GREEN%Successfully installed include and libs folders.%RESET%
    set "LAST_ACTION_MSG=%GREEN%Python include libs folders installed successfully.%RESET%"
    set "STATUS_LIBS=1"
) else (
    echo %RED%Failed to download or extract folders. Please do it manually.%RESET%
    set "LAST_ACTION_MSG=%RED%Failed to install Python include libs folders.%RESET%"
    set "STATUS_LIBS=0"
)
popd
echo.
goto :eof


:: --- Update Run Scripts ---
:update_run_scripts
echo.
echo %BLUE%======================================================================%RESET%
echo %BLUE%                     Adding Updates to Run Scripts                    %RESET%
echo %BLUE%======================================================================%RESET%
echo.
if not exist "%COMFYUI_DIR%" (
    echo %RED%ComfyUI directory not found.%RESET%
    goto :eof
)
set "TARGET_ARG=--use-sage-attention --highvram --dont-launch-browser"
set "SEARCH_LINE=ComfyUI\main.py"

for %%F in (run_nvidia_gpu.bat run_nvidia_gpu_fast_fp16_accumulation.bat) do (
    set "FILE_PATH=%COMFYUI_DIR%\%%F"
    if exist "!FILE_PATH!" (
        echo %YELLOW%Updating !FILE_PATH!...%RESET%
        set "updated=false"
        (for /f "usebackq tokens=* delims=" %%L in ("!FILE_PATH!") do (
            set "line=%%L"
            echo !line! | findstr /c:"%SEARCH_LINE%" >nul
            if !errorlevel! equ 0 (
                echo !line! | findstr /c:"--use-sage-attention" >nul
                if !errorlevel! neq 0 (
                    echo !line! %TARGET_ARG%
                    set "updated=true"
                ) else (
                    echo !line!
                )
            ) else (
                echo !line!
            )
        )) > "!FILE_PATH!.tmp"

        move /y "!FILE_PATH!.tmp" "!FILE_PATH!" >nul
        if "!updated!"=="true" (
            echo %GREEN%   Added '%TARGET_ARG%'.%RESET%
        ) else (
            echo %PURPLE%   Argument already present or line not found. No changes made.%RESET%
        )
    ) else (
        echo %PURPLE%[WARN] Could not find %%F. Skipping.%RESET%
    )
)
goto :eof

:: --- Verification Routines ---
:silent_verify_all
call :verify_prereqs >nul 2>&1
call :verify_comfyui >nul 2>&1
call :verify_nodes >nul 2>&1
call :verify_models >nul 2>&1
call :verify_python_packages >nul 2>&1
call :verify_run_scripts >nul 2>&1
goto :eof

:verify_all
echo.
echo %BLUE%======================================================================%RESET%
echo %BLUE%                     Verifying All Components                         %RESET%
echo %BLUE%======================================================================%RESET%
echo.
call :verify_prereqs
call :verify_comfyui
call :verify_nodes
call :verify_models
call :verify_python_packages
call :verify_run_scripts
call :calculate_total_size
echo.
echo %GREEN%======================================================================%RESET%
echo %GREEN%                       Verification Complete                          %RESET%
echo %GREEN%======================================================================%RESET%
echo.
set "LAST_ACTION_MSG=%GREEN%Full verification process complete. Status checkmarks updated.%RESET%"
goto :main_menu

:verify_prereqs
echo %YELLOW%Verifying Prerequisites...%RESET%
git --version >nul 2>&1 && (echo %GREEN%[OK] Git%RESET%) || (echo %RED%[FAIL] Git%RESET%)
call :find_7zip >nul && (echo %GREEN%[OK] 7-Zip%RESET%) || (echo %RED%[FAIL] 7-Zip%RESET%)
echo.
goto :eof

:verify_comfyui
echo %YELLOW%Verifying ComfyUI Core...%RESET%
if not exist "%COMFYUI_DIR%\run_nvidia_gpu.bat" (
    echo %RED%[FAIL] ComfyUI directory structure not found.%RESET%
    set "STATUS_COMFYUI=0"
    goto :eof
)
echo %GREEN%[OK] ComfyUI directory structure%RESET%
set "STATUS_COMFYUI=1"
echo.
goto :eof

:verify_nodes
echo %YELLOW%Verifying Custom Nodes...%RESET%
if exist "%CUSTOM_NODES_DIR%\ComfyUI-Manager" (
    echo %GREEN%[OK] ComfyUI-Manager found.%RESET%
    set "STATUS_NODES=1"
) else (
    echo %RED%[FAIL] ComfyUI-Manager not found.%RESET%
    set "STATUS_NODES=0"
)
echo.
goto :eof

:verify_models
echo %YELLOW%Verifying Models...%RESET%

set "any_model_family_selected=false"
for /l %%G in (1,1,99) do (
    set "num=0%%G" & set "num=!num:~-2!"
    if defined MODEL_!num!_NAME (
        call set "is_selected=%%SELECT_MODEL_!num!%%"
        if "!is_selected!"=="1" set "any_model_family_selected=true"
    )
)

if "!any_model_family_selected!"=="false" (
    echo %PURPLE%[SKIP] No model families have been selected. Cannot verify models.%RESET%
    set "STATUS_MODELS=0"
    goto :eof
)
if "!SELECTED_QUALITY_NAME!"=="None" (
    echo %PURPLE%[SKIP] No model quality has been selected. Cannot verify models.%RESET%
    set "STATUS_MODELS=0"
    goto :eof
)

echo %YELLOW%Checking for files based on '!SELECTED_QUALITY_NAME!' selection...%RESET%
set "all_models_found=1"
for /l %%G in (1,1,99) do (
    set "num=0%%G"
    set "num=!num:~-2!"
    if defined MODEL_!num!_NAME (
        for /l %%I in (1,1,9) do (
            if defined MODEL_!num!_OPT_%%I_INSTALL (
                call set "FILENAME=%%MODEL_!num!_OPT_%%I_FILE%%"
                call set "FILETYPE=%%MODEL_!num!_OPT_%%I_TYPE%%"

                set "TARGET_DIR="
                if /i "!FILETYPE!"=="gguf" ( set "TARGET_DIR=unet" )
                if /i "!FILETYPE!"=="gguf_flux" ( set "TARGET_DIR=unet" )
                if /i "!FILETYPE!"=="checkpoint" ( set "TARGET_DIR=checkpoints" )
                if /i "!FILETYPE!"=="checkpoints" ( set "TARGET_DIR=checkpoints" )
                if /i "!FILETYPE!"=="diffusion_model" ( set "TARGET_DIR=diffusion_models" )
                if /i "!FILETYPE!"=="lora" ( set "TARGET_DIR=loras" )

                if defined TARGET_DIR (
                    set "FILE_PATH=!MODELS_DIR!\!TARGET_DIR!\!FILENAME!"
                    if exist "!FILE_PATH!" (
                        echo %GREEN%  [FOUND] !FILENAME!%RESET%
                    ) else (
                        echo %RED%  [MISSING] !FILENAME! ^(expected in !TARGET_DIR!^)%RESET%
                        set "all_models_found=0"
                    )
                )
            )
        )
    )
)

if "!all_models_found!"=="1" (
    echo %GREEN%[OK] All expected model files were found.%RESET%
    set "STATUS_MODELS=1"
) else (
    echo %RED%[FAIL] One or more model files are missing.%RESET%
    set "STATUS_MODELS=0"
)
echo.
goto :eof

:verify_python_packages
echo %YELLOW%Verifying Python Packages...%RESET%
if not exist "%PYTHON_EXE%" (
    echo %PURPLE%[SKIP] Python executable not found. Cannot verify packages.%RESET%
    goto :eof
)
"%PYTHON_EXE%" -m pip list | findstr /i "triton-windows" >nul
if !errorlevel! equ 0 (
    echo %GREEN%[OK] Triton package installed.%RESET%
    set "STATUS_TRITON=1"
) else (
    echo %RED%[FAIL] Triton package not found.%RESET%
    set "STATUS_TRITON=0"
)

"%PYTHON_EXE%" -m pip list | findstr /i "sageattention" >nul
if !errorlevel! equ 0 (
    echo %GREEN%[OK] Sage Attention package installed.%RESET%
    if !STATUS_TRITON! equ 1 set "STATUS_TRITON=1"
) else (
    echo %RED%[FAIL] Sage Attention package not found.%RESET%
    set "STATUS_TRITON=0"
)

if exist "%COMFYUI_DIR%\python_embeded\libs" (
    echo %GREEN%[OK] python_embeded\libs folder exists.%RESET%
    set "STATUS_LIBS=1"
) else (
    echo %RED%[FAIL] python_embeded\libs folder not found.%RESET%
    set "STATUS_LIBS=0"
)
if exist "%COMFYUI_DIR%\python_embeded\include" (
    echo %GREEN%[OK] python_embeded\include folder exists.%RESET%
    if !STATUS_LIBS! equ 1 set "STATUS_LIBS=1"
) else (
    echo %RED%[FAIL] python_embeded\include folder not found.%RESET%
    set "STATUS_LIBS=0"
)
echo.
goto :eof

:verify_run_scripts
echo %YELLOW%Verifying Run Scripts...%RESET%
findstr /c:"--use-sage-attention" "%COMFYUI_DIR%\run_nvidia_gpu.bat" >nul
if !errorlevel! equ 0 (
    echo %GREEN%[OK] run_nvidia_gpu.bat is configured for Sage Attention.%RESET%
) else (
    echo %RED%[FAIL] run_nvidia_gpu.bat is NOT configured for Sage Attention.%RESET%
)
echo.
goto :eof

:: -----------------------------------------------------------------------------
:: Section 4: Helper Functions
:: -----------------------------------------------------------------------------

:ensure_winget
winget --version > nul 2>&1
if %errorlevel% neq 0 (
    echo %PURPLE%[WARN] Winget is not installed. Attempting to install...%RESET%
    curl -L -o "%temp%\winget.msixbundle" "https://github.com/microsoft/winget-cli/releases/download/v1.6.2771/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" --ssl-no-revoke
    start "" "%temp%\winget.msixbundle"
    echo %YELLOW%Please complete the Winget installation and re-run this script if needed.%RESET%
    pause
) else (
    echo %GREEN%[OK] Winget is installed.%RESET%
)
goto :eof

:install_vcredist_buildtools
echo %YELLOW%Installing Microsoft VC++ Redistributables and Build Tools via Winget...%RESET%
winget install -e --id Microsoft.VCRedist.2015+.x64
winget install -e --id Microsoft.VCRedist.2015+.x86
curl -L -o "%temp%\vs_buildtools.exe" "https://aka.ms/vs/17/release/vs_BuildTools.exe" --ssl-no-revoke
start "" "%temp%\vs_buildtools.exe" --norestart --passive --downloadThenInstall --includeRecommended --add Microsoft.VisualStudio.Workload.NativeDesktop --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Workload.MSBuildTools
echo %PURPLE%The Build Tools installation will proceed in the background.%RESET%
goto :eof

:find_7zip
set "SEVEN_ZIP_PATH="
for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe" /ve 2^>nul') do (
    if /i "%%a"=="(Default)" set "SEVEN_ZIP_PATH=%%~dpb7z.exe"
)
if defined SEVEN_ZIP_PATH if exist "!SEVEN_ZIP_PATH!" exit /b 0
if exist "%ProgramW6432%\7-Zip\7z.exe" (set "SEVEN_ZIP_PATH=%ProgramW6432%\7-Zip\7z.exe" & exit /b 0)
if exist "%ProgramFiles(x86)%\7-Zip\7z.exe" (set "SEVEN_ZIP_PATH=%ProgramFiles(x86)%\7-Zip\7z.exe" & exit /b 0)
for %%I in (7z.exe) do set "SEVEN_ZIP_PATH=%%~$PATH:I"
if defined SEVEN_ZIP_PATH if exist "!SEVEN_ZIP_PATH!" exit /b 0
exit /b 1

:ensure_7zip
call :find_7zip
if !errorlevel! equ 0 (
    echo %GREEN%[OK] 7-Zip found at: !SEVEN_ZIP_PATH!%RESET%
    goto :eof
)
echo %PURPLE%7-Zip not found – attempting to download and install...%RESET%
call :grab "7z-installer.exe" "https://www.7-zip.org/a/7z%SEVEN_VER%-x64.exe"
if !errorlevel! neq 0 ( echo %RED%Download failed.%RESET% & pause & exit /b 1 )
start /wait "" 7z-installer.exe /S
del "7z-installer.exe"
call :find_7zip
if %errorlevel! neq 0 (
    echo %RED%7-Zip install failed. Please install it manually.%RESET%
    pause & exit /b 1
)
echo %GREEN%7-Zip installed successfully.%RESET%
goto :eof

:ensure_git
git --version >nul 2>&1 && (echo %GREEN%[OK] Git is installed.%RESET% & goto :eof)
echo %PURPLE%Git not found – downloading silent installer...%RESET%
call :grab "git-setup.exe" "https://github.com/git-for-windows/git/releases/download/v%GIT_VER%/Git-%GIT_VER%-64-bit.exe"
start /wait "" git-setup.exe /VERYSILENT
del git-setup.exe
git --version >nul 2>&1 || (echo %RED%Git install failed. Please install manually.%RESET% & pause & exit /b 1)
echo %GREEN%Git installed successfully.%RESET%
goto :eof

:clone_and_install_reqs
set "REPO_URL=!CURRENT_URL!"
for /f "tokens=*" %%a in ("!REPO_URL!") do set "REPO_NAME=%%~na"

if exist "!REPO_NAME!" (
    echo %PURPLE%[SKIP] !REPO_NAME! already exists.%RESET%
) else (
    echo %YELLOW%Cloning !REPO_NAME!...%RESET%
    git clone "!REPO_URL!" >nul 2>&1
    if !errorlevel! neq 0 (
        echo %RED%[ERROR] Failed to clone !REPO_NAME!.%RESET%
    ) else (
        if exist "!REPO_NAME!\requirements.txt" (
            echo %YELLOW%  Installing requirements for !REPO_NAME!...%RESET%
            "%PYTHON_EXE%" -m pip install -r "!REPO_NAME!\requirements.txt" --no-warn-script-location >nul
        )
    )
)
goto :eof

:grab
set "DEST_PATH=%~1"
set "DOWNLOAD_URL=%~2"
for %%F in ("%DEST_PATH%") do set "FILENAME=%%~nxF" & set "DIR_PATH=%%~dpF"
if not exist "!DIR_PATH!" mkdir "!DIR_PATH!"


set "MAX_RETRIES=3"
set "RETRY_COUNT=0"

:grab_loop
set /a RETRY_COUNT+=1
if !RETRY_COUNT! gtr 1 (
    <nul set /p "=%YELLOW%  Retrying download (!RETRY_COUNT!/%MAX_RETRIES%)...%RESET%"
    echo.
    timeout /t 3 >nul
) else (
    if exist "%DEST_PATH%" (
        <nul set /p "=%PURPLE%  Resuming !FILENAME!...%RESET%"
    ) else (
        <nul set /p "=%GREEN%  Downloading !FILENAME!...%RESET%"
    )
    echo.
)

curl -C - -# -L -o "%DEST_PATH%" "%DOWNLOAD_URL%" --ssl-no-revoke
if !errorlevel! equ 0 (
    exit /b 0
)

if !RETRY_COUNT! lss %MAX_RETRIES% (
    goto :grab_loop
)

echo %RED%[ERROR] Download failed for %FILENAME% after %MAX_RETRIES% attempts.%RESET%
del "%DEST_PATH%" 2>nul
exit /b 1

:: -----------------------------------------------------------------------------
:: Section 5: Size Calculation
:: -----------------------------------------------------------------------------

:calculate_total_size
cls
echo.
echo %BLUE%======================================================================%RESET%
echo %BLUE%       Calculating Required Download Size (excluding existing files)    %RESET%
echo %BLUE%======================================================================%RESET%
echo.
echo %YELLOW%This may take a moment. Fetching file sizes from the web...%RESET%

set "URL_LIST_FILE=%TEMP%\comfy_url_list.txt"
if exist "%URL_LIST_FILE%" del "%URL_LIST_FILE%" >nul 2>&1

:: --- Determine download size for ComfyUI download + extract size ---
set "SIZE_COMFYUI_DOWNLOAD_GB=0.0"
if "!STATUS_COMFYUI!"=="0" (
    set "SIZE_COMFYUI_DOWNLOAD_GB=8.5"
)

:: --- Add URLs of MISSING selected models to list ---
for /l %%G in (1,1,99) do (
    set "num=0%%G" & set "num=!num:~-2!"
    if defined MODEL_!num!_NAME (
        for /l %%I in (1,1,9) do (
            if defined MODEL_!num!_OPT_%%I_INSTALL (
                call set "FILENAME=%%MODEL_!num!_OPT_%%I_FILE%%"
                call set "FILETYPE=%%MODEL_!num!_OPT_%%I_TYPE%%"
                call set "URL=%%MODEL_!num!_OPT_%%I_URL%%"

                set "TARGET_DIR="
                if /i "!FILETYPE!"=="gguf" set "TARGET_DIR=unet"
                if /i "!FILETYPE!"=="gguf_flux" set "TARGET_DIR=unet"
                if /i "!FILETYPE!"=="checkpoint" set "TARGET_DIR=checkpoints"
                if /i "!FILETYPE!"=="checkpoints" set "TARGET_DIR=checkpoints"
                if /i "!FILETYPE!"=="diffusion_model" set "TARGET_DIR=diffusion_models"
                if /i "!FILETYPE!"=="lora" set "TARGET_DIR=loras"

                if defined TARGET_DIR (
                    set "FILE_PATH=!MODELS_DIR!\!TARGET_DIR!\!FILENAME!"
                    if not exist "!FILE_PATH!" (
                        echo !URL!>>"%URL_LIST_FILE%"
                    )
                )
            )
        )
    )
)

:: --- Add URLs of MISSING shared models to list ---
call :add_shared_urls_to_list

:: --- Calculate model size from URL list ---
set "SIZE_MODELS_GB=0.0"
set "PS_SCRIPT_MODELS=%TEMP%\get_model_size.ps1"

(
echo try {
echo     $totalBytes = 0;
echo     $urlFile = '!URL_LIST_FILE!';
echo     if (Test-Path -LiteralPath $urlFile^) {
echo         Get-Content -LiteralPath $urlFile ^| ForEach-Object {
echo             try {
echo                 $response = Invoke-WebRequest -Uri $_ -Method Head -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop;
echo                 if ($response.Headers.ContainsKey^('Content-Length'^) -and $response.Headers['Content-Length']^) {
echo                     $totalBytes += [long]$response.Headers['Content-Length'];
echo                 }
echo             } catch {}
echo         }
echo     }
echo     $result = [Math]::Round^($totalBytes / 1GB, 1^);
echo     Write-Output $result.ToString^([System.Globalization.CultureInfo]::InvariantCulture^);
echo } catch {
echo     Write-Output '0.0';
echo }
) > "!PS_SCRIPT_MODELS!"

for /f "delims=" %%s in ('powershell.exe -NoProfile -ExecutionPolicy Bypass -File "!PS_SCRIPT_MODELS!"') do set "SIZE_MODELS_GB=%%s"
if exist "!PS_SCRIPT_MODELS!" del "!PS_SCRIPT_MODELS!" >nul 2>&1

:: --- Calculate total size using a robust PowerShell method ---
set "PS_SCRIPT_TOTAL=%TEMP%\get_total_size.ps1"
(
echo try {
echo     $sizeModels = [double]::Parse^('!SIZE_MODELS_GB!', [System.Globalization.CultureInfo]::InvariantCulture^);
echo     $sizeComfy = [double]::Parse^('!SIZE_COMFYUI_DOWNLOAD_GB!', [System.Globalization.CultureInfo]::InvariantCulture^);
echo     $total = $sizeComfy + $sizeModels;
echo     Write-Output ^([Math]::Round^($total, 1^).ToString^([System.Globalization.CultureInfo]::InvariantCulture^)^);
echo } catch {
echo     Write-Output '!SIZE_COMFYUI_DOWNLOAD_GB!';
echo }
) > "!PS_SCRIPT_TOTAL!"

for /f "delims=" %%t in ('powershell.exe -NoProfile -ExecutionPolicy Bypass -File "!PS_SCRIPT_TOTAL!"') do set "SIZE_TOTAL_GB=%%t"
if exist "!PS_SCRIPT_TOTAL!" del "!PS_SCRIPT_TOTAL!" >nul 2>&1

if exist "%URL_LIST_FILE%" del "%URL_LIST_FILE%" >nul 2>&1
echo %GREEN%Size calculation complete.%RESET%
timeout /t 1 >nul
goto :eof

:add_shared_urls_to_list
:: This subroutine adds all conditionally downloaded shared model URLs to the list for size calculation,
:: but only if the target file does not already exist.
for /l %%E in (1,1,999) do (
    set "num=00%%E" & set "num=!num:~-3!"
    if defined EXTRA_!num!_FLAG (
        call set "MODEL_FLAG=%%EXTRA_!num!_FLAG%%"
        set "is_needed=false"

        if "!MODEL_FLAG!"=="ALWAYS" (
            set "is_needed=true"
        ) else (
            set "FAMILY_FLAG_VAR=FLAG_!MODEL_FLAG!_SELECTED"
            if defined !FAMILY_FLAG_VAR! (
                set "is_needed=true"
            )
        )

        if "!is_needed!"=="true" (
            call set "DEST_SUBDIR=%%EXTRA_!num!_PATH%%"
            call set "FILENAME=%%EXTRA_!num!_FILE%%"
            call set "DOWNLOAD_URL=%%EXTRA_!num!_URL%%"

            set "FILE_PATH=!MODELS_DIR!\!DEST_SUBDIR!\!FILENAME!"
            if not exist "!FILE_PATH!" (
                echo !DOWNLOAD_URL!>>"%URL_LIST_FILE%"
            )
        )
    )
)
goto :eof

:: -----------------------------------------------------------------------------
:: Section 6: Exit
:: -----------------------------------------------------------------------------
:exit_script
cls
echo.
echo %BLUE%======================================================================%RESET%
echo %BLUE% Thank you for using the Draekz Ultimate ComfyUI Installation Wizard! %RESET%
echo %BLUE%======================================================================%RESET%
echo.
timeout /t 2 >nul
exit
