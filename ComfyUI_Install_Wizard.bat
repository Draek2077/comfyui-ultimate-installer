@echo off
setlocal enabledelayedexpansion

:: =============================================================================
:: Draekz Ultimate ComfyUI Installation Wizard
:: =============================================================================
:: This script provides a comprehensive toolkit for installing and managing
:: a portable ComfyUI instance, including custom nodes, models, and performance
:: enhancements like Triton and Sage Attention.
::
:: Version: 2.1 (Server Manager Integration)
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

:: --- Toggles Options ---
set "INSTALL_SERVER_MANAGER=0" :: Set to 1 to install, 0 to skip

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
set "SERVER_MANAGER_URL=https://github.com/Draek2077/ComfyUI-Server-Manager/releases/download/v1.0/ComfyUIServerManagerInstaller.msi"
set "SERVER_MANAGER_MSI_NAME=ComfyUIServerManagerInstaller.msi"

:: --- Model Catalog Configuration ---
:: To add/change models, edit this section. The menus will update automatically.
:: ---
:: For each option, define NAME, FILE (the actual filename), and TYPE (gguf or safetensor), and URL (opt) if separate source
:: ---
:: Model 1: FLUXDev
set "MODEL_01_NAME=FLUX-Dev"
set "MODEL_01_OPT_1_NAME=Q4_K_S (GGUF, <12GB VRAM)"       & set "MODEL_01_OPT_1_FILE=flux1-dev-Q4_K_S.gguf"     & set "MODEL_01_OPT_1_TYPE=gguf_flux"
set "MODEL_01_OPT_2_NAME=Q5_K_S (GGUF, 12-16GB VRAM)"     & set "MODEL_01_OPT_2_FILE=flux1-dev-Q5_K_S.gguf"     & set "MODEL_01_OPT_2_TYPE=gguf_flux"
set "MODEL_01_OPT_3_NAME=Q8_0   (GGUF, >16GB VRAM)"       & set "MODEL_01_OPT_3_FILE=flux1-dev-Q8_0.gguf"       & set "MODEL_01_OPT_3_TYPE=gguf_flux"
set "MODEL_01_OPT_4_NAME=FP8    (Safetensor, >24GB VRAM)" & set "MODEL_01_OPT_4_FILE=flux1-dev-fp8.safetensors" & set "MODEL_01_OPT_4_TYPE=diffusion_model"
set "MODEL_01_OPT_5_NAME=FP16   (Safetensor, >32GB VRAM)" & set "MODEL_01_OPT_5_FILE=flux1-dev.sft"             & set "MODEL_01_OPT_5_TYPE=diffusion_model"
:: Model 2: FLUXSchnell
set "MODEL_02_NAME=FLUX-Schnell"
set "MODEL_02_OPT_1_NAME=Q4_K_S (GGUF, <12GB VRAM)"        & set "MODEL_02_OPT_1_FILE=flux1-schnell-Q4_K_S.gguf"     & set "MODEL_02_OPT_1_TYPE=gguf"
set "MODEL_02_OPT_2_NAME=Q5_K_S (GGUF, 12-16GB VRAM)"      & set "MODEL_02_OPT_2_FILE=flux1-schnell-Q5_K_S.gguf"     & set "MODEL_02_OPT_2_TYPE=gguf"
set "MODEL_02_OPT_3_NAME=Q8_0   (GGUF, >16GB VRAM)"        & set "MODEL_02_OPT_3_FILE=flux1-schnell-Q8_0.gguf"       & set "MODEL_02_OPT_3_TYPE=gguf"
set "MODEL_02_OPT_4_NAME=FP8    (Safetensors, >24GB VRAM)" & set "MODEL_02_OPT_4_FILE=flux1-schnell-fp8.safetensors" & set "MODEL_02_OPT_4_TYPE=diffusion_model"
set "MODEL_02_OPT_5_NAME=FP16   (Safetensors, >32GB VRAM)" & set "MODEL_02_OPT_5_FILE=flux1-schnell.safetensors"     & set "MODEL_02_OPT_5_TYPE=diffusion_model" & set "MODEL_02_OPT_5_URL=https://huggingface.co/black-forest-labs/FLUX.1-schnell/resolve/main/flux1-schnell.safetensors?download=true"
:: Model 3: FLUX Kontext
set "MODEL_03_NAME=FLUX-Kontext"
set "MODEL_03_OPT_1_NAME=Q4_K_S (GGUF, <12GB VRAM)"       & set "MODEL_03_OPT_1_FILE=flux1-kontext-dev-Q4_K_S.gguf"            & set "MODEL_03_OPT_1_TYPE=gguf"
set "MODEL_03_OPT_2_NAME=Q5_K_S (GGUF, 12-24GB VRAM)"     & set "MODEL_03_OPT_2_FILE=flux1-kontext-dev-Q5_K_S.gguf"            & set "MODEL_03_OPT_2_TYPE=gguf"
set "MODEL_03_OPT_3_NAME=Q8_0   (GGUF, >24GB VRAM)"       & set "MODEL_03_OPT_3_FILE=flux1-kontext-dev-Q8_0.gguf"              & set "MODEL_03_OPT_3_TYPE=gguf"
set "MODEL_03_OPT_4_NAME=FP8    (Safetensor, >24GB VRAM)" & set "MODEL_03_OPT_4_FILE=flux1-kontext-dev-fp8-e4m3fn.safetensors" & set "MODEL_03_OPT_4_TYPE=diffusion_model"
set "MODEL_03_OPT_5_NAME=FP16   (Safetensor, >32GB VRAM)" & set "MODEL_03_OPT_5_FILE=flux1-kontext-dev.safetensors"            & set "MODEL_03_OPT_5_TYPE=diffusion_model" & set "MODEL_03_OPT_5_URL=https://huggingface.co/black-forest-labs/FLUX.1-Kontext-dev/resolve/main/flux1-kontext-dev.safetensors?download=true"
:: Model 4: Qwen Image
set "MODEL_04_NAME=Qwen-Image"
set "MODEL_04_OPT_1_NAME=Q4_K_S (GGUF, <12GB VRAM)"       & set "MODEL_04_OPT_1_FILE=Qwen_Image_Distill-Q4_K_S.gguf"    & set "MODEL_04_OPT_1_TYPE=gguf"
set "MODEL_04_OPT_2_NAME=Q5_K_S (GGUF, 12-24GB VRAM)"     & set "MODEL_04_OPT_2_FILE=Qwen_Image_Distill-Q5_K_S.gguf"    & set "MODEL_04_OPT_2_TYPE=gguf"
set "MODEL_04_OPT_3_NAME=Q8_0   (GGUF, >24GB VRAM)"       & set "MODEL_04_OPT_3_FILE=Qwen_Image_Distill-Q8_0.gguf"      & set "MODEL_04_OPT_3_TYPE=gguf"
set "MODEL_04_OPT_4_NAME=FP8    (Safetensor, >24GB VRAM)" & set "MODEL_04_OPT_4_FILE=qwen_image_fp8_e4m3fn.safetensors" & set "MODEL_04_OPT_4_TYPE=diffusion_model" & set "MODEL_04_OPT_4_URL=https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/diffusion_models/qwen_image_fp8_e4m3fn.safetensors?download=true"
set "MODEL_04_OPT_5_NAME=BF16   (Safetensor, >32GB VRAM)" & set "MODEL_04_OPT_5_FILE=qwen_image_bf16.safetensors"       & set "MODEL_04_OPT_5_TYPE=diffusion_model" & set "MODEL_04_OPT_5_URL=https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/diffusion_models/qwen_image_bf16.safetensors?download=true"
:: Model 5: Qwen Edit
set "MODEL_05_NAME=Qwen-Edit"
set "MODEL_05_OPT_1_NAME=Q4_K_S (GGUF, <12GB VRAM)"       & set "MODEL_05_OPT_1_FILE=Qwen_Image_Edit-Q4_K_S.gguf"            & set "MODEL_05_OPT_1_TYPE=gguf"
set "MODEL_05_OPT_2_NAME=Q5_K_S (GGUF, 12-24GB VRAM)"     & set "MODEL_05_OPT_2_FILE=Qwen_Image_Edit-Q5_K_S.gguf"            & set "MODEL_05_OPT_2_TYPE=gguf"
set "MODEL_05_OPT_3_NAME=Q8_0   (GGUF, >24GB VRAM)"       & set "MODEL_05_OPT_3_FILE=Qwen_Image_Edit-Q8_0.gguf"              & set "MODEL_05_OPT_3_TYPE=gguf"
set "MODEL_05_OPT_4_NAME=FP8    (Safetensor, >24GB VRAM)" & set "MODEL_05_OPT_4_FILE=qwen_image_edit_fp8_e4m3fn.safetensors" & set "MODEL_05_OPT_4_TYPE=diffusion_model" & set "MODEL_05_OPT_4_URL=https://huggingface.co/Comfy-Org/Qwen-Image-Edit_ComfyUI/resolve/main/split_files/diffusion_models/qwen_image_edit_fp8_e4m3fn.safetensors?download=true"
set "MODEL_05_OPT_5_NAME=BF16   (Safetensor, >32GB VRAM)" & set "MODEL_05_OPT_5_FILE=qwen_image_edit_bf16.safetensors"       & set "MODEL_05_OPT_5_TYPE=diffusion_model" & set "MODEL_05_OPT_5_URL=https://huggingface.co/Comfy-Org/Qwen-Image-Edit_ComfyUI/resolve/main/split_files/diffusion_models/qwen_image_edit_bf16.safetensors?download=true"
:: Model 6: HiDream
set "MODEL_06_NAME=HiDream"
set "MODEL_06_OPT_1_NAME=Q4_K_S (GGUF, <12GB VRAM)"       & set "MODEL_06_OPT_1_FILE=hidream-i1-dev-Q4_K_S.gguf"      & set "MODEL_06_OPT_1_TYPE=gguf"
set "MODEL_06_OPT_2_NAME=Q5_K_S (GGUF, 12-16GB VRAM)"     & set "MODEL_06_OPT_2_FILE=hidream-i1-dev-Q5_K_S.gguf"      & set "MODEL_06_OPT_2_TYPE=gguf"
set "MODEL_06_OPT_3_NAME=Q8_0   (GGUF, >16GB VRAM)"       & set "MODEL_06_OPT_3_FILE=hidream-i1-dev-Q8_0.gguf"        & set "MODEL_06_OPT_3_TYPE=gguf"
set "MODEL_06_OPT_4_NAME=FP8    (Safetensor, >24GB VRAM)" & set "MODEL_06_OPT_4_FILE=hidream_i1_dev_fp8.safetensors"  & set "MODEL_06_OPT_4_TYPE=diffusion_model"
set "MODEL_06_OPT_5_NAME=BF16   (Safetensor, >32GB VRAM)" & set "MODEL_06_OPT_5_FILE=hidream_i1_dev_bf16.safetensors" & set "MODEL_06_OPT_5_TYPE=diffusion_model" & set "MODEL_06_OPT_5_URL=https://huggingface.co/Comfy-Org/HiDream-I1_ComfyUI/resolve/main/split_files/diffusion_models/hidream_i1_dev_bf16.safetensors?download=true"
:: Model 7: SD1.5
set "MODEL_07_NAME=SD15"
set "MODEL_07_OPT_1_NAME=FP16 (Safetensor, 12GB VRAM)" & set "MODEL_07_OPT_1_FILE=v1-5-pruned-emaonly-fp16.safetensors" & set "MODEL_07_OPT_1_TYPE=checkpoint" & set "MODEL_07_OPT_1_URL=https://huggingface.co/Comfy-Org/stable-diffusion-v1-5-archive/resolve/main/v1-5-pruned-emaonly-fp16.safetensors?download=true"
:: Model 8: SDXL
set "MODEL_08_NAME=SDXL"
set "MODEL_08_OPT_1_NAME=Base (Safetensor, 12GB VRAM)" & set "MODEL_08_OPT_1_FILE=sd_xl_base_1.0_0.9vae.safetensors" & set "MODEL_08_OPT_1_TYPE=checkpoint"
:: Model 9: SD3
set "MODEL_09_NAME=SD3"
set "MODEL_09_OPT_1_NAME=Medium 2B      (Safetensor, 6-8GB VRAM)"   & set "MODEL_09_OPT_1_FILE=sd3.5_medium.safetensors"      & set "MODEL_09_OPT_1_TYPE=diffusion_model"
set "MODEL_09_OPT_2_NAME=Large Turbo 8B (Safetensor, 16-24GB VRAM)" & set "MODEL_09_OPT_2_FILE=sd3.5_large_turbo.safetensors" & set "MODEL_09_OPT_2_TYPE=checkpoints" & set "MODEL_09_OPT_2_URL=https://huggingface.co/stabilityai/stable-diffusion-3.5-large-turbo/resolve/main/sd3.5_large_turbo.safetensors?download=true"
set "MODEL_09_OPT_3_NAME=Large 8B FP8   (Safetensor, 16-24GB VRAM)" & set "MODEL_09_OPT_3_FILE=sd3.5_large_fp8_scaled"        & set "MODEL_09_OPT_3_TYPE=checkpoints" & set "MODEL_09_OPT_3_URL=https://huggingface.co/Comfy-Org/stable-diffusion-3.5-fp8/resolve/main/sd3.5_large_fp8_scaled.safetensors?download=true"
set "MODEL_09_OPT_4_NAME=Large 8B       (Safetensor, 16-24GB VRAM)" & set "MODEL_09_OPT_4_FILE=sd3.5_large.safetensors"       & set "MODEL_09_OPT_4_TYPE=diffusion_model"
:: Model 10: WAN2.1T2V
set "MODEL_10_NAME=WAN2.1-T2V"
set "MODEL_10_OPT_1_NAME=Q4_K_S (GGUF, <12GB VRAM)"        & set "MODEL_10_OPT_1_FILE=wan2.1-t2v-14b-Q4_K_S.gguf"            & set "MODEL_10_OPT_1_TYPE=gguf"
set "MODEL_10_OPT_2_NAME=Q5_K_S (GGUF, 12-16GB VRAM)"      & set "MODEL_10_OPT_2_FILE=wan2.1-t2v-14b-Q5_K_S.gguf"            & set "MODEL_10_OPT_2_TYPE=gguf"
set "MODEL_10_OPT_3_NAME=Q8_0   (GGUF, >16GB VRAM)"        & set "MODEL_10_OPT_3_FILE=wan2.1-t2v-14b-Q8_0.gguf"              & set "MODEL_10_OPT_3_TYPE=gguf"
set "MODEL_10_OPT_4_NAME=FP8    (Safetensors, >24GB VRAM)" & set "MODEL_10_OPT_4_FILE=wan2.1_t2v_14B_fp8_e4m3fn.safetensors" & set "MODEL_10_OPT_4_TYPE=diffusion_model" & set "MODEL_10_OPT_4_URL=https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_t2v_14B_fp8_e4m3fn.safetensors?download=true"
set "MODEL_10_OPT_5_NAME=BF16   (Safetensors, >32GB VRAM)" & set "MODEL_10_OPT_5_FILE=wan2.1_t2v_14B_bf16.safetensors"       & set "MODEL_10_OPT_5_TYPE=diffusion_model"
:: Model 11: WAN2.1I2V
set "MODEL_11_NAME=WAN2.1-I2V-480"
set "MODEL_11_OPT_1_NAME=Q4_K_S (GGUF, <12GB VRAM)"        & set "MODEL_11_OPT_1_FILE=wan2.1-i2v-14b-480p-Q4_K_S.gguf"            & set "MODEL_11_OPT_1_TYPE=gguf"
set "MODEL_11_OPT_2_NAME=Q5_K_S (GGUF, 12-16GB VRAM)"      & set "MODEL_11_OPT_2_FILE=wan2.1-i2v-14b-480p-Q5_K_S.gguf"            & set "MODEL_11_OPT_2_TYPE=gguf"
set "MODEL_11_OPT_3_NAME=Q8_0   (GGUF, >16GB VRAM)"        & set "MODEL_11_OPT_3_FILE=wan2.1-i2v-14b-480p-Q8_0.gguf"              & set "MODEL_11_OPT_3_TYPE=gguf"
set "MODEL_11_OPT_4_NAME=FP8    (Safetensors, >24GB VRAM)" & set "MODEL_11_OPT_4_FILE=wan2.1_i2v_480p_14B_fp8_e4m3fn.safetensors" & set "MODEL_11_OPT_4_TYPE=diffusion_model" & set "MODEL_11_OPT_4_URL=https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_i2v_480p_14B_fp8_e4m3fn.safetensors?download=true"
set "MODEL_11_OPT_5_NAME=BF16   (Safetensors, >32GB VRAM)" & set "MODEL_11_OPT_5_FILE=wan2.1_i2v_480p_14B_bf16.safetensors"       & set "MODEL_11_OPT_5_TYPE=diffusion_model"
:: Model 12: WAN2.1I2V
set "MODEL_12_NAME=WAN2.1-I2V-720"
set "MODEL_12_OPT_1_NAME=Q4_K_S (GGUF, <12GB VRAM)"        & set "MODEL_12_OPT_1_FILE=wan2.1-i2v-14b-720p-Q4_K_S.gguf"            & set "MODEL_12_OPT_1_TYPE=gguf"
set "MODEL_12_OPT_2_NAME=Q5_K_S (GGUF, 12-16GB VRAM)"      & set "MODEL_12_OPT_2_FILE=wan2.1-i2v-14b-720p-Q5_K_S.gguf"            & set "MODEL_12_OPT_2_TYPE=gguf"
set "MODEL_12_OPT_3_NAME=Q8_0   (GGUF, >16GB VRAM)"        & set "MODEL_12_OPT_3_FILE=wan2.1-i2v-14b-720p-Q8_0.gguf"              & set "MODEL_12_OPT_3_TYPE=gguf"
set "MODEL_12_OPT_4_NAME=FP8    (Safetensors, >24GB VRAM)" & set "MODEL_12_OPT_4_FILE=wan2.1_i2v_720p_14B_fp8_e4m3fn.safetensors" & set "MODEL_12_OPT_4_TYPE=diffusion_model" & set "MODEL_12_OPT_4_URL=https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_i2v_720p_14B_fp8_e4m3fn.safetensors?download=true"
set "MODEL_12_OPT_5_NAME=BF16   (Safetensors, >32GB VRAM)" & set "MODEL_12_OPT_5_FILE=wan2.1_i2v_720p_14B_bf16.safetensors"       & set "MODEL_12_OPT_5_TYPE=diffusion_model"
:: Model 13: WAN2.1T2VFusionX
set "MODEL_13_NAME=WAN2.1-T2V-FusionX"
set "MODEL_13_OPT_1_NAME=Q4_K_S (GGUF, <13GB VRAM)"   & set "MODEL_13_OPT_1_FILE=Wan14BT2VFusionX-Q4_K_S.gguf" & set "MODEL_13_OPT_1_TYPE=gguf"
set "MODEL_13_OPT_2_NAME=Q5_K_S (GGUF, 13-16GB VRAM)" & set "MODEL_13_OPT_2_FILE=Wan14BT2VFusionX-Q5_K_S.gguf" & set "MODEL_13_OPT_2_TYPE=gguf"
set "MODEL_13_OPT_3_NAME=Q8_0   (GGUF, >16GB VRAM)"   & set "MODEL_13_OPT_3_FILE=Wan14BT2VFusionX-Q8_0.gguf"   & set "MODEL_13_OPT_3_TYPE=gguf"
:: Model 14: WAN2.1FusionXVace
set "MODEL_14_NAME=WAN2.1-T2V-FusionX-Vace"
set "MODEL_14_OPT_1_NAME=Q4_K_S (GGUF, <12GB VRAM)"   & set "MODEL_14_OPT_1_FILE=Wan2.1_T2V_14B_FusionX_VACE-Q4_K_S.gguf" & set "MODEL_14_OPT_1_TYPE=gguf"
set "MODEL_14_OPT_2_NAME=Q5_K_S (GGUF, 12-16GB VRAM)" & set "MODEL_14_OPT_2_FILE=Wan2.1_T2V_14B_FusionX_VACE-Q5_K_S.gguf" & set "MODEL_14_OPT_2_TYPE=gguf"
set "MODEL_14_OPT_3_NAME=Q8_0   (GGUF, >16GB VRAM)"   & set "MODEL_14_OPT_3_FILE=Wan2.1_T2V_14B_FusionX_VACE-Q8_0.gguf"   & set "MODEL_14_OPT_3_TYPE=gguf"
:: Model 15: WAN2.1Vace
set "MODEL_15_NAME=WAN2.1-Vace"
set "MODEL_15_OPT_1_NAME=Q4_K_S (GGUF, <12GB VRAM)"        & set "MODEL_15_OPT_1_FILE=Wan2.1-VACE-15B-Q4_K_S.gguf"            & set "MODEL_15_OPT_1_TYPE=gguf"
set "MODEL_15_OPT_2_NAME=Q5_K_S (GGUF, 12-16GB VRAM)"      & set "MODEL_15_OPT_2_FILE=Wan2.1-VACE-15B-Q5_K_S.gguf"            & set "MODEL_15_OPT_2_TYPE=gguf"
set "MODEL_15_OPT_3_NAME=Q8_0   (GGUF, >16GB VRAM)"        & set "MODEL_15_OPT_3_FILE=Wan2.1-VACE-15B-Q8_0.gguf"              & set "MODEL_15_OPT_3_TYPE=gguf"
set "MODEL_15_OPT_4_NAME=FP8    (Safetensors, >24GB VRAM)" & set "MODEL_15_OPT_4_FILE=wan2.1_vace_15B_fp8_e4m3fn.safetensors" & set "MODEL_15_OPT_4_TYPE=diffusion_model" & set "MODEL_15_OPT_4_URL=https://huggingface.co/Kamikaze-88/Wan2.1-VACE-15B-fp8/resolve/main/wan2.1_vace_15B_fp8_e4m3fn.safetensors?download=true"
set "MODEL_15_OPT_5_NAME=FP16   (Safetensors, >32GB VRAM)" & set "MODEL_15_OPT_5_FILE=wan2.1_vace_15B_fp16.safetensors"       & set "MODEL_15_OPT_5_TYPE=diffusion_model" & set "MODEL_15_OPT_5_URL=https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_vace_15B_fp16.safetensors?download=true"
:: Model 16: WAN2.2I2VL
set "MODEL_16_NAME=WAN2.2-I2V-L"
set "MODEL_16_OPT_1_NAME=Low Q4_K_S  (GGUF, <12GB VRAM)"        & set "MODEL_16_OPT_1_FILE=Wan2.2-I2V-A14B-LowNoise-Q4_K_S.gguf"            & set "MODEL_16_OPT_1_TYPE=gguf"
set "MODEL_16_OPT_2_NAME=Low Q5_K_S  (GGUF, 12-16GB VRAM)"      & set "MODEL_16_OPT_2_FILE=Wan2.2-I2V-A14B-LowNoise-Q5_K_S.gguf"            & set "MODEL_16_OPT_2_TYPE=gguf"
set "MODEL_16_OPT_3_NAME=Low Q8_0    (GGUF, >16GB VRAM)"        & set "MODEL_16_OPT_3_FILE=Wan2.2-I2V-A14B-LowNoise-Q8_0.gguf"              & set "MODEL_16_OPT_3_TYPE=gguf"
set "MODEL_16_OPT_4_NAME=Low FP8     (Safetensors, >24GB VRAM)" & set "MODEL_16_OPT_4_FILE=wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors" & set "MODEL_16_OPT_4_TYPE=diffusion_model" & set "MODEL_16_OPT_4_URL=https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors?download=true"
set "MODEL_16_OPT_5_NAME=Low FP16    (Safetensors, >32GB VRAM)" & set "MODEL_16_OPT_5_FILE=wan2.2_i2v_low_noise_14B_fp16.safetensors"       & set "MODEL_16_OPT_5_TYPE=diffusion_model" & set "MODEL_16_OPT_5_URL=https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_low_noise_14B_fp16.safetensors?download=true"
:: Model 17: WAN2.2I2VH
set "MODEL_17_NAME=WAN2.2-I2V-H"
set "MODEL_17_OPT_1_NAME=High Q4_K_S (GGUF, <12GB VRAM)"        & set "MODEL_17_OPT_1_FILE=Wan2.2-I2V-A14B-HighNoise-Q4_K_S.gguf"            & set "MODEL_17_OPT_1_TYPE=gguf"
set "MODEL_17_OPT_2_NAME=High Q5_K_S (GGUF, 12-16GB VRAM)"      & set "MODEL_17_OPT_2_FILE=Wan2.2-I2V-A14B-HighNoise-Q5_K_S.gguf"            & set "MODEL_17_OPT_2_TYPE=gguf"
set "MODEL_17_OPT_3_NAME=High Q8_0   (GGUF, >16GB VRAM)"        & set "MODEL_17_OPT_3_FILE=Wan2.2-I2V-A14B-HighNoise-Q8_0.gguf"              & set "MODEL_17_OPT_3_TYPE=gguf"
set "MODEL_17_OPT_4_NAME=High FP8    (Safetensors, >24GB VRAM)" & set "MODEL_17_OPT_4_FILE=wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors" & set "MODEL_17_OPT_4_TYPE=diffusion_model" & set "MODEL_17_OPT_4_URL=https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors?download=true"
set "MODEL_17_OPT_5_NAME=High FP16   (Safetensors, >32GB VRAM)" & set "MODEL_17_OPT_5_FILE=wan2.2_i2v_high_noise_14B_fp16.safetensors"       & set "MODEL_17_OPT_5_TYPE=diffusion_model" & set "MODEL_17_OPT_5_URL=https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_high_noise_14B_fp16.safetensors?download=true"
:: Model 18: WAN2.2T2VL
set "MODEL_18_NAME=WAN2.2-T2V-L"
set "MODEL_18_OPT_1_NAME=Low Q4_K_S  (GGUF, <12GB VRAM)"        & set "MODEL_18_OPT_1_FILE=Wan2.2-T2V-A14B-LowNoise-Q4_K_S.gguf"            & set "MODEL_18_OPT_1_TYPE=gguf"
set "MODEL_18_OPT_2_NAME=Low Q5_K_S  (GGUF, 12-16GB VRAM)"      & set "MODEL_18_OPT_2_FILE=Wan2.2-T2V-A14B-LowNoise-Q5_K_S.gguf"            & set "MODEL_18_OPT_2_TYPE=gguf"
set "MODEL_18_OPT_3_NAME=Low Q8_0    (GGUF, >16GB VRAM)"        & set "MODEL_18_OPT_3_FILE=Wan2.2-T2V-A14B-LowNoise-Q8_0.gguf"              & set "MODEL_18_OPT_3_TYPE=gguf"
set "MODEL_18_OPT_4_NAME=Low FP8     (Safetensors, >24GB VRAM)" & set "MODEL_18_OPT_4_FILE=wan2.2_t2v_low_noise_14B_fp8_scaled.safetensors" & set "MODEL_18_OPT_4_TYPE=diffusion_model" & set "MODEL_18_OPT_4_URL=https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_t2v_low_noise_14B_fp8_scaled.safetensors?download=true"
set "MODEL_18_OPT_5_NAME=Low FP16    (Safetensors, >32GB VRAM)" & set "MODEL_18_OPT_5_FILE=wan2.2_t2v_low_noise_14B_fp16.safetensors"       & set "MODEL_18_OPT_5_TYPE=diffusion_model" & set "MODEL_18_OPT_5_URL=https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_t2v_low_noise_14B_fp16.safetensors?download=true"
:: Model 19: WAN2.2T2VH
set "MODEL_19_NAME=WAN2.2-T2V-H"
set "MODEL_19_OPT_1_NAME=High Q4_K_S (GGUF, <12GB VRAM)"        & set "MODEL_19_OPT_1_FILE=Wan2.2-T2V-A14B-HighNoise-Q4_K_S.gguf"            & set "MODEL_19_OPT_1_TYPE=gguf"
set "MODEL_19_OPT_2_NAME=High Q5_K_S (GGUF, 12-16GB VRAM)"      & set "MODEL_19_OPT_2_FILE=Wan2.2-T2V-A14B-HighNoise-Q5_K_S.gguf"            & set "MODEL_19_OPT_2_TYPE=gguf"
set "MODEL_19_OPT_3_NAME=High Q8_0   (GGUF, >16GB VRAM)"        & set "MODEL_19_OPT_3_FILE=Wan2.2-T2V-A14B-HighNoise-Q8_0.gguf"              & set "MODEL_19_OPT_3_TYPE=gguf"
set "MODEL_19_OPT_4_NAME=High FP8    (Safetensors, >24GB VRAM)" & set "MODEL_19_OPT_4_FILE=wan2.2_t2v_high_noise_14B_fp8_scaled.safetensors" & set "MODEL_19_OPT_4_TYPE=diffusion_model" & set "MODEL_19_OPT_4_URL=https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_t2v_high_noise_14B_fp8_scaled.safetensors?download=true"
set "MODEL_19_OPT_5_NAME=High FP16   (Safetensors, >32GB VRAM)" & set "MODEL_19_OPT_5_FILE=wan2.2_t2v_high_noise_14B_fp16.safetensors"       & set "MODEL_19_OPT_5_TYPE=diffusion_model" & set "MODEL_19_OPT_5_URL=https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_t2v_high_noise_14B_fp16.safetensors?download=true"
:: Model 20: WAN2.2TI2V
set "MODEL_20_NAME=WAN2.2-TI2V"
set "MODEL_20_OPT_1_NAME=Q4_K_S  (GGUF, <12GB VRAM)"        & set "MODEL_20_OPT_1_FILE=Wan2.2-TI2V-5B-Q4_K_S.gguf"      & set "MODEL_20_OPT_1_TYPE=gguf"
set "MODEL_20_OPT_2_NAME=Q5_K_S  (GGUF, 12-16GB VRAM)"      & set "MODEL_20_OPT_2_FILE=Wan2.2-TI2V-5B-Q5_K_S.gguf"      & set "MODEL_20_OPT_2_TYPE=gguf"
set "MODEL_20_OPT_3_NAME=Q8_0    (GGUF, >16GB VRAM)"        & set "MODEL_20_OPT_3_FILE=Wan2.2-TI2V-5B-Q8_0.gguf"        & set "MODEL_20_OPT_3_TYPE=gguf"
set "MODEL_20_OPT_4_NAME=FP16    (Safetensors, >32GB VRAM)" & set "MODEL_20_OPT_4_FILE=wan2.2_ti2v_5B_fp16.safetensors" & set "MODEL_20_OPT_4_TYPE=diffusion_model" & set "MODEL_20_OPT_4_URL=https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_ti2v_5B_fp16.safetensors?download=true"

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
set "NODE_URL_39=https://github.com/Draek2077/comfyui-draekz-nodes.git"
set "NODE_URL_40=https://github.com/crystian/ComfyUI-Crystools.git"
set "NODE_URL_41=https://github.com/sipherxyz/comfyui-art-venture.git"
set "NODE_URL_42=https://github.com/digitaljohn/comfyui-propost.git"
set "NODE_URL_43=https://github.com/miaoshouai/ComfyUI-Miaoshouai-Tagger.git"
set "NODE_URL_44=https://github.com/jags111/efficiency-nodes-comfyui.git"

