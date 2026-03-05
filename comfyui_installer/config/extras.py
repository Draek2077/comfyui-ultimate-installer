"""
All 81 shared/extra model entries.

flag == "ALWAYS" → always download regardless of model family selection.
Otherwise        → download only when the matching family flag is selected.

Repo-based entries (type="repo") are git cloned rather than file-downloaded.
"""

from dataclasses import dataclass

HF = "https://huggingface.co/Aitrepreneur/FLX/resolve/main"


@dataclass
class ExtraModel:
    flag: str     # "FLUX"|"QWEN"|"HIDREAM"|"SD15"|"SDXL"|"SD3"|"WAN21"|"WAN22"|"ALWAYS"
    subdir: str   # subdirectory under models\ (use forward slashes; converted at runtime)
    filename: str # local filename
    url: str      # direct download URL  (or HF repo path for type=="repo")
    model_type: str = "file"  # "file" | "repo"


EXTRA_MODELS: list[ExtraModel] = [
    # ── FLUX extras (001-017) ─────────────────────────────────────────────────
    ExtraModel("FLUX", "diffusion_models", "svdq-fp4_r32-flux.1-kontext-dev.safetensors",  f"{HF}/svdq-fp4_r32-flux.1-kontext-dev.safetensors?download=true"),
    ExtraModel("FLUX", "diffusion_models", "svdq-int4_r32-flux.1-kontext-dev.safetensors", f"{HF}/svdq-int4_r32-flux.1-kontext-dev.safetensors?download=true"),
    ExtraModel("FLUX", "text_encoders",    "umt5-xxl-encoder-Q5_K_S.gguf",                f"{HF}/umt5-xxl-encoder-Q5_K_S.gguf?download=true"),
    ExtraModel("FLUX", "text_encoders",    "t5xxl_fp16.safetensors",                       f"{HF}/t5xxl_fp16.safetensors?download=true"),
    ExtraModel("FLUX", "text_encoders",    "t5xxl_fp8_e4m3fn.safetensors",                f"{HF}/t5xxl_fp8_e4m3fn.safetensors?download=true"),
    ExtraModel("FLUX", "text_encoders",    "t5xxl_fp8_e4m3fn_scaled.safetensors",         f"{HF}/t5xxl_fp8_e4m3fn_scaled.safetensors?download=true"),
    ExtraModel("FLUX", "pulid",            "pulid_flux_v0.9.1.safetensors",               "https://huggingface.co/guozinan/PuLID/resolve/main/pulid_flux_v0.9.1.safetensors?download=true"),
    ExtraModel("FLUX", "controlnet",       "FLUX1-dev-ControlNet-Union-Pro.safetensors",   f"{HF}/Shakker-LabsFLUX1-dev-ControlNet-Union-Pro.safetensors?download=true"),
    ExtraModel("FLUX", "controlnet",       "FLUX1-dev-ControlNet-Depth.safetensors",       "https://huggingface.co/Shakker-Labs/FLUX.1-dev-ControlNet-Depth/resolve/main/diffusion_pytorch_model.safetensors?download=true"),
    ExtraModel("FLUX", "xlabs/ipadapters", "ip_adapter.safetensors",                      "https://huggingface.co/XLabs-AI/flux-ip-adapter-v2/resolve/main/ip_adapter.safetensors?download=true"),
    ExtraModel("FLUX", "xlabs/controlnets","flux-canny-controlnet-v3.safetensors",        "https://huggingface.co/XLabs-AI/flux-controlnet-canny-v3/resolve/main/flux-canny-controlnet-v3.safetensors?download=true"),
    ExtraModel("FLUX", "xlabs/controlnets","flux-depth-controlnet-v3.safetensors",        "https://huggingface.co/XLabs-AI/flux-controlnet-depth-v3/resolve/main/flux-depth-controlnet-v3.safetensors?download=true"),
    ExtraModel("FLUX", "xlabs/controlnets","flux-hed-controlnet-v3.safetensors",          "https://huggingface.co/XLabs-AI/flux-controlnet-hed-v3/resolve/main/flux-hed-controlnet-v3.safetensors?download=true"),
    ExtraModel("FLUX", "clip_vision",      "model.safetensors",                           "https://huggingface.co/openai/clip-vit-large-patch14/resolve/main/model.safetensors?download=true"),
    ExtraModel("FLUX", "style_models",     "flux1-redux-dev.safetensors",                 "https://huggingface.co/Runware/FLUX.1-Redux-dev/resolve/main/flux1-redux-dev.safetensors?download=true"),
    ExtraModel("FLUX", "vae_approx",       "taef1_decoder.pth",                           "https://github.com/madebyollin/taesd/raw/main/taef1_decoder.pth"),
    ExtraModel("FLUX", "vae_approx",       "taef1_encoder.pth",                           "https://github.com/madebyollin/taesd/raw/main/taef1_encoder.pth"),

    # ── QWEN extras (018-027) ─────────────────────────────────────────────────
    ExtraModel("QWEN", "text_encoders",    "Qwen2.5-VL-7B-Instruct-UD-Q4_K_S.gguf",    f"{HF}/Qwen2.5-VL-7B-Instruct-UD-Q4_K_S.gguf?download=true"),
    ExtraModel("QWEN", "text_encoders",    "Qwen2.5-VL-7B-Instruct-UD-Q4_K_XL.gguf",  f"{HF}/Qwen2.5-VL-7B-Instruct-UD-Q4_K_XL.gguf?download=true"),
    ExtraModel("QWEN", "text_encoders",    "Qwen2.5-VL-7B-Instruct-UD-Q5_K_S.gguf",   f"{HF}/Qwen2.5-VL-7B-Instruct-UD-Q5_K_S.gguf?download=true"),
    ExtraModel("QWEN", "text_encoders",    "Qwen2.5-VL-7B-Instruct-UD-Q8_0.gguf",     f"{HF}/Qwen2.5-VL-7B-Instruct-UD-Q8_0.gguf?download=true"),
    ExtraModel("QWEN", "text_encoders",    "Qwen2.5-VL-7B-Instruct-mmproj-BF16.gguf", f"{HF}/Qwen2.5-VL-7B-Instruct-mmproj-BF16.gguf?download=true"),
    ExtraModel("QWEN", "text_encoders",    "qwen_2.5_vl_7b_fp8_scaled.safetensors",   "https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors?download=true"),
    ExtraModel("QWEN", "vae",              "qwen_image_vae.safetensors",               f"{HF}/qwen_image_vae.safetensors?download=true"),
    ExtraModel("QWEN", "loras",            "Qwen-Image-Lightning-8steps-V1.0.safetensors", "https://huggingface.co/lightx2v/Qwen-Image-Lightning/resolve/main/Qwen-Image-Lightning-8steps-V1.0.safetensors?download=true"),
    ExtraModel("QWEN", "loras",            "Qwen-Image-Lightning-4steps-V1.0.safetensors", "https://huggingface.co/lightx2v/Qwen-Image-Lightning/resolve/main/Qwen-Image-Lightning-4steps-V1.0.safetensors?download=true"),
    ExtraModel("QWEN", "loras",            "qwen_image_union_diffsynth_lora.safetensors",  "https://huggingface.co/Comfy-Org/Qwen-Image-DiffSynth-ControlNets/resolve/main/split_files/loras/qwen_image_union_diffsynth_lora.safetensors?download=true"),

    # ── HIDREAM extras (028-029) ──────────────────────────────────────────────
    ExtraModel("HIDREAM", "text_encoders", "clip_g_hidream.safetensors", f"{HF}/clip_g_hidream.safetensors?download=true"),
    ExtraModel("HIDREAM", "text_encoders", "clip_l_hidream.safetensors", f"{HF}/clip_l_hidream.safetensors?download=true"),

    # ── SD15 extras (030-031) ─────────────────────────────────────────────────
    ExtraModel("SD15", "vae_approx", "taesd_decoder.pth", "https://github.com/madebyollin/taesd/raw/main/taesd_decoder.pth"),
    ExtraModel("SD15", "vae_approx", "taesd_encoder.pth", "https://github.com/madebyollin/taesd/raw/main/taesd_encoder.pth"),

    # ── SD3 extras (032-039) ──────────────────────────────────────────────────
    ExtraModel("SD3", "text_encoders", "clip_g.safetensors",                       "https://huggingface.co/Comfy-Org/stable-diffusion-3.5-fp8/resolve/main/text_encoders/clip_g.safetensors?download=true"),
    ExtraModel("SD3", "text_encoders", "clip_l.safetensors",                       "https://huggingface.co/Comfy-Org/stable-diffusion-3.5-fp8/resolve/main/text_encoders/clip_l.safetensors?download=true"),
    ExtraModel("SD3", "vae",           "sd35_vae.safetensors",                     "https://civitai.com/api/download/models/985137?type=Model&format=SafeTensor"),
    ExtraModel("SD3", "vae_approx",    "taesd3_decoder.pth",                       "https://github.com/madebyollin/taesd/raw/main/taesd3_decoder.pth"),
    ExtraModel("SD3", "vae_approx",    "taesd3_encoder.pth",                       "https://github.com/madebyollin/taesd/raw/main/taesd3_encoder.pth"),
    ExtraModel("SD3", "controlnet",    "sd3.5_large_controlnet_depth.safetensors", "https://huggingface.co/stabilityai/stable-diffusion-3.5-controlnets/resolve/main/sd3.5_large_controlnet_depth.safetensors?download=true"),
    ExtraModel("SD3", "controlnet",    "sd3.5_large_controlnet_canny.safetensors", "https://huggingface.co/stabilityai/stable-diffusion-3.5-controlnets/resolve/main/sd3.5_large_controlnet_canny.safetensors?download=true"),
    ExtraModel("SD3", "controlnet",    "sd3.5_large_controlnet_blur.safetensors",  "https://huggingface.co/stabilityai/stable-diffusion-3.5-controlnets/resolve/main/sd3.5_large_controlnet_blur.safetensors?download=true"),

    # ── SDXL extras (040-047) ─────────────────────────────────────────────────
    ExtraModel("SDXL", "vae",       "sdxl_vae.safetensors",                  "https://huggingface.co/stabilityai/sdxl-vae/resolve/main/sdxl_vae.safetensors?download=true"),
    ExtraModel("SDXL", "checkpoints","sd_xl_refiner_1.0_0.9vae.safetensors", "https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0_0.9vae.safetensors?download=true"),
    ExtraModel("SDXL", "controlnet", "controlnet-union-sdxl-1.0.safetensors", "https://huggingface.co/xinsir/controlnet-union-sdxl-1.0/resolve/main/diffusion_pytorch_model_promax.safetensors?download=true"),
    ExtraModel("SDXL", "controlnet", "diffusers_xl_canny_full.safetensors",   "https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/diffusers_xl_canny_full.safetensors?download=true"),
    ExtraModel("SDXL", "controlnet", "diffusers_xl_depth_full.safetensors",   "https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/diffusers_xl_depth_full.safetensors?download=true"),
    ExtraModel("SDXL", "controlnet", "thibaud_xl_openpose.safetensors",       "https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/thibaud_xl_openpose.safetensors?download=true"),
    ExtraModel("SDXL", "vae_approx", "taesdxl_decoder.pth",                   "https://github.com/madebyollin/taesd/raw/main/taesdxl_decoder.pth"),
    ExtraModel("SDXL", "vae_approx", "taesdxl_encoder.pth",                   "https://github.com/madebyollin/taesd/raw/main/taesdxl_encoder.pth"),

    # ── WAN21 extras (048-052) ────────────────────────────────────────────────
    ExtraModel("WAN21", "vae",        "wan_2.1_vae.safetensors",                            f"{HF}/wan_2.1_vae.safetensors?download=true"),
    ExtraModel("WAN21", "loras",      "Wan2.1_T2V_14B_FusionX_LoRA.safetensors",           f"{HF}/Wan2.1_T2V_14B_FusionX_LoRA.safetensors?download=true"),
    ExtraModel("WAN21", "loras",      "Wan21_T2V_14B_lightx2v_cfg_step_distill_lora_rank32.safetensors", f"{HF}/Wan21_T2V_14B_lightx2v_cfg_step_distill_lora_rank32.safetensors?download=true"),
    ExtraModel("WAN21", "vae",        "ae.safetensors",                                     f"{HF}/ae.safetensors?download=true"),
    ExtraModel("WAN21", "clip_vision","clip_vision_h.safetensors",                          "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors?download=true"),

    # ── WAN22 extras (053-062) ────────────────────────────────────────────────
    ExtraModel("WAN22", "vae",   "wan_2.2_vae.safetensors",                                              "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/vae/wan2.2_vae.safetensors?download=true"),
    ExtraModel("WAN22", "loras", "Wan2.2-Lightning_T2V-v1.1-A14B-4steps-lora_LOW_fp16.safetensors",     f"{HF}/Wan2.2-Lightning_T2V-v1.1-A14B-4steps-lora_LOW_fp16.safetensors?download=true"),
    ExtraModel("WAN22", "loras", "Wan2.2-Lightning_T2V-v1.1-A14B-4steps-lora_HIGH_fp16.safetensors",    f"{HF}/Wan2.2-Lightning_T2V-v1.1-A14B-4steps-lora_HIGH_fp16.safetensors?download=true"),
    ExtraModel("WAN22", "loras", "wan2.2_t2v_lightx2v_4steps_lora_v1.1_high_noise.safetensors",         "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_t2v_lightx2v_4steps_lora_v1.1_high_noise.safetensors?download=true"),
    ExtraModel("WAN22", "loras", "wan2.2_t2v_lightx2v_4steps_lora_v1.1_low_noise.safetensors",          "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_t2v_lightx2v_4steps_lora_v1.1_low_noise.safetensors?download=true"),
    ExtraModel("WAN22", "loras", "Wan2.2-Lightning_I2V-A14B-4steps-lora_LOW_fp16.safetensors",          f"{HF}/Wan2.2-Lightning_I2V-A14B-4steps-lora_LOW_fp16.safetensors?download=true"),
    ExtraModel("WAN22", "loras", "Wan2.2-Lightning_I2V-A14B-4steps-lora_HIGH_fp16.safetensors",         f"{HF}/Wan2.2-Lightning_I2V-A14B-4steps-lora_HIGH_fp16.safetensors?download=true"),
    ExtraModel("WAN22", "loras", "wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors",           "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors?download=true"),
    ExtraModel("WAN22", "loras", "wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors",            "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors?download=true"),
    ExtraModel("WAN22", "text_encoders", "umt5_xxl_fp8_e4m3fn_scaled.safetensors",                      "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors?download=true"),

    # ── ALWAYS extras (063-081) ───────────────────────────────────────────────
    ExtraModel("ALWAYS", "upscale_models",    "4x-ClearRealityV1.pth",                  f"{HF}/4x-ClearRealityV1.pth?download=true"),
    ExtraModel("ALWAYS", "upscale_models",    "4x-UltraSharp.pth",                      "https://huggingface.co/uwg/upscaler/resolve/main/ESRGAN/4x-UltraSharp.pth?download=true"),
    ExtraModel("ALWAYS", "upscale_models",    "ESRGAN_4x.pth",                          "https://huggingface.co/Afizi/ESRGAN_4x.pth/resolve/main/ESRGAN_4x.pth?download=true"),
    ExtraModel("ALWAYS", "upscale_models",    "RealESRGAN_x2.pth",                      "https://huggingface.co/ai-forever/Real-ESRGAN/resolve/main/RealESRGAN_x2.pth?download=true"),
    ExtraModel("ALWAYS", "upscale_models",    "RealESRGAN_x4.pth",                      "https://huggingface.co/ai-forever/Real-ESRGAN/resolve/main/RealESRGAN_x4.pth?download=true"),
    ExtraModel("ALWAYS", "upscale_models",    "RealESRGAN_x8.pth",                      "https://huggingface.co/ai-forever/Real-ESRGAN/resolve/main/RealESRGAN_x8.pth?download=true"),
    ExtraModel("ALWAYS", "upscale_models",    "RealESRGAN_x4plus_anime_6B.pth",         f"{HF}/RealESRGAN_x4plus_anime_6B.pth?download=true"),
    ExtraModel("ALWAYS", "upscale_models",    "4x_NMKD-Siax_200k.pth",                 "https://huggingface.co/uwg/upscaler/resolve/main/ESRGAN/4x_NMKD-Siax_200k.pth"),
    ExtraModel("ALWAYS", "upscale_models",    "4x_foolhardy_Remacri.pth",               "https://huggingface.co/uwg/upscaler/resolve/main/ESRGAN/4x_foolhardy_Remacri.pth?download=true"),
    ExtraModel("ALWAYS", "upscale_models",    "4x_NMKD-Superscale-SP_178000_G.pth",    "https://huggingface.co/uwg/upscaler/resolve/main/ESRGAN/4x_NMKD-Superscale-SP_178000_G.pth?download=true"),
    ExtraModel("ALWAYS", "upscale_models",    "4xNomos8kDAT.pth",                       "https://huggingface.co/uwg/upscaler/resolve/main/ESRGAN/4xNomos8kDAT.pth?download=true"),
    ExtraModel("ALWAYS", "sams",              "sam_vit_b_01ec64.pth",                   f"{HF}/sam_vit_b_01ec64.pth?download=true"),
    ExtraModel("ALWAYS", "ultralytics/bbox",  "hand_yolov8s.pt",                        "https://huggingface.co/xingren23/comfyflow-models/resolve/976de8449674de379b02c144d0b3cfa2b61482f2/ultralytics/bbox/hand_yolov8s.pt?download=true"),
    ExtraModel("ALWAYS", "ultralytics/bbox",  "face_yolov8m.pt",                        "https://huggingface.co/xingren23/comfyflow-models/resolve/976de8449674de379b02c144d0b3cfa2b61482f2/ultralytics/bbox/face_yolov8m.pt?download=true"),
    ExtraModel("ALWAYS", "ultralytics/segm",  "person_yolov8m-seg.pt",                  "https://huggingface.co/xingren23/comfyflow-models/resolve/976de8449674de379b02c144d0b3cfa2b61482f2/ultralytics/segm/person_yolov8m-seg.pt?download=true"),
    ExtraModel("ALWAYS", "text_encoders",     "llama_3.1_8b_instruct_fp8_scaled.safetensors", f"{HF}/llama_3.1_8b_instruct_fp8_scaled.safetensors?download=true"),
    ExtraModel("ALWAYS", "clip_vision",       "sigclip_vision_patch14_384.safetensors", f"{HF}/sigclip_vision_patch14_384.safetensors?download=true"),
    ExtraModel("ALWAYS", "clip",              "ViT-L-14-TEXT-detail-improved-hiT-GmP-TE-only-HF.safetensors", f"{HF}/ViT-L-14-TEXT-detail-improved-hiT-GmP-TE-only-HF.safetensors?download=true"),
    ExtraModel("ALWAYS", "llm_gguf",          "Hermes-3-Llama-3.1-8B.Q8_0.gguf",       "https://huggingface.co/NousResearch/Hermes-3-Llama-3.1-8B-GGUF/resolve/main/Hermes-3-Llama-3.1-8B.Q8_0.gguf?download=true"),
]

# Repo-based extras: git cloned into models\ subdirectory
REPO_EXTRAS: list[tuple[str, str, str]] = [
    # (flag,    dest_subdir,                  hf_repo_url)
    ("ALWAYS", "insightface",                "https://huggingface.co/Aitrepreneur/insightface"),
    ("ALWAYS", "llm/Florence-2-base",        "https://huggingface.co/Aitrepreneur/Florence-2-base"),
    ("ALWAYS", "llm/Florence-2-large",       "https://huggingface.co/Aitrepreneur/Florence-2-large"),
]
