"""
Central configuration: version pins, base URLs, directory names, pinned wheel URLs.
Update this file when upgrading dependencies.
"""

# ── ComfyUI & tools ───────────────────────────────────────────────────────────
COMFY_VER   = "0.3.49"
GIT_VER     = "2.45.0.windows.1"
SEVEN_VER   = "22.01"

# ── Directory names (relative to .exe location) ───────────────────────────────
COMFYUI_DIR      = "ComfyUI_windows_portable"
CUSTOM_NODES_DIR = r"ComfyUI\custom_nodes"
MODELS_DIR       = r"ComfyUI\models"
PYTHON_EMBEDED   = r"python_embeded"
PYTHON_EXE_REL   = r"python_embeded\python.exe"

# ── Base download URLs ────────────────────────────────────────────────────────
HF_BASE_URL   = "https://huggingface.co/Aitrepreneur"
HF_FLX_URL    = f"{HF_BASE_URL}/FLX/resolve/main"

COMFY_RELEASE_URL = (
    f"https://github.com/comfyanonymous/ComfyUI/releases/download/"
    f"v{COMFY_VER}/ComfyUI_windows_portable_nvidia.7z"
)

SERVER_MANAGER_URL      = "https://github.com/Draek2077/comfyui-server-manager/releases/download/v1.0.1/ComfyUIServerManagerInstaller.msi"
SERVER_MANAGER_MSI_NAME = "ComfyUIServerManagerInstaller.msi"
CLIENT_WRAPPER_URL      = "https://github.com/Draek2077/comfyui-client-wrapper/releases/download/v1.0.1/ComfyUIClientWrapperInstaller.msi"
CLIENT_WRAPPER_MSI_NAME = "ComfyUIClientWrapperInstaller.msi"

# ── Pinned Python wheels (update when new versions are released) ──────────────
# insightface wheel: filename is built at runtime from Python version
INSIGHTFACE_BASE_URL = "https://huggingface.co/hanamizuki-ai/insightface-releases/resolve/main"
INSIGHTFACE_VER      = "0.7.3"

# nunchaku — v1.0.0dev20250823, torch2.8, cp312, cu128
NUNCHAKU_WHL_URL = (
    "https://github.com/nunchaku-tech/nunchaku/releases/download/"
    "v1.0.0dev20250823/nunchaku-1.0.0.dev20250823+torch2.8-cp312-cp312-win_amd64.whl"
)

# llama-cpp-python — v0.3.16, cp312
LLAMA_CPP_WHL_URL = (
    "https://github.com/eswarthammana/llama-cpp-wheels/releases/download/"
    "v0.3.16/llama_cpp_python-0.3.16-cp312-cp312-win_amd64.whl"
)

# SageAttention — v2.2.0-windows.post2, cu128/torch2.8.0.post2 (cp39 abi3 = any cp3.9+)
SAGEATTENTION_WHL_URL = (
    "https://github.com/woct0rdho/SageAttention/releases/download/"
    "v2.2.0-windows.post2/sageattention-2.2.0+cu128torch2.8.0.post2-cp39-abi3-win_amd64.whl"
)

# Python include/libs zip — needed for Triton/insightface compilation
PYTHON_LIBS_ZIP_URL = (
    "https://github.com/woct0rdho/triton-windows/releases/download/"
    "v3.0.0-windows.post1/python_3.12.7_include_libs.zip"
)

# PyTorch index
TORCH_INDEX_URL = "https://download.pytorch.org/whl/cu128"

# ── Shortcut assets (icons) ───────────────────────────────────────────────────
COMFY_LOGO_URL   = f"{HF_FLX_URL}/Comfy_Logo.ico"
COMFY_CLIENT_URL = f"{HF_FLX_URL}/Comfy_Client.ico"