:: -----------------------------------------------------------------------------
:: Section 2: Main Menu
:: -----------------------------------------------------------------------------
:main_menu
cls
echo.
echo %BLUE%======================================================================%RESET%
echo %BLUE%          Draekz Ultimate ComfyUI Installation Wizard                 %RESET%
echo %BLUE%======================================================================%RESET%
echo.

:: --- Dynamic Model Status Display ---
set "MODEL_STATUS_STRING="
for /l %%G in (1,1,99) do (
    set "num=0%%G"
    set "num=!num:~-2!"
    if defined MODEL_!num!_NAME (
        set "model_selected=false"
        for /l %%H in (1,1,5) do (
            if defined MODEL_!num!_OPT_%%H_INSTALL set "model_selected=true"
        )
        if "!model_selected!"=="true" (
            call set "MODEL_NAME=%%MODEL_!num!_NAME%%"
            set "MODEL_STATUS_STRING=!MODEL_STATUS_STRING! [!MODEL_NAME!]"
        )
    )
)
if not defined MODEL_STATUS_STRING set "MODEL_STATUS_STRING=%PURPLE% [None Selected]%RESET%"

echo %YELLOW%[ Setup ^& Status ]%RESET%
if "!INSTALL_SERVER_MANAGER!"=="1" (
    echo %WHITE%  0^) Install Server Manager %GREEN%[X]%RESET%
) else (
    echo %WHITE%  0^) Install Server Manager %RED%[ ]%RESET%
)
echo %WHITE%  1) Full Automatic Installation (All Models)%RESET%
echo %WHITE%  2) Select Models...%GREEN%!MODEL_STATUS_STRING!%RESET%
echo.
echo %YELLOW%[ Core Installation ]%RESET%
echo %WHITE%  3) Install ComfyUI%RESET%
echo %WHITE%  4) Install SELECTED Models%RESET%
echo %WHITE%  5) Install Custom Nodes%RESET%
echo.
echo %YELLOW%[ Supporting Modules ]%RESET%
echo %WHITE%  6) Configure Settings ^& Shortcuts%RESET%
echo %WHITE%  7) Install Triton ^& Sage Attention (+Enable Flag)%RESET%
echo %WHITE%  8) Install Python Include/Libs for Triton%RESET%
echo %WHITE%  9) Verify Full Installation%RESET%
echo.
echo %YELLOW%[ Diagnostics ]%RESET%
echo %WHITE%  V) Verify Prerequisites%RESET%
echo.
echo %WHITE%  X) Quit%RESET%
echo.
echo %BLUE%======================================================================%RESET%
echo.
if defined LAST_ACTION_MSG echo  Last Action: !LAST_ACTION_MSG!
echo.
set /p "main_choice=%WHITE%Enter your choice and press ENTER: %RESET%"

