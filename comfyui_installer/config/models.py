"""
All 21 model families with their quality-tier options.

Quality tier indices (0-based):
  0 → Q4 GGUF    (<12 GB VRAM)
  1 → Q5 GGUF    (12-16 GB VRAM)
  2 → Q6 GGUF    (~16 GB VRAM)
  3 → Q8 GGUF    (>16 GB VRAM)
  4 → FP8        (>24 GB VRAM, SafeTensors)
  5 → Full/BF16  (>32 GB VRAM, SafeTensors)

Not all families have 6 tiers; fallback logic installs the highest tier ≤ user choice.

model_type → destination directory:
  "gguf"            → models/unet/
  "gguf_flux"       → models/unet/  AND downloads T5 encoder companion
  "checkpoint"      → models/checkpoints/
  "checkpoints"     → models/checkpoints/
  "diffusion_model" → models/diffusion_models/
  "lora"            → models/loras/
"""

from dataclasses import dataclass, field

HF = "https://huggingface.co/Aitrepreneur/FLX/resolve/main"


@dataclass
class ModelOption:
    name: str             # Display name shown in UI
    filename: str         # Local filename after download
    model_type: str       # Determines destination directory
    url: str              # Direct download URL
    tier: int | None = None  # Global quality tier (0=Q4…5=Full); None = use list index


@dataclass
class ModelFamily:
    id: int                            # 1–21
    name: str                          # Human-readable name
    family_flag: str                   # For extras filtering
    options: list[ModelOption] = field(default_factory=list)