if "%main_choice%"=="0" goto :toggle_server_manager
if "%main_choice%"=="1" goto :full_install
if "%main_choice%"=="2" goto :model_selection_menu
if "%main_choice%"=="3" goto :install_comfyui
if "%main_choice%"=="4" goto :install_models
if "%main_choice%"=="5" goto :install_nodes
if "%main_choice%"=="6" goto :configure_comfyui
if "%main_choice%"=="7" goto :install_triton_sage
if "%main_choice%"=="8" goto :setup_python_libs
if "%main_choice%"=="9" goto :verify_all
if /i "%main_choice%"=="V" goto :verify_prereqs_menu
if /i "%main_choice%"=="X" goto :exit_script

set "LAST_ACTION_MSG=%RED%Invalid choice. Please try again.%RESET%"
goto :main_menu


:: -----------------------------------------------------------------------------
:: Section 3: Core Logic and Subroutines
:: -----------------------------------------------------------------------------

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

:: --- Full Automated Install ---
:full_install
cls
echo.
echo %BLUE%======================================================================%RESET%
echo %BLUE%               Starting Full Automated Installation                   %RESET%
echo %BLUE%======================================================================%RESET%
echo %YELLOW%[INFO] Enabling Server Manager installation for Full Install mode.%RESET%
set "INSTALL_SERVER_MANAGER=1"
call :auto_install_model_setup
if "%AUTO_INSTALL_QUALITY%"=="" (
    set "LAST_ACTION_MSG=%PURPLE%Full installation was cancelled by user.%RESET%"
    goto :main_menu
)

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
echo %GREEN%           [X] Full Automated Installation Complete!                  %RESET%
echo %GREEN%======================================================================%RESET%
echo.
set "LAST_ACTION_MSG=%GREEN%Full Automated Installation completed successfully!%RESET%"
pause
goto :main_menu

:auto_install_model_setup
echo.
echo %BLUE%======================================================================%RESET%
echo %BLUE%           Automatic Installation: Select Model Quality               %RESET%
echo %BLUE%======================================================================%RESET%
echo.
echo %YELLOW%Please select the HIGHEST quality level you want for all models.%RESET%
echo %YELLOW%The installer will try to get this version, or the next best available.%RESET%
echo.
echo %WHITE%  1) Q4 - Basic Quality (Lowest VRAM, ~8GB+)%RESET%
echo %WHITE%  2) Q5 - Good Quality (Balanced, ~12GB+)%RESET%
echo %WHITE%  3) Q8 - High Quality (High VRAM, ~16GB+)%RESET%
echo %WHITE%  4) FP8 - Best Quality (Very High VRAM, ~24GB+)%RESET%
echo %WHITE%  5) FP16 - Maximum Quality (Highest VRAM, ~32GB+)%RESET%
echo.
echo %WHITE%  X) Cancel and return to Main Menu%RESET%
echo.
set /p "quality_choice=%WHITE%Enter your choice and press ENTER: %RESET%"

if /i "%quality_choice%"=="X" set "AUTO_INSTALL_QUALITY=" & goto :eof
if "%quality_choice%"=="1" set "AUTO_INSTALL_QUALITY=1" & goto :set_auto_models
if "%quality_choice%"=="2" set "AUTO_INSTALL_QUALITY=2" & goto :set_auto_models
if "%quality_choice%"=="3" set "AUTO_INSTALL_QUALITY=3" & goto :set_auto_models
if "%quality_choice%"=="4" set "AUTO_INSTALL_QUALITY=4" & goto :set_auto_models
if "%quality_choice%"=="5" set "AUTO_INSTALL_QUALITY=5" & goto :set_auto_models

echo %RED%Invalid selection. Please try again.%RESET%
timeout /t 2 >nul
goto :auto_install_model_setup