MODEL_FAMILIES: list[ModelFamily] = [

    # ── 01 FLUX-Dev ────────────────────────────────────────────────────────────
    ModelFamily(1, "FLUX-Dev", "FLUX", [
        ModelOption("Q4_K_S (GGUF, <12GB VRAM)",        "flux1-dev-Q4_K_S.gguf",     "gguf_flux", f"{HF}/flux1-dev-Q4_K_S.gguf"),
        ModelOption("Q5_K_S (GGUF, 12-16GB VRAM)",      "flux1-dev-Q5_K_S.gguf",     "gguf_flux", f"{HF}/flux1-dev-Q5_K_S.gguf"),
        ModelOption("Q6_K   (GGUF, ~16GB VRAM)",        "flux1-dev-Q6_K.gguf",       "gguf_flux", "https://huggingface.co/city96/FLUX.1-dev-gguf/resolve/main/flux1-dev-Q6_K.gguf?download=true"),
        ModelOption("Q8_0   (GGUF, >16GB VRAM)",        "flux1-dev-Q8_0.gguf",       "gguf_flux", f"{HF}/flux1-dev-Q8_0.gguf"),
        ModelOption("FP8    (Safetensor, >24GB VRAM)",  "flux1-dev-fp8.safetensors", "diffusion_model", f"{HF}/flux1-dev-fp8.safetensors"),
        ModelOption("FP16   (Safetensor, >32GB VRAM)",  "flux1-dev.safetensors",     "diffusion_model", f"{HF}/flux1-dev.sft"),
    ]),

    # ── 02 FLUX-Fill-Dev ───────────────────────────────────────────────────────
    ModelFamily(2, "FLUX-Fill-Dev", "FLUX", [
        ModelOption("Q4_K_S (GGUF, <12GB VRAM)",        "flux1-fill-dev-Q4_K_S.gguf",     "gguf_flux", f"{HF}/flux1-fill-dev-Q4_K_S.gguf",     tier=0),
        ModelOption("Q5_K_S (GGUF, 12-16GB VRAM)",      "flux1-fill-dev-Q5_K_S.gguf",     "gguf_flux", f"{HF}/flux1-fill-dev-Q5_K_S.gguf",     tier=1),
        ModelOption("Q8_0   (GGUF, >16GB VRAM)",        "flux1-fill-dev-Q8_0.gguf",       "gguf_flux", f"{HF}/flux1-fill-dev-Q8_0.gguf",       tier=3),
        ModelOption("FP8    (Safetensor, >24GB VRAM)",  "flux1-fill-dev_fp8.safetensors", "diffusion_model", f"{HF}/flux1-fill-dev_fp8.safetensors", tier=4),
    ]),

    # ── 03 FLUX-Schnell ────────────────────────────────────────────────────────
    ModelFamily(3, "FLUX-Schnell", "FLUX", [
        ModelOption("Q4_K_S (GGUF, <12GB VRAM)",        "flux1-schnell-Q4_K_S.gguf",     "gguf", f"{HF}/flux1-schnell-Q4_K_S.gguf"),
        ModelOption("Q5_K_S (GGUF, 12-16GB VRAM)",      "flux1-schnell-Q5_K_S.gguf",     "gguf", f"{HF}/flux1-schnell-Q5_K_S.gguf"),
        ModelOption("Q6_K   (GGUF, ~16GB VRAM)",        "flux1-schnell-Q6_K.gguf",       "gguf", "https://huggingface.co/city96/FLUX.1-schnell-gguf/resolve/main/flux1-schnell-Q6_K.gguf?download=true"),
        ModelOption("Q8_0   (GGUF, >16GB VRAM)",        "flux1-schnell-Q8_0.gguf",       "gguf", f"{HF}/flux1-schnell-Q8_0.gguf"),
        ModelOption("FP8    (Safetensors, >24GB VRAM)", "flux1-schnell-fp8.safetensors", "diffusion_model", f"{HF}/flux1-schnell-fp8.safetensors"),
        ModelOption("FP16   (Safetensors, >32GB VRAM)", "flux1-schnell.safetensors",     "diffusion_model", "https://huggingface.co/OlafCC/flux1-schnell.safetensors/resolve/main/flux1-schnell.safetensors?download=true"),
    ]),

    # ── 04 FLUX-Kontext ────────────────────────────────────────────────────────
    ModelFamily(4, "FLUX-Kontext", "FLUX", [
        ModelOption("Q4_K_S (GGUF, <12GB VRAM)",        "flux1-kontext-dev-Q4_K_S.gguf",            "gguf", f"{HF}/flux1-kontext-dev-Q4_K_S.gguf"),
        ModelOption("Q5_K_S (GGUF, 12-24GB VRAM)",      "flux1-kontext-dev-Q5_K_S.gguf",            "gguf", f"{HF}/flux1-kontext-dev-Q5_K_S.gguf"),
        ModelOption("Q6_K   (GGUF, ~24GB VRAM)",        "flux1-kontext-dev-Q6_K.gguf",              "gguf", "https://huggingface.co/QuantStack/FLUX.1-Kontext-dev-GGUF/resolve/main/flux1-kontext-dev-Q6_K.gguf?download=true"),
        ModelOption("Q8_0   (GGUF, >24GB VRAM)",        "flux1-kontext-dev-Q8_0.gguf",              "gguf", f"{HF}/flux1-kontext-dev-Q8_0.gguf"),
        ModelOption("FP8    (Safetensor, >24GB VRAM)",  "flux1-kontext-dev-fp8-e4m3fn.safetensors", "diffusion_model", f"{HF}/flux1-kontext-dev-fp8-e4m3fn.safetensors"),
    ]),

    # ── 05 Qwen-Image ──────────────────────────────────────────────────────────
    ModelFamily(5, "Qwen-Image", "QWEN", [
        ModelOption("Q4_K_S (GGUF, <12GB VRAM)",        "Qwen_Image_Distill-Q4_K_S.gguf",    "gguf", f"{HF}/Qwen_Image_Distill-Q4_K_S.gguf"),
        ModelOption("Q5_K_S (GGUF, 12-24GB VRAM)",      "Qwen_Image_Distill-Q5_K_S.gguf",    "gguf", f"{HF}/Qwen_Image_Distill-Q5_K_S.gguf"),
        ModelOption("Q6_K   (GGUF, ~24GB VRAM)",        "Qwen_Image_Distill-Q6_K.gguf",      "gguf", "https://huggingface.co/QuantStack/Qwen-Image-Distill-GGUF/resolve/main/Qwen_Image_Distill-Q6_K.gguf?download=true"),
        ModelOption("Q8_0   (GGUF, >24GB VRAM)",        "Qwen_Image_Distill-Q8_0.gguf",      "gguf", f"{HF}/Qwen_Image_Distill-Q8_0.gguf"),
        ModelOption("FP8    (Safetensor, >24GB VRAM)",  "qwen_image_fp8_e4m3fn.safetensors", "diffusion_model", "https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/diffusion_models/qwen_image_fp8_e4m3fn.safetensors?download=true"),
        ModelOption("BF16   (Safetensor, >32GB VRAM)",  "qwen_image_bf16.safetensors",       "diffusion_model", "https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/diffusion_models/qwen_image_bf16.safetensors?download=true"),
    ]),

    # ── 06 Qwen-Edit ───────────────────────────────────────────────────────────
    ModelFamily(6, "Qwen-Edit", "QWEN", [
        ModelOption("Q4_K_S (GGUF, <12GB VRAM)",        "Qwen_Image_Edit-Q4_K_S.gguf",            "gguf", f"{HF}/Qwen_Image_Edit-Q4_K_S.gguf"),
        ModelOption("Q5_K_S (GGUF, 12-24GB VRAM)",      "Qwen_Image_Edit-Q5_K_S.gguf",            "gguf", f"{HF}/Qwen_Image_Edit-Q5_K_S.gguf"),
        ModelOption("Q6_K   (GGUF, ~24GB VRAM)",        "Qwen_Image_Edit-Q6_K.gguf",              "gguf", "https://huggingface.co/QuantStack/Qwen-Image-Edit-GGUF/resolve/main/Qwen_Image_Edit-Q6_K.gguf?download=true"),
        ModelOption("Q8_0   (GGUF, >24GB VRAM)",        "Qwen_Image_Edit-Q8_0.gguf",              "gguf", f"{HF}/Qwen_Image_Edit-Q8_0.gguf"),
        ModelOption("FP8    (Safetensor, >24GB VRAM)",  "qwen_image_edit_fp8_e4m3fn.safetensors", "diffusion_model", "https://huggingface.co/Comfy-Org/Qwen-Image-Edit_ComfyUI/resolve/main/split_files/diffusion_models/qwen_image_edit_fp8_e4m3fn.safetensors?download=true"),
        ModelOption("BF16   (Safetensor, >32GB VRAM)",  "qwen_image_edit_bf16.safetensors",       "diffusion_model", "https://huggingface.co/Comfy-Org/Qwen-Image-Edit_ComfyUI/resolve/main/split_files/diffusion_models/qwen_image_edit_bf16.safetensors?download=true"),
    ]),

    # ── 07 HiDream ─────────────────────────────────────────────────────────────
    ModelFamily(7, "HiDream", "HIDREAM", [
        ModelOption("Q4_K_S (GGUF, <12GB VRAM)",        "hidream-i1-dev-Q4_K_S.gguf",      "gguf", f"{HF}/hidream-i1-dev-Q4_K_S.gguf"),
        ModelOption("Q5_K_S (GGUF, 12-16GB VRAM)",      "hidream-i1-dev-Q5_K_S.gguf",      "gguf", f"{HF}/hidream-i1-dev-Q5_K_S.gguf"),
        ModelOption("Q6_K   (GGUF, ~16GB VRAM)",        "hidream-i1-dev-Q6_K.gguf",        "gguf", "https://huggingface.co/city96/HiDream-I1-Dev-gguf/resolve/main/hidream-i1-dev-Q6_K.gguf?download=true"),
        ModelOption("Q8_0   (GGUF, >16GB VRAM)",        "hidream-i1-dev-Q8_0.gguf",        "gguf", f"{HF}/hidream-i1-dev-Q8_0.gguf"),
        ModelOption("FP8    (Safetensor, >24GB VRAM)",  "hidream_i1_dev_fp8.safetensors",  "diffusion_model", f"{HF}/hidream_i1_dev_fp8.safetensors"),
        ModelOption("BF16   (Safetensor, >32GB VRAM)",  "hidream_i1_dev_bf16.safetensors", "diffusion_model", "https://huggingface.co/Comfy-Org/HiDream-I1_ComfyUI/resolve/main/split_files/diffusion_models/hidream_i1_dev_bf16.safetensors?download=true"),
    ]),

    # ── 08 SD1.5 ───────────────────────────────────────────────────────────────
    ModelFamily(8, "SD1.5", "SD15", [
        ModelOption("Full (Safetensor, 12GB VRAM)", "v1-5-pruned-emaonly-fp16.safetensors", "checkpoint", "https://huggingface.co/Comfy-Org/stable-diffusion-v1-5-archive/resolve/main/v1-5-pruned-emaonly-fp16.safetensors?download=true"),
    ]),

    # ── 09 SDXL ────────────────────────────────────────────────────────────────
    ModelFamily(9, "SDXL", "SDXL", [
        ModelOption("Base (Safetensor, 12GB VRAM)", "sd_xl_base_1.0_0.9vae.safetensors", "checkpoint", f"{HF}/sd_xl_base_1.0_0.9vae.safetensors"),
    ]),

    # ── 10 SD3.5 ───────────────────────────────────────────────────────────────
    ModelFamily(10, "SD3.5", "SD3", [
        ModelOption("Medium 2B      (Safetensor, 6-8GB VRAM)",   "sd3.5_medium.safetensors",             "diffusion_model", f"{HF}/sd3.5_medium.safetensors"),
        ModelOption("Large Turbo 8B (Safetensor, 16-24GB VRAM)", "sd3.5_large_turbo.safetensors",        "checkpoints",     "https://huggingface.co/calcuis/sd3.5-large-turbo/resolve/main/sd3.5_large_turbo.safetensors?download=true"),
        ModelOption("Large 8B FP8   (Safetensor, 16-24GB VRAM)", "sd3.5_large_fp8_scaled.safetensors",  "checkpoints",     "https://huggingface.co/Comfy-Org/stable-diffusion-3.5-fp8/resolve/main/sd3.5_large_fp8_scaled.safetensors?download=true"),
        ModelOption("Large 8B       (Safetensor, 16-24GB VRAM)", "sd3.5_large.safetensors",             "diffusion_model", f"{HF}/sd3.5_large.safetensors"),
    ]),

    # ── 11 WAN2.1-T2V ──────────────────────────────────────────────────────────
    ModelFamily(11, "WAN2.1-T2V", "WAN21", [
        ModelOption("Q4_K_S (GGUF, <12GB VRAM)",        "wan2.1-t2v-14b-Q4_K_S.gguf",            "gguf", f"{HF}/wan2.1-t2v-14b-Q4_K_S.gguf"),
        ModelOption("Q5_K_S (GGUF, 12-16GB VRAM)",      "wan2.1-t2v-14b-Q5_K_S.gguf",            "gguf", f"{HF}/wan2.1-t2v-14b-Q5_K_S.gguf"),
        ModelOption("Q6_K   (GGUF, ~16GB VRAM)",        "wan2.1-t2v-14b-Q6_K.gguf",              "gguf", "https://huggingface.co/city96/Wan2.1-T2V-14B-gguf/resolve/main/wan2.1-t2v-14b-Q6_K.gguf?download=true"),
        ModelOption("Q8_0   (GGUF, >16GB VRAM)",        "wan2.1-t2v-14b-Q8_0.gguf",              "gguf", f"{HF}/wan2.1-t2v-14b-Q8_0.gguf"),
        ModelOption("FP8    (Safetensors, >24GB VRAM)", "wan2.1_t2v_14B_fp8_e4m3fn.safetensors", "diffusion_model", "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_t2v_14B_fp8_e4m3fn.safetensors?download=true"),
        ModelOption("BF16   (Safetensors, >32GB VRAM)", "wan2.1_t2v_14B_bf16.safetensors",       "diffusion_model", f"{HF}/wan2.1_t2v_14B_bf16.safetensors"),
    ]),

    # ── 12 WAN2.1-I2V-480 ─────────────────────────────────────────────────────
    ModelFamily(12, "WAN2.1-I2V-480", "WAN21", [
        ModelOption("Q4_K_S (GGUF, <12GB VRAM)",        "wan2.1-i2v-14b-480p-Q4_K_S.gguf",            "gguf", f"{HF}/wan2.1-i2v-14b-480p-Q4_K_S.gguf"),
        ModelOption("Q5_K_S (GGUF, 12-16GB VRAM)",      "wan2.1-i2v-14b-480p-Q5_K_S.gguf",            "gguf", f"{HF}/wan2.1-i2v-14b-480p-Q5_K_S.gguf"),
        ModelOption("Q6_K   (GGUF, ~16GB VRAM)",        "wan2.1-i2v-14b-480p-Q6_K.gguf",              "gguf", "https://huggingface.co/city96/Wan2.1-I2V-14B-480P-gguf/resolve/main/wan2.1-i2v-14b-480p-Q6_K.gguf?download=true"),
        ModelOption("Q8_0   (GGUF, >16GB VRAM)",        "wan2.1-i2v-14b-480p-Q8_0.gguf",              "gguf", f"{HF}/wan2.1-i2v-14b-480p-Q8_0.gguf"),
        ModelOption("FP8    (Safetensors, >24GB VRAM)", "wan2.1_i2v_480p_14B_fp8_e4m3fn.safetensors", "diffusion_model", "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_i2v_480p_14B_fp8_e4m3fn.safetensors?download=true"),
        ModelOption("BF16   (Safetensors, >32GB VRAM)", "wan2.1_i2v_480p_14B_bf16.safetensors",       "diffusion_model", f"{HF}/wan2.1_i2v_480p_14B_bf16.safetensors"),
    ]),

    # ── 13 WAN2.1-I2V-720 ─────────────────────────────────────────────────────
    ModelFamily(13, "WAN2.1-I2V-720", "WAN21", [
        ModelOption("Q4_K_S (GGUF, <12GB VRAM)",        "wan2.1-i2v-14b-720p-Q4_K_S.gguf",            "gguf", f"{HF}/wan2.1-i2v-14b-720p-Q4_K_S.gguf"),
        ModelOption("Q5_K_S (GGUF, 12-16GB VRAM)",      "wan2.1-i2v-14b-720p-Q5_K_S.gguf",            "gguf", f"{HF}/wan2.1-i2v-14b-720p-Q5_K_S.gguf"),
        ModelOption("Q6_K   (GGUF, ~16GB VRAM)",        "wan2.1-i2v-14b-720p-Q6_K.gguf",              "gguf", "https://huggingface.co/city96/Wan2.1-I2V-14B-720P-gguf/resolve/main/wan2.1-i2v-14b-720p-Q6_K.gguf?download=true"),
        ModelOption("Q8_0   (GGUF, >16GB VRAM)",        "wan2.1-i2v-14b-720p-Q8_0.gguf",              "gguf", f"{HF}/wan2.1-i2v-14b-720p-Q8_0.gguf"),
        ModelOption("FP8    (Safetensors, >24GB VRAM)", "wan2.1_i2v_720p_14B_fp8_e4m3fn.safetensors", "diffusion_model", "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_i2v_720p_14B_fp8_e4m3fn.safetensors?download=true"),
        ModelOption("BF16   (Safetensors, >32GB VRAM)", "wan2.1_i2v_720p_14B_bf16.safetensors",       "diffusion_model", f"{HF}/wan2.1_i2v_720p_14B_bf16.safetensors"),
    ]),

    # ── 14 WAN2.1-T2V-FusionX ─────────────────────────────────────────────────
    ModelFamily(14, "WAN2.1-T2V-FusionX", "WAN21", [
        ModelOption("Q4_K_S (GGUF, <13GB VRAM)",   "Wan14BT2VFusionX-Q4_K_S.gguf", "gguf", f"{HF}/Wan14BT2VFusionX-Q4_K_S.gguf"),
        ModelOption("Q5_K_S (GGUF, 13-16GB VRAM)", "Wan14BT2VFusionX-Q5_K_S.gguf", "gguf", f"{HF}/Wan14BT2VFusionX-Q5_K_S.gguf"),
        ModelOption("Q6_K   (GGUF, ~16GB VRAM)",   "Wan14BT2VFusionX-Q6_K.gguf",   "gguf", "https://huggingface.co/QuantStack/Wan2.1_T2V_14B_FusionX-GGUF/resolve/main/Wan2.1_T2V_14B_FusionX-Q6_K.gguf?download=true"),
        ModelOption("Q8_0   (GGUF, >16GB VRAM)",   "Wan14BT2VFusionX-Q8_0.gguf",   "gguf", f"{HF}/Wan14BT2VFusionX-Q8_0.gguf"),
    ]),

    # ── 15 WAN2.1-T2V-FusionX-Vace ────────────────────────────────────────────
    ModelFamily(15, "WAN2.1-T2V-FusionX-Vace", "WAN21", [
        ModelOption("Q4_K_S (GGUF, <12GB VRAM)",   "Wan2.1_T2V_14B_FusionX_VACE-Q4_K_S.gguf", "gguf", f"{HF}/Wan2.1_T2V_14B_FusionX_VACE-Q4_K_S.gguf"),
        ModelOption("Q5_K_S (GGUF, 12-16GB VRAM)", "Wan2.1_T2V_14B_FusionX_VACE-Q5_K_S.gguf", "gguf", f"{HF}/Wan2.1_T2V_14B_FusionX_VACE-Q5_K_S.gguf"),
        ModelOption("Q6_K   (GGUF, ~16GB VRAM)",   "Wan2.1_T2V_14B_FusionX_VACE-Q6_K.gguf",   "gguf", "https://huggingface.co/QuantStack/Wan2.1_T2V_14B_FusionX-GGUF/resolve/main/Wan2.1_T2V_14B_FusionX-Q6_K.gguf?download=true"),
        ModelOption("Q8_0   (GGUF, >16GB VRAM)",   "Wan2.1_T2V_14B_FusionX_VACE-Q8_0.gguf",   "gguf", f"{HF}/Wan2.1_T2V_14B_FusionX_VACE-Q8_0.gguf"),
    ]),

    # ── 16 WAN2.1-Vace ────────────────────────────────────────────────────────
    ModelFamily(16, "WAN2.1-Vace", "WAN21", [
        ModelOption("Q4_K_S (GGUF, <12GB VRAM)",        "Wan2.1-VACE-14B-Q4_K_S.gguf",            "gguf", f"{HF}/Wan2.1-VACE-14B-Q4_K_S.gguf"),
        ModelOption("Q5_K_S (GGUF, 12-16GB VRAM)",      "Wan2.1-VACE-14B-Q5_K_S.gguf",            "gguf", f"{HF}/Wan2.1-VACE-14B-Q5_K_S.gguf"),
        ModelOption("Q6_K   (GGUF, ~16GB VRAM)",        "Wan2.1-VACE-14B-Q6_K.gguf",              "gguf", "https://huggingface.co/QuantStack/Wan2.1_14B_VACE-GGUF/resolve/main/Wan2.1_14B_VACE-Q6_K.gguf?download=true"),
        ModelOption("Q8_0   (GGUF, >16GB VRAM)",        "Wan2.1-VACE-14B-Q8_0.gguf",              "gguf", f"{HF}/Wan2.1-VACE-14B-Q8_0.gguf"),
        ModelOption("FP8    (Safetensors, >24GB VRAM)", "wan2.1_vace_14B_fp8_e4m3fn.safetensors", "diffusion_model", "https://huggingface.co/Kamikaze-88/Wan2.1-VACE-14B-fp8/resolve/main/wan2.1_vace_14B_fp8_e4m3fn.safetensors?download=true"),
        ModelOption("FP16   (Safetensors, >32GB VRAM)", "wan2.1_vace_14B_fp16.safetensors",       "diffusion_model", "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_vace_14B_fp16.safetensors?download=true"),
    ]),

    # ── 17 WAN2.2-I2V-L ───────────────────────────────────────────────────────
    ModelFamily(17, "WAN2.2-I2V-L", "WAN22", [
        ModelOption("Low Q4_K_S  (GGUF, <12GB VRAM)",        "Wan2.2-I2V-A14B-LowNoise-Q4_K_S.gguf",            "gguf", f"{HF}/Wan2.2-I2V-A14B-LowNoise-Q4_K_S.gguf"),
        ModelOption("Low Q5_K_S  (GGUF, 12-16GB VRAM)",      "Wan2.2-I2V-A14B-LowNoise-Q5_K_S.gguf",            "gguf", f"{HF}/Wan2.2-I2V-A14B-LowNoise-Q5_K_S.gguf"),
        ModelOption("Low Q6_K    (GGUF, ~16GB VRAM)",        "Wan2.2-I2V-A14B-LowNoise-Q6_K.gguf",              "gguf", "https://huggingface.co/QuantStack/Wan2.2-I2V-A14B-GGUF/resolve/main/LowNoise/Wan2.2-I2V-A14B-LowNoise-Q6_K.gguf?download=true"),
        ModelOption("Low Q8_0    (GGUF, >16GB VRAM)",        "Wan2.2-I2V-A14B-LowNoise-Q8_0.gguf",              "gguf", f"{HF}/Wan2.2-I2V-A14B-LowNoise-Q8_0.gguf"),
        ModelOption("Low FP8     (Safetensors, >24GB VRAM)", "wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors", "diffusion_model", "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors?download=true"),
        ModelOption("Low FP16    (Safetensors, >32GB VRAM)", "wan2.2_i2v_low_noise_14B_fp16.safetensors",       "diffusion_model", "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_low_noise_14B_fp16.safetensors?download=true"),
    ]),

    # ── 18 WAN2.2-I2V-H ───────────────────────────────────────────────────────
    ModelFamily(18, "WAN2.2-I2V-H", "WAN22", [
        ModelOption("High Q4_K_S (GGUF, <12GB VRAM)",        "Wan2.2-I2V-A14B-HighNoise-Q4_K_S.gguf",            "gguf", f"{HF}/Wan2.2-I2V-A14B-HighNoise-Q4_K_S.gguf"),
        ModelOption("High Q5_K_S (GGUF, 12-16GB VRAM)",      "Wan2.2-I2V-A14B-HighNoise-Q5_K_S.gguf",            "gguf", f"{HF}/Wan2.2-I2V-A14B-HighNoise-Q5_K_S.gguf"),
        ModelOption("High Q6_K   (GGUF, ~16GB VRAM)",        "Wan2.2-I2V-A14B-HighNoise-Q6_K.gguf",              "gguf", "https://huggingface.co/QuantStack/Wan2.2-I2V-A14B-GGUF/resolve/main/HighNoise/Wan2.2-I2V-A14B-HighNoise-Q6_K.gguf?download=true"),
        ModelOption("High Q8_0   (GGUF, >16GB VRAM)",        "Wan2.2-I2V-A14B-HighNoise-Q8_0.gguf",              "gguf", f"{HF}/Wan2.2-I2V-A14B-HighNoise-Q8_0.gguf"),
        ModelOption("High FP8    (Safetensors, >24GB VRAM)", "wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors", "diffusion_model", "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors?download=true"),
        ModelOption("High FP16   (Safetensors, >32GB VRAM)", "wan2.2_i2v_high_noise_14B_fp16.safetensors",       "diffusion_model", "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_i2v_high_noise_14B_fp16.safetensors?download=true"),
    ]),

    # ── 19 WAN2.2-T2V-L ───────────────────────────────────────────────────────
    ModelFamily(19, "WAN2.2-T2V-L", "WAN22", [
        ModelOption("Low Q4_K_S  (GGUF, <12GB VRAM)",        "Wan2.2-T2V-A14B-LowNoise-Q4_K_S.gguf",            "gguf", f"{HF}/Wan2.2-T2V-A14B-LowNoise-Q4_K_S.gguf"),
        ModelOption("Low Q5_K_S  (GGUF, 12-16GB VRAM)",      "Wan2.2-T2V-A14B-LowNoise-Q5_K_S.gguf",            "gguf", f"{HF}/Wan2.2-T2V-A14B-LowNoise-Q5_K_S.gguf"),
        ModelOption("Low Q6_K    (GGUF, ~16GB VRAM)",        "Wan2.2-T2V-A14B-LowNoise-Q6_K.gguf",              "gguf", "https://huggingface.co/QuantStack/Wan2.2-T2V-A14B-GGUF/resolve/main/LowNoise/Wan2.2-T2V-A14B-LowNoise-Q6_K.gguf?download=true"),
        ModelOption("Low Q8_0    (GGUF, >16GB VRAM)",        "Wan2.2-T2V-A14B-LowNoise-Q8_0.gguf",              "gguf", f"{HF}/Wan2.2-T2V-A14B-LowNoise-Q8_0.gguf"),
        ModelOption("Low FP8     (Safetensors, >24GB VRAM)", "wan2.2_t2v_low_noise_14B_fp8_scaled.safetensors", "diffusion_model", "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_t2v_low_noise_14B_fp8_scaled.safetensors?download=true"),
        ModelOption("Low FP16    (Safetensors, >32GB VRAM)", "wan2.2_t2v_low_noise_14B_fp16.safetensors",       "diffusion_model", "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_t2v_low_noise_14B_fp16.safetensors?download=true"),
    ]),

    # ── 20 WAN2.2-T2V-H ───────────────────────────────────────────────────────
    ModelFamily(20, "WAN2.2-T2V-H", "WAN22", [
        ModelOption("High Q4_K_S (GGUF, <12GB VRAM)",        "Wan2.2-T2V-A14B-HighNoise-Q4_K_S.gguf",            "gguf", f"{HF}/Wan2.2-T2V-A14B-HighNoise-Q4_K_S.gguf"),
        ModelOption("High Q5_K_S (GGUF, 12-16GB VRAM)",      "Wan2.2-T2V-A14B-HighNoise-Q5_K_S.gguf",            "gguf", f"{HF}/Wan2.2-T2V-A14B-HighNoise-Q5_K_S.gguf"),
        ModelOption("High Q6_K   (GGUF, ~16GB VRAM)",        "Wan2.2-T2V-A14B-HighNoise-Q6_K.gguf",              "gguf", "https://huggingface.co/QuantStack/Wan2.2-T2V-A14B-GGUF/resolve/main/HighNoise/Wan2.2-T2V-A14B-HighNoise-Q6_K.gguf?download=true"),
        ModelOption("High Q8_0   (GGUF, >16GB VRAM)",        "Wan2.2-T2V-A14B-HighNoise-Q8_0.gguf",              "gguf", f"{HF}/Wan2.2-T2V-A14B-HighNoise-Q8_0.gguf"),
        ModelOption("High FP8    (Safetensors, >24GB VRAM)", "wan2.2_t2v_high_noise_14B_fp8_scaled.safetensors", "diffusion_model", "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_t2v_high_noise_14B_fp8_scaled.safetensors?download=true"),
        ModelOption("High FP16   (Safetensors, >32GB VRAM)", "wan2.2_t2v_high_noise_14B_fp16.safetensors",       "diffusion_model", "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_t2v_high_noise_14B_fp16.safetensors?download=true"),
    ]),

    # ── 21 WAN2.2-TI2V ────────────────────────────────────────────────────────
    ModelFamily(21, "WAN2.2-TI2V", "WAN22", [
        ModelOption("Q4_K_S  (GGUF, <12GB VRAM)",        "Wan2.2-TI2V-5B-Q4_K_S.gguf",      "gguf", f"{HF}/Wan2.2-TI2V-5B-Q4_K_S.gguf"),
        ModelOption("Q5_K_S  (GGUF, 12-16GB VRAM)",      "Wan2.2-TI2V-5B-Q5_K_S.gguf",      "gguf", f"{HF}/Wan2.2-TI2V-5B-Q5_K_S.gguf"),
        ModelOption("Q6_K    (GGUF, ~16GB VRAM)",        "Wan2.2-TI2V-5B-Q6_K.gguf",        "gguf", "https://huggingface.co/QuantStack/Wan2.2-TI2V-5B-GGUF/resolve/main/Wan2.2-TI2V-5B-Q6_K.gguf?download=true"),
        ModelOption("Q8_0    (GGUF, >16GB VRAM)",        "Wan2.2-TI2V-5B-Q8_0.gguf",        "gguf", f"{HF}/Wan2.2-TI2V-5B-Q8_0.gguf"),
        ModelOption("FP16    (Safetensors, >32GB VRAM)", "wan2.2_ti2v_5B_fp16.safetensors",  "diffusion_model", "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_ti2v_5B_fp16.safetensors?download=true"),
    ]),
]

# T5 encoder companion for gguf_flux models (downloaded alongside the main GGUF)
# key = quality index (0-based), value = (filename, url)
T5_ENCODERS: dict[int, tuple[str, str]] = {
    0: ("t5-v1_1-xxl-encoder-Q4_K_S.gguf", f"{HF}/t5-v1_1-xxl-encoder-Q4_K_S.gguf"),
    1: ("t5-v1_1-xxl-encoder-Q5_K_S.gguf", f"{HF}/t5-v1_1-xxl-encoder-Q5_K_S.gguf"),
    2: ("t5-v1_1-xxl-encoder-Q6_K.gguf",   f"{HF}/t5-v1_1-xxl-encoder-Q6_K.gguf"),
    3: ("t5-v1_1-xxl-encoder-Q8_0.gguf",   f"{HF}/t5-v1_1-xxl-encoder-Q8_0.gguf"),
    4: ("t5xxl_fp8_e4m3fn.safetensors",     f"{HF}/t5xxl_fp8_e4m3fn.safetensors"),
    5: ("t5xxl_fp16.safetensors",           f"{HF}/t5xxl_fp16.safetensors"),
}