:set_auto_models
echo %YELLOW%Setting models to best available, up to your selection...%RESET%
for /l %%G in (1,1,99) do (
    set "num=0%%G"
    set "num=!num:~-2!"
    if defined MODEL_!num!_NAME (
        set "found_model=false"
        for /l %%H in (%AUTO_INSTALL_QUALITY%,-1,1) do (
            if "!found_model!"=="false" (
                if defined MODEL_!num!_OPT_%%H_NAME (
                    set "MODEL_!num!_OPT_%%H_INSTALL=1"
                    set "found_model=true"
                )
            )
        )
    )
)
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
    goto :main_menu_return
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
"%SEVEN_ZIP_PATH%" x "ComfyUI_portable.7z" -aoa -o"%CD%" >nul
del "ComfyUI_portable.7z"
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
set "LAST_ACTION_MSG=%GREEN%ComfyUI Core installed successfully.%RESET%"
goto :main_menu_return

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
(echo ew0KICAgICJDb21meS5WYWxpZGF0aW9uLldvcmtmbG93cyI6IHRydWUsDQogICAgIkNvbWZ5LkV4dGVuc2lvbi5EaXNhYmxlZCI6IFsNCiAgICAgICAgInB5c3Nzc3MuTG9ja2luZyIsDQogICAgICAgICJweXNzc3NzLlNuYXBUb0dyaWQiLA0KICAgICAgICAicHlzc3Nzcy5JbWFnZUZlZWQiLA0KICAgICAgICAicHlzc3Nzcy5TaG93SW1hZ2VPbk1lbnUiLA0KICAgICAgICAicmd0aHJlZS5Ub3BNZW51Ig0KICAgIF0sDQogICAgInB5c3Nzc3MuTW9kZWxJbmZvLkNoZWNrcG9pbnROb2RlcyI6ICJDaGVja3BvaW50TG9hZGVyLmNrcHRfbmFtZSxDaGVja3BvaW50TG9hZGVyU2ltcGxlLENoZWNrcG9pbnRMb2FkZXJ8cHlzc3NzcyxFZmZpY2llbnQgTG9hZGVyLEVmZi4gTG9hZGVyIFNEWEwsdHROIHBpcGVMb2FkZXJfdjIsdHROIHBpcGVMb2FkZXJTRFhMX3YyLHR0TiB0aW55TG9hZGVyIiwNCiAgICAicHlzc3Nzcy5Nb2RlbEluZm8uTG9yYU5vZGVzIjogIkxvcmFMb2FkZXIubG9yYV9uYW1lLExvcmFMb2FkZXJ8cHlzc3NzcyxMb3JhTG9hZGVyTW9kZWxPbmx5LmxvcmFfbmFtZSxMb1JBIFN0YWNrZXIubG9yYV9uYW1lLiosdHROIEtTYW1wbGVyX3YyLHR0TiBwaXBlS1NhbXBsZXJfdjIsdHROIHBpcGVLU2FtcGxlckFkdmFuY2VkX3YyLHR0TiBwaXBlS1NhbXBsZXJTRFhMX3YyIiwNCiAgICAiQ29tZnkuU2lkZWJhci5TaXplIjogInNtYWxsIiwNCiAgICAiQ29tZnkuVXNlTmV3TWVudSI6ICJUb3AiLA0KICAgICJDb21meS5NaW5pbWFwLlZpc2libGUiOiBmYWxzZSwNCiAgICAiQ29tZnkuTW9kZWxMaWJyYXJ5Lk5hbWVGb3JtYXQiOiAidGl0bGUiLA0KICAgICJDb21meS5Xb3JrZmxvdy5Xb3JrZmxvd1RhYnNQb3NpdGlvbiI6ICJTaWRlYmFyIiwNCiAgICAiQ29tZnkuU25hcFRvR3JpZC5HcmlkU2l6ZSI6IDIwLA0KICAgICJweXNzc3NzLlNuYXBUb0dyaWQiOiB0cnVlLA0KICAgICJMaXRlR3JhcGguQ2FudmFzLkxvd1F1YWxpdHlSZW5kZXJpbmdab29tVGhyZXNob2xkIjogMC40LA0KICAgICJDb21meS5HcmFwaC5DYW52YXNJbmZvIjogZmFsc2UsDQogICAgIkNvbWZ5LkxpbmtSZW5kZXJNb2RlIjogMCwNCiAgICAiQ29tZnkuR3JhcGguTGlua01hcmtlcnMiOiAyLA0KICAgICJDb21meS5UZXh0YXJlYVdpZGdldC5Gb250U2l6ZSI6IDEyLA0KICAgICJDb21meS5TaWRlYmFyLlVuaWZpZWRXaWR0aCI6IHRydWUsDQogICAgInB5c3Nzc3MuTW9kZWxJbmZvLk5zZndMZXZlbCI6ICJYWFgiLA0KICAgICJLSk5vZGVzLmJyb3dzZXJTdGF0dXMiOiB0cnVlLA0KICAgICJDcnlzdG9vbHMuTW9uaXRvckhlaWdodCI6IDI4LA0KICAgICJDcnlzdG9vbHMuU2hvd0hkZCI6IHRydWUsDQogICAgIkNyeXN0b29scy5XaGljaEhkZCI6ICJDOlxcIg0KfQ==)>"%TEMP_B64_FILE%"
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

echo.
echo %YELLOW%Creating Desktop and Start Menu shortcuts...%RESET%

:: --- Create Shortcuts (only if Server Manager is NOT installed) ---
if "%INSTALL_SERVER_MANAGER%"=="0" (
    call :grab "%SERVER_ICON_FILE%" "https://github.com/Comfy-Org/desktop/raw/refs/heads/main/assets/UI/Comfy_Logo.ico"

    powershell.exe -NoProfile -Command "$ws = New-Object -ComObject WScript.Shell; $DesktopPath = [Environment]::GetFolderPath('Desktop'); $ShortcutPath = Join-Path -Path $DesktopPath -ChildPath '%SERVER_SHORTCUT_NAME%'; $s = $ws.CreateShortcut($ShortcutPath); $s.TargetPath = 'C:\Windows\System32\cmd.exe'; $s.Arguments = '/c \"%TARGET_EXE%\"'; $s.WorkingDirectory = '%ABSOLUTE_COMFYUI_DIR%'; $s.IconLocation = '%SERVER_ICON_FILE%,0'; $s.WindowStyle = 7; $s.Save()"
    powershell.exe -NoProfile -Command "$ws = New-Object -ComObject WScript.Shell; $StartMenuPath = [Environment]::GetFolderPath('Programs'); $ShortcutPath = Join-Path -Path $StartMenuPath -ChildPath '%SERVER_SHORTCUT_NAME%'; $s = $ws.CreateShortcut($ShortcutPath); $s.TargetPath = 'C:\Windows\System32\cmd.exe'; $s.Arguments = '/c \"%TARGET_EXE%\"'; $s.WorkingDirectory = '%ABSOLUTE_COMFYUI_DIR%'; $s.IconLocation = '%SERVER_ICON_FILE%,0'; $s.WindowStyle = 7; $s.Save()"
) else (
    echo.
    echo %PURPLE%[INFO] Skipping server shortcut creation because the Server Manager is being installed.%RESET%
)

call :grab "%CLIENT_ICON_FILE%" "https://drive.usercontent.google.com/download?id=1ehBRfElOe-v-zHQTKoCRInkzL8HBtYBZ&export=download&authuser=0&confirm=t&uuid=bc713c44-c765-4a89-a212-1b2ba8016a15&at=AN8xHoqQo2CQKoir69Qmh2iGscvg:1756246657739"

powershell.exe -NoProfile -Command "$ws = New-Object -ComObject WScript.Shell; $DesktopPath = [Environment]::GetFolderPath('Desktop'); $ShortcutPath = Join-Path -Path $DesktopPath -ChildPath '%CLIENT_SHORTCUT_NAME%'; $s = $ws.CreateShortcut($ShortcutPath); $s.TargetPath = '%EDGE_PATH%'; $s.Arguments = '--app=%TARGET_URL%'; $s.IconLocation = '%CLIENT_ICON_FILE%'; $s.Save()"
powershell.exe -NoProfile -Command "$ws = New-Object -ComObject WScript.Shell; $StartMenuPath = [Environment]::GetFolderPath('Programs'); $ShortcutPath = Join-Path -Path $StartMenuPath -ChildPath '%CLIENT_SHORTCUT_NAME%'; $s = $ws.CreateShortcut($ShortcutPath); $s.TargetPath = '%EDGE_PATH%'; $s.Arguments = '--app=%TARGET_URL%'; $s.IconLocation = '%CLIENT_ICON_FILE%'; $s.Save()"

echo %GREEN%ComfyUI configuration complete!%RESET%
echo.
set "LAST_ACTION_MSG=%GREEN%ComfyUI configuration complete!%RESET%
goto :main_menu_return

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

echo %YELLOW%Cleaning up files...%RESET%
del "!WHL_FILE!"
del "%SERVER_MANAGER_MSI_NAME%"

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
    goto :main_menu
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
goto :main_menu_return

:: --- Model Installation Menus and Logic ---
:install_models
set "models_were_selected=false"
for /l %%G in (1,1,99) do (
    set "num=0%%G"
    set "num=!num:~-2!"
    if defined MODEL_!num!_NAME (
        for /l %%H in (1,1,5) do (
            if defined MODEL_!num!_OPT_%%H_INSTALL set "models_were_selected=true"
        )
    )
)
if "!models_were_selected!"=="false" (
    echo %PURPLE%No models selected. Please use Option 2 from the main menu to select models first.%RESET%
    set "LAST_ACTION_MSG=%PURPLE%Model installation skipped: No models were selected.%RESET%"
    pause
    goto :main_menu
)
call :download_selected_models
goto :main_menu_return

:model_selection_menu
cls
echo.
echo %BLUE%======================================================================%RESET%
echo %BLUE%                     Model Installation Manager                       %RESET%
echo %BLUE%======================================================================%RESET%
echo.
echo %YELLOW%Select a model type to configure its versions.%RESET%
echo.
for /l %%G in (1,1,99) do (
    set "num=0%%G"
    set "num=!num:~-2!"
    if defined MODEL_!num!_NAME (
        call set "MODEL_NAME=%%MODEL_!num!_NAME%%"
        echo %WHITE%  %%G^) Configure !MODEL_NAME! Models%RESET%
    )
)
echo.
echo %WHITE%  B) Back - Return to Main Menu%RESET%
echo.
set /p "model_choice=%WHITE%Enter your choice and press ENTER: %RESET%"

if /i "%model_choice%"=="B" goto :main_menu

set "choice_num=0%model_choice%"
set "choice_num=!choice_num:~-2!"
if defined MODEL_!choice_num!_NAME (
    call :choose_model_versions !choice_num!
)
goto :model_selection_menu

:choose_model_versions
set "model_idx=%~1"
:choose_model_versions_loop
cls
echo.
call set "MODEL_NAME=%%MODEL_%model_idx%_NAME%%"
echo %BLUE%======================================================================%RESET%
echo %BLUE%                     Configure !MODEL_NAME! Models                       %RESET%
echo %BLUE%======================================================================%RESET%
echo.
echo %YELLOW%Select which versions to install. [%GREEN%X%YELLOW%] = selected.%RESET%
echo.
for /l %%H in (1,1,99) do (
    if defined MODEL_%model_idx%_OPT_%%H_NAME (
        call set "IS_ENABLED=%%MODEL_%model_idx%_OPT_%%H_INSTALL%%"
        call set "OPT_NAME=%%MODEL_%model_idx%_OPT_%%H_NAME%%"
        if defined IS_ENABLED (
            echo %GREEN%  %%H^) [X] !OPT_NAME!%RESET%
        ) else (
            echo %WHITE%  %%H^) [ ] !OPT_NAME!%RESET%
        )
    )
)
echo.
echo %WHITE%  B) Back - Return to Previous Menu%RESET%
echo.
set /p "version_choice=%WHITE%Enter number to toggle selection, or 'B' to go back: %RESET%"

if /i "%version_choice%"=="B" goto :eof

if defined MODEL_%model_idx%_OPT_%version_choice%_NAME (
    call set "CHECK_INSTALL=%%MODEL_%model_idx%_OPT_%version_choice%_INSTALL%%"
    if defined CHECK_INSTALL (
        set "MODEL_%model_idx%_OPT_%version_choice%_INSTALL="
    ) else (
        set "MODEL_%model_idx%_OPT_%version_choice%_INSTALL=1"
    )
)
goto :choose_model_versions_loop
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
        for /l %%H in (1,1,5) do (
            if defined MODEL_!num!_OPT_%%H_INSTALL set "family_member_selected=true"
        )
        if "!family_member_selected!"=="true" (
            call set "MODEL_FAMILY_NAME=%%MODEL_!num!_NAME%%"
            echo !MODEL_FAMILY_NAME! | findstr /i "FLUX" >nul   && set "FLAG_FLUX_SELECTED=1"
            echo !MODEL_FAMILY_NAME! | findstr /i "Qwen" >nul   && set "FLAG_QWEN_SELECTED=1"
            echo !MODEL_FAMILY_NAME! | findstr /i "HiDream" >nul&& set "FLAG_HIDREAM_SELECTED=1"
            echo !MODEL_FAMILY_NAME! | findstr /i "SD15" >nul&& set "FLAG_SD15_SELECTED=1"
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
        for /l %%I in (1,1,5) do (
            if defined MODEL_!num!_OPT_%%I_INSTALL (
                call set "MODEL_NAME=%%MODEL_!num!_NAME%%"
                call set "FILENAME=%%MODEL_!num!_OPT_%%I_FILE%%"
                call set "FILETYPE=%%MODEL_!num!_OPT_%%I_TYPE%%"
                call set "CUSTOM_URL=%%MODEL_!num!_OPT_%%I_URL%%"

                set "DOWNLOAD_URL="
                if defined CUSTOM_URL (
                    set "DOWNLOAD_URL=!CUSTOM_URL!"
                ) else (
                    set "DOWNLOAD_URL=%HF_FLX_URL%/!FILENAME!"
                )

                echo %YELLOW%Downloading !MODEL_NAME! (!FILENAME!^)...%RESET%

                if "!FILETYPE!"=="gguf" (
                    call :grab "unet\!FILENAME!" "!DOWNLOAD_URL!?download=true"
                )
                if "!FILETYPE!"=="gguf_flux" (
                    call :grab "unet\!FILENAME!" "!DOWNLOAD_URL!?download=true"
                    rem Also grab the associated text encoder for Flux models
                    call set "FLUX_ENCODER=%%MODEL_01_OPT_%%I_ENC%%"
                    if defined FLUX_ENCODER call :grab "clip\t5-v1_1-xxl-encoder-!FLUX_ENCODER!.gguf" "%HF_FLX_URL%/t5-v1_1-xxl-encoder-!FLUX_ENCODER!.gguf?download=true"
                )
                if "!FILETYPE!"=="checkpoint" (
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
goto :main_menu_return

:download_shared_models
echo.
echo %BLUE%======================================================================%RESET%
echo %BLUE%        Downloading Supporting Models (VAEs, Upscalers, etc.)         %RESET%
echo %BLUE%======================================================================%RESET%
echo.

:: --- FLUX Models ---
if defined FLAG_FLUX_SELECTED (
    echo %YELLOW%--- Downloading supporting files for FLUX...%RESET%
    call :grab "diffusion_models\svdq-fp4_r32-flux.1-kontext-dev.safetensors" "%HF_FLX_URL%/svdq-fp4_r32-flux.1-kontext-dev.safetensors?download=true"
    call :grab "diffusion_models\svdq-int4_r32-flux.1-kontext-dev.safetensors" "%HF_FLX_URL%/svdq-int4_r32-flux.1-kontext-dev.safetensors?download=true"
    call :grab "text_encoders\umt5-xxl-encoder-Q5_K_S.gguf" "%HF_FLX_URL%/umt5-xxl-encoder-Q5_K_S.gguf?download=true"
    call :grab "text_encoders\t5xxl_fp16.safetensors" "%HF_FLX_URL%/t5xxl_fp16.safetensors?download=true"
    call :grab "text_encoders\t5xxl_fp8_e4m3fn.safetensors" "%HF_FLX_URL%/t5xxl_fp8_e4m3fn.safetensors?download=true"
    call :grab "text_encoders\t5xxl_fp8_e4m3fn_scaled.safetensors" "%HF_FLX_URL%/t5xxl_fp8_e4m3fn_scaled.safetensors?download=true"
    call :grab "pulid\pulid_flux_v0.9.1.safetensors" "https://huggingface.co/guozinan/PuLID/resolve/main/pulid_flux_v0.9.1.safetensors?download=true"
    call :grab "controlnet\FLUX1-dev-ControlNet-Union-Pro.safetensors" "%HF_FLX_URL%/Shakker-LabsFLUX1-dev-ControlNet-Union-Pro.safetensors?download=true"
    call :grab "controlnet\FLUX1-dev-ControlNet-Depth.safetensors" "https://huggingface.co/Shakker-Labs/FLUX.1-dev-ControlNet-Depth/resolve/main/diffusion_pytorch_model.safetensors?download=true"
    call :grab "xlabs\ipadapters\ip_adapter.safetensors" "https://huggingface.co/XLabs-AI/flux-ip-adapter-v2/resolve/main/ip_adapter.safetensors?download=true"
    call :grab "xlabs\controlnets\flux-canny-controlnet-v3.safetensors" "https://huggingface.co/XLabs-AI/flux-controlnet-canny-v3/resolve/main/flux-canny-controlnet-v3.safetensors?download=true"
    call :grab "xlabs\controlnets\flux-depth-controlnet-v3.safetensors" "https://huggingface.co/XLabs-AI/flux-controlnet-depth-v3/resolve/main/flux-depth-controlnet-v3.safetensors?download=true"
    call :grab "xlabs\controlnets\flux-hed-controlnet-v3.safetensors" "https://huggingface.co/XLabs-AI/flux-controlnet-hed-v3/resolve/main/flux-hed-controlnet-v3.safetensors?download=true"
    call :grab "clip_vision\model.safetensors" "https://huggingface.co/openai/clip-vit-large-patch14/resolve/main/model.safetensors?download=true"
    call :grab "style_models\flux1-redux-dev.safetensors" "https://huggingface.co/Runware/FLUX.1-Redux-dev/resolve/main/flux1-redux-dev.safetensors?download=true"
    call :grab "diffusion_models\flux1-fill-dev.safetensors" "https://huggingface.co/black-forest-labs/FLUX.1-Fill-dev/blob/main/flux1-fill-dev.safetensors?download=true"
    call :grab "vae_approx\taef1_decoder.pth" "https://github.com/madebyollin/taesd/raw/main/taef1_decoder.pth"
    call :grab "vae_approx\taef1_encoder.pth" "https://github.com/madebyollin/taesd/raw/main/taef1_encoder.pth"
)

:: --- Qwen Models ---
if defined FLAG_QWEN_SELECTED (
    echo %YELLOW%--- Downloading supporting files for Qwen...%RESET%
    call :grab "text_encoders\Qwen2.5-VL-7B-Instruct-UD-Q4_K_S.gguf" "%HF_FLX_URL%/Qwen2.5-VL-7B-Instruct-UD-Q4_K_S.gguf?download=true"
    call :grab "text_encoders\Qwen2.5-VL-7B-Instruct-UD-Q4_K_XL.gguf" "%HF_FLX_URL%/Qwen2.5-VL-7B-Instruct-UD-Q4_K_XL.gguf?download=true"
    call :grab "text_encoders\Qwen2.5-VL-7B-Instruct-UD-Q5_K_S.gguf" "%HF_FLX_URL%/Qwen2.5-VL-7B-Instruct-UD-Q5_K_S.gguf?download=true"
    call :grab "text_encoders\Qwen2.5-VL-7B-Instruct-UD-Q8_0.gguf" "%HF_FLX_URL%/Qwen2.5-VL-7B-Instruct-UD-Q8_0.gguf?download=true"
    call :grab "text_encoders\Qwen2.5-VL-7B-Instruct-mmproj-BF16.gguf" "%HF_FLX_URL%/Qwen2.5-VL-7B-Instruct-mmproj-BF16.gguf?download=true"
    call :grab "text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors" "https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors?download=true"
    call :grab "vae\qwen_image_vae.safetensors" "%HF_FLX_URL%/qwen_image_vae.safetensors?download=true"
    call :grab "loras\Qwen-Image-Lightning-8steps-V1.0.safetensors" "https://huggingface.co/lightx2v/Qwen-Image-Lightning/resolve/main/Qwen-Image-Lightning-8steps-V1.0.safetensors?download=true"
    call :grab "loras\Qwen-Image-Lightning-4steps-V1.0.safetensors" "https://huggingface.co/lightx2v/Qwen-Image-Lightning/resolve/main/Qwen-Image-Lightning-4steps-V1.0.safetensors?download=true"
    call :grab "loras/qwen_image_union_diffsynth_lora.safetensors" "https://huggingface.co/Comfy-Org/Qwen-Image-DiffSynth-ControlNets/resolve/main/split_files/loras/qwen_image_union_diffsynth_lora.safetensors?download=true"
)

:: --- HiDream Models ---
if defined FLAG_HIDREAM_SELECTED (
    echo %YELLOW%--- Downloading supporting files for HiDream...%RESET%
    call :grab "text_encoders\clip_g_hidream.safetensors" "%HF_FLX_URL%/clip_g_hidream.safetensors?download=true"
    call :grab "text_encoders\clip_l_hidream.safetensors" "%HF_FLX_URL%/clip_l_hidream.safetensors?download=true"
)

:: --- SD Models ---
if defined FLAG_SD15_SELECTED (
echo %YELLOW%--- Downloading supporting files for SD1.5...%RESET%
    call :grab "vae_approx\taesd_decoder.pth" "https://github.com/madebyollin/taesd/raw/main/taesd_decoder.pth"
    call :grab "vae_approx\taesd_encoder.pth" "https://github.com/madebyollin/taesd/raw/main/taesd_encoder.pth"
)

:: --- SD3 Models ---
if defined FLAG_SD3_SELECTED (
    echo %YELLOW%--- Downloading supporting files for SD3...%RESET%
    call :grab "text_encoders\clip_g.safetensors" "https://huggingface.co/Comfy-Org/stable-diffusion-3.5-fp8/resolve/main/text_encoders/clip_g.safetensors?download=true"
    call :grab "text_encoders\clip_l.safetensors" "https://huggingface.co/Comfy-Org/stable-diffusion-3.5-fp8/resolve/main/text_encoders/clip_l.safetensors?download=true"
    call :grab "vae\sd35_vae.safetensors" "https://civitai.com/api/download/models/985137?type=Model&format=SafeTensor"
    call :grab "vae_approx\taesd3_decoder.pth" "https://github.com/madebyollin/taesd/raw/main/taesd3_decoder.pth"
    call :grab "vae_approx\taesd3_encoder.pth" "https://github.com/madebyollin/taesd/raw/main/taesd3_encoder.pth"
    call :grab "controlnet\sd3.5_large_controlnet_depth.safetensors" "https://huggingface.co/stabilityai/stable-diffusion-3.5-controlnets/resolve/main/sd3.5_large_controlnet_depth.safetensors?download=true"
    call :grab "controlnet\sd3.5_large_controlnet_canny.safetensors" "https://huggingface.co/stabilityai/stable-diffusion-3.5-controlnets/resolve/main/sd3.5_large_controlnet_canny.safetensors?download=true"
    call :grab "controlnet\sd3.5_large_controlnet_blur.safetensors" "https://huggingface.co/stabilityai/stable-diffusion-3.5-controlnets/resolve/main/sd3.5_large_controlnet_blur.safetensors?download=true"
)

:: --- SDXL Models ---
if defined FLAG_SDXL_SELECTED (
    echo %YELLOW%--- Downloading supporting files for SDXL...%RESET%
    call :grab "vae\sdxl_vae.safetensors" "https://huggingface.co/stabilityai/sdxl-vae/resolve/main/sdxl_vae.safetensors?download=true"
    call :grab "checkpoints\sd_xl_refiner_1.0_0.9vae.safetensors" "https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0_0.9vae.safetensors?download=true"
    call :grab "controlnet\controlnet-union-sdxl-1.0.safetensors" "https://huggingface.co/xinsir/controlnet-union-sdxl-1.0/resolve/main/diffusion_pytorch_model_promax.safetensors?download=true"
    call :grab "controlnet\diffusers_xl_canny_full.safetensors" "https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/diffusers_xl_canny_full.safetensors?download=true"
    call :grab "controlnet\diffusers_xl_depth_full.safetensors" "https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/diffusers_xl_depth_full.safetensors?download=true"
    call :grab "controlnet\thibaud_xl_openpose.safetensors" "https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/thibaud_xl_openpose.safetensors?download=true"
    call :grab "vae_approx\taesdxl_decoder.pth" "https://github.com/madebyollin/taesd/raw/main/taesdxl_decoder.pth"
    call :grab "vae_approx\taesdxl_decoder.pth" "https://github.com/madebyollin/taesd/raw/main/taesdxl_decoder.pth"
)

:: --- WAN 2.1 Models ---
if defined FLAG_WAN21_SELECTED (
    echo %YELLOW%--- Downloading supporting files for WAN2.1...%RESET%
    call :grab "vae\wan_2.1_vae.safetensors" "%HF_FLX_URL%/wan_2.1_vae.safetensors?download=true"
    call :grab "loras\Wan2.1_T2V_14B_FusionX_LoRA.safetensors" "%HF_FLX_URL%/Wan2.1_T2V_14B_FusionX_LoRA.safetensors?download=true"
    call :grab "loras\Wan21_T2V_14B_lightx2v_cfg_step_distill_lora_rank32.safetensors" "%HF_FLX_URL%/Wan21_T2V_14B_lightx2v_cfg_step_distill_lora_rank32.safetensors?download=true"
    call :grab "vae\ae.safetensors" "%HF_FLX_URL%/ae.safetensors?download=true"
)

:: --- WAN 2.2 Models ---
if defined FLAG_WAN22_SELECTED (
    echo %YELLOW%--- Downloading supporting files for WAN2.2...%RESET%
    call :grab "vae\wan_2.2_vae.safetensors" "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/vae/wan2.2_vae.safetensors?download=true"
    call :grab "loras\Wan2.2-Lightning_T2V-v1.1-A14B-4steps-lora_LOW_fp16.safetensors" "%HF_FLX_URL%/Wan2.2-Lightning_T2V-v1.1-A14B-4steps-lora_LOW_fp16.safetensors?download=true"
    call :grab "loras\Wan2.2-Lightning_T2V-v1.1-A14B-4steps-lora_HIGH_fp16.safetensors" "%HF_FLX_URL%/Wan2.2-Lightning_T2V-v1.1-A14B-4steps-lora_HIGH_fp16.safetensors?download=true"
    call :grab "loras\wan2.2_t2v_lightx2v_4steps_lora_v1.1_high_noise.safetensors" "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_t2v_lightx2v_4steps_lora_v1.1_high_noise.safetensors?download=true"
    call :grab "loras\wan2.2_t2v_lightx2v_4steps_lora_v1.1_low_noise.safetensors" "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_t2v_lightx2v_4steps_lora_v1.1_low_noise.safetensors?download=true"
    call :grab "loras\Wan2.2-Lightning_I2V-A14B-4steps-lora_LOW_fp16.safetensors" "%HF_FLX_URL%/Wan2.2-Lightning_I2V-A14B-4steps-lora_LOW_fp16.safetensors?download=true"
    call :grab "loras\Wan2.2-Lightning_I2V-A14B-4steps-lora_HIGH_fp16.safetensors" "%HF_FLX_URL%/Wan2.2-Lightning_I2V-A14B-4steps-lora_HIGH_fp16.safetensors?download=true"
    call :grab "loras\wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors" "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors?download=true"
    call :grab "loras\wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors" "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors?download=true"
    call :grab "text_encoders\umt5_xxl_fp8_e4m3fn_scaled.safetensors" "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors?download=true"
)

echo.
echo %YELLOW%--- Downloading general purpose models ^& tools (Upscalers, etc.)...%RESET%
call :grab "upscale_models\4x-ClearRealityV1.pth" "%HF_FLX_URL%/4x-ClearRealityV1.pth?download=true"
call :grab "upscale_models\4x-UltraSharp.pth" "https://huggingface.co/uwg/upscaler/resolve/main/ESRGAN/4x-UltraSharp.pth?download=true"
call :grab "upscale_models\ESRGAN_4x.pth" "https://huggingface.co/Afizi/ESRGAN_4x.pth/resolve/main/ESRGAN_4x.pth?download=true"
call :grab "upscale_models\RealESRGAN_x2.pth" "https://huggingface.co/ai-forever/Real-ESRGAN/resolve/main/RealESRGAN_x2.pth?download=true"
call :grab "upscale_models\RealESRGAN_x4.pth" "https://huggingface.co/ai-forever/Real-ESRGAN/resolve/main/RealESRGAN_x4.pth?download=true"
call :grab "upscale_models\RealESRGAN_x8.pth" "https://huggingface.co/ai-forever/Real-ESRGAN/resolve/main/RealESRGAN_x8.pth?download=true"
call :grab "upscale_models\RealESRGAN_x4plus_anime_6B.pth" "%HF_FLX_URL%/RealESRGAN_x4plus_anime_6B.pth?download=true"
call :grab "upscale_models\4x_NMKD-Siax_200k.pth" "https://huggingface.co/uwg/upscaler/blob/main/ESRGAN/4x_NMKD-Siax_200k.pth"
call :grab "upscale_models\4x_foolhardy_Remacri.pth" "https://huggingface.co/uwg/upscaler/resolve/main/ESRGAN/4x_foolhardy_Remacri.pth?download=true"
call :grab "upscale_models\4x_NMKD-Superscale-SP_178000_G.pth" "https://huggingface.co/uwg/upscaler/resolve/main/ESRGAN/4x_NMKD-Superscale-SP_178000_G.pth?download=true"
call :grab "upscale_models\4xNomos8kDAT.pth" "https://huggingface.co/uwg/upscaler/resolve/main/ESRGAN/4xNomos8kDAT.pth?download=true"
call :grab "sams\sam_vit_b_01ec64.pth" "%HF_FLX_URL%/sam_vit_b_01ec64.pth?download=true"
call :grab "ultralytics\bbox\hand_yolov8s.pt" "https://huggingface.co/xingren23/comfyflow-models/resolve/976de8449674de379b02c144d0b3cfa2b61482f2/ultralytics/bbox/hand_yolov8s.pt?download=true"
call :grab "ultralytics\bbox\face_yolov8m.pt" "https://huggingface.co/xingren23/comfyflow-models/resolve/976de8449674de379b02c144d0b3cfa2b61482f2/ultralytics/bbox/face_yolov8m.pt?download=true"
call :grab "ultralytics\segm\person_yolov8m-seg.pt" "https://huggingface.co/xingren23/comfyflow-models/resolve/976de8449674de379b02c144d0b3cfa2b61482f2/ultralytics/segm/person_yolov8m-seg.pt?download=true"
call :grab "text_encoders\llama_3.1_8b_instruct_fp8_scaled.safetensors" "%HF_FLX_URL%/llama_3.1_8b_instruct_fp8_scaled.safetensors?download=true"
call :grab "clip_vision\sigclip_vision_patch14_384.safetensors" "%HF_FLX_URL%/sigclip_vision_patch14_384.safetensors?download=true"
call :grab "clip\ViT-L-14-TEXT-detail-improved-hiT-GmP-TE-only-HF.safetensors" "%HF_FLX_URL%/ViT-L-14-TEXT-detail-improved-hiT-GmP-TE-only-HF.safetensors?download=true"

echo.
echo %YELLOW%--- Cloning Repo-based Models (InsightFace, Florence, etc.)...%RESET%
if not exist "insightface" git clone %HF_BASE_URL%/insightface
if not exist "LLM\Florence-2-base" git clone %HF_BASE_URL%/Florence-2-base LLM\Florence-2-base
if not exist "LLM\Florence-2-large" git clone %HF_BASE_URL%/Florence-2-large LLM\Florence-2-large

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
    goto :main_menu
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
    goto :main_menu_return
)
echo %YELLOW%Installing Sage Attention...%RESET%
"%PYTHON_EXE%" -m pip install -U https://github.com/woct0rdho/SageAttention/releases/download/v2.2.0-windows.post2/sageattention-2.2.0+cu128torch2.8.0.post2-cp39-abi3-win_amd64.whl
if %errorlevel% neq 0 (
    echo %RED%Sage Attention installation failed.%RESET%
    set "LAST_ACTION_MSG=%RED%Sage Attention installation failed.%RESET%"
    pause
    goto :main_menu_return
)
echo %GREEN%Triton and Sage Attention installed successfully.%RESET%
echo.
echo %YELLOW%Applying '--use-sage-attention' flag to run scripts...%RESET%
call :update_run_scripts
echo.
set "LAST_ACTION_MSG=%GREEN%Triton and Sage Attention installed and enabled.%RESET%"
goto :main_menu_return


:: --- Python Libs/Includes Setup ---
:setup_python_libs
echo.
echo %BLUE%======================================================================%RESET%
echo %BLUE%             Setting up Python Include/Libs for Triton                %RESET%
echo %BLUE%======================================================================%RESET%
echo.
if not exist "%COMFYUI_DIR%" (
    echo %RED%ComfyUI not found. Please run Core Install first.%RESET%
    set "LAST_ACTION_MSG=%RED%Python Libs setup failed: ComfyUI not found.%RESET%"
    pause
    goto :main_menu
)
pushd "%COMFYUI_DIR%"
echo %YELLOW%Downloading include and libs folders...%RESET%
powershell -Command "Invoke-WebRequest -Uri 'https://github.com/woct0rdho/triton-windows/releases/download/v3.0.0-windows.post1/python_3.12.7_include_libs.zip' -OutFile 'libs_include.zip'; Expand-Archive -Path 'libs_include.zip' -DestinationPath 'python_embeded' -Force; Remove-Item 'libs_include.zip'"
if exist "python_embeded\libs" if exist "python_embeded\include" (
    echo %GREEN%Successfully installed include and libs folders.%RESET%
    set "LAST_ACTION_MSG=%GREEN%Python include/libs folders installed successfully.%RESET%"
) else (
    echo %RED%Failed to download or extract folders. Please do it manually.%RESET%
    set "LAST_ACTION_MSG=%RED%Failed to install Python include/libs folders.%RESET%"
)
popd
echo.
goto :main_menu_return


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
:verify_all
echo.
echo %BLUE%======================================================================%RESET%
echo %BLUE%                     Verifying All Components                         %RESET%
echo %BLUE%======================================================================%RESET%
echo.
call :verify_prereqs
call :verify_comfyui
call :verify_nodes
call :verify_python_packages
call :verify_run_scripts
echo.
echo %GREEN%======================================================================%RESET%
echo %GREEN%                       Verification Complete                          %RESET%
echo %GREEN%======================================================================%RESET%
echo.
set "LAST_ACTION_MSG=%GREEN%Full verification process complete. See report above.%RESET%"
pause
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
    echo %RED%[FAIL] ComfyUI directory structure not found. Please install first.%RESET%
    goto :eof
)
echo %GREEN%[OK] ComfyUI directory structure%RESET%
echo.
goto :eof

:verify_nodes
echo %YELLOW%Verifying Custom Nodes...%RESET%
if exist "%CUSTOM_NODES_DIR%\ComfyUI-Manager" (echo %GREEN%[OK] ComfyUI-Manager%RESET%) else (echo %RED%[FAIL] ComfyUI-Manager%RESET%)
if exist "%CUSTOM_NODES_DIR%\comfyui-reactor-node" (echo %GREEN%[OK] Reactor Node%RESET%) else (echo %RED%[FAIL] Reactor Node%RESET%)
echo.
goto :eof

:verify_python_packages
echo %YELLOW%Verifying Python Packages...%RESET%
if not exist "%PYTHON_EXE%" (
    echo %PURPLE%[SKIP] Python executable not found. Cannot verify packages.%RESET%
    goto :eof
)
"%PYTHON_EXE%" -m pip list | findstr /i "triton-windows" >nul && (echo %GREEN%[OK] Triton%RESET%) || (echo %RED%[FAIL] Triton%RESET%)
"%PYTHON_EXE%" -m pip list | findstr /i "sageattention" >nul && (echo %GREEN%[OK] Sage Attention%RESET%) || (echo %RED%[FAIL] Sage Attention%RESET%)
if exist "%COMFYUI_DIR%\python_embeded\libs" (echo %GREEN%[OK] python_embeded\libs folder%RESET%) else (echo %RED%[FAIL] python_embeded\libs folder%RESET%)
if exist "%COMFYUI_DIR%\python_embeded\include" (echo %GREEN%[OK] python_embeded\include folder%RESET%) else (echo %RED%[FAIL] python_embeded\include folder%RESET%)
echo.
goto :eof

:verify_run_scripts
echo %YELLOW%Verifying Run Scripts...%RESET%
findstr /c:"--use-sage-attention" "%COMFYUI_DIR%\run_nvidia_gpu.bat" >nul && (echo %GREEN%[OK] run_nvidia_gpu.bat%RESET%) || (echo %RED%[FAIL] run_nvidia_gpu.bat%RESET%)
echo.
goto :eof

:: --- Menu Return Helper ---
:main_menu_return
if "%main_choice%"=="1" (goto :eof) else (goto :main_menu)


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
if %errorlevel! neq 0 ( echo %RED%Download failed.%RESET% & pause & exit /b 1 )
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
if exist "%DEST_PATH%" (
    echo %PURPLE%[SKIP] %FILENAME% already exists.%RESET%
) else (
    echo %YELLOW%  Downloading %FILENAME%...%RESET%
    curl -# -L -o "%DEST_PATH%" "%DOWNLOAD_URL%" --ssl-no-revoke
    if !errorlevel! neq 0 (
        echo %RED%[ERROR] Download failed for %FILENAME%.%RESET%
        del "%DEST_PATH%" 2>nul
        exit /b 1
    )
)
exit /b 0

:: -----------------------------------------------------------------------------
:: Section 5: Exit
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