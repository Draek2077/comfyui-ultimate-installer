# CLAUDE.md — ComfyUI Ultimate Installer

## Project Overview

Windows 11 installer for ComfyUI (AI image generation, node-based UI for Stable Diffusion).
Targets NVIDIA GPU users. Distributed as a single executable (no prerequisites on target machine).

Installs: ComfyUI portable, 48 custom nodes, 21 model families (81+ models), Python packages
(torch/xformers/triton/sageattention/insightface), Windows shortcuts, and optionally
a Server Manager and Client Wrapper application.

Target audience: Non-technical Windows 11 + NVIDIA users.
Author's custom nodes/workflows: https://github.com/Draek2077/comfyui-draekz-nodez

## Technology Stack (Rewrite Target)

```
Language:  Python 3.12
TUI:       Textual (https://textual.textualize.io/) — arrow key menus, progress bars, panels
Build:     PyInstaller — single .exe, no Python required on target machine
IDE:       PyCharm (JetBrains)
```

Previous implementation: Windows batch file (`ComfyUI_Install_Wizard.bat`, 1799 lines, Gemini-generated)

### Why Textual

| Concern | Rationale |
|---|---|
| JetBrains IDE | PyCharm has first-class Python support — autocomplete, debugger, type hints |
| Keyboard navigation | Textual has built-in `ListView`, focus management, keyboard bindings — no manual cursor code |
| Windows distribution | PyInstaller produces a single `.exe` (~15–25 MB), no Python required on target |
| Modern TUI look | Full color, borders, panels, progress bars, CSS-like styling |
| Maintainability | 81 models and 48 nodes become typed Python dataclasses — adding a model is one dict append |

Rich is a dependency of Textual (included free). Node.js + Ink is not recommended — raw-mode
console issues on Windows `cmd.exe` are a known problem in the exact context this installer
targets (double-clicked .exe from a non-developer machine).

### Distribution

```bash
pip install textual pyinstaller
pyinstaller --onefile --name ComfyUI_Install_Wizard main.py
# → dist/ComfyUI_Install_Wizard.exe  (no dependencies required)
```

## Repository Structure (Rewrite Target)

```
comfyui_installer/
    main.py                          # Textual App entry point
    config/
        models.py                    # 21 ModelFamily dataclasses
        nodes.py                     # 48 custom node repo URLs
        extras.py                    # 81 shared/extra model entries
        settings.py                  # Version pins, base URLs, path constants
    ui/
        screens/
            main_menu.py             # MainMenuScreen
            model_selection.py       # Toggle model families + quality tier
            install_progress.py      # Live log + per-file progress
            verification.py          # Post-install verification report
        widgets/
            status_panel.py          # [✓]/[ ] status indicators
            model_list.py            # Scrollable toggle list
            progress_log.py          # Scrollable install log
    installer/
        comfyui.py                   # Download + extract ComfyUI portable
        models.py                    # Model download logic
        nodes.py                     # Git clone + pip install nodes
        python_libs.py               # pip installs for core packages
        triton.py                    # Triton + SageAttention
        prereqs.py                   # winget, git, 7zip, vcredist, build tools
        shortcuts.py                 # Desktop + Start Menu shortcuts
        run_script_patcher.py        # Modify ComfyUI .bat run scripts
        configure.py                 # Write comfy.settings.json + manager config
    utils/
        downloader.py                # curl wrapper with resume + 3-retry
        verification.py              # File/dir/registry/pip checks
        size_estimator.py            # HTTP HEAD requests for download sizing
    build/
        ComfyUI_Install_Wizard.spec  # PyInstaller spec
```

## ComfyUI Installation

```
Install directory:  ComfyUI_windows_portable\  (relative to .exe location)
Base version:       0.3.49 (COMFY_VER in settings.py), then auto-updates
Archive:            ComfyUI_windows_portable_nvidia.7z (~6.5 GB download, ~8.5 GB extracted)
Source URL:         https://github.com/comfyanonymous/ComfyUI/releases/download/v{COMFY_VER}/

Skip condition:     If ComfyUI_windows_portable\run_nvidia_gpu.bat exists → skip download/extract
                    Still run nodes/models/triton on re-runs (idempotent)

Python executable:  {INSTALL_DIR}\python_embeded\python.exe  (Python 3.12 embedded)
```

Directory structure after install:

```
ComfyUI_windows_portable\
    run_nvidia_gpu.bat
    run_nvidia_gpu_fast_fp16_accumulation.bat
    ComfyUI\
        main.py
        custom_nodes\
        models\
            checkpoints\
            diffusion_models\
            unet\                  ← GGUF models
            loras\
            vae\
            controlnet\
            text_encoders\
            clip_vision\
            clip\
            upscale_models\
            sams\
            ultralytics\bbox\
            ultralytics\segm\
            pulid\
            xlabs\ipadapters\
            xlabs\controlnets\
            vae_approx\
            style_models\
            llm_gguf\
            insightface\           ← git cloned
            llm\Florence-2-base\   ← git cloned
            llm\Florence-2-large\  ← git cloned
        user\default\
            comfy.settings.json
            ComfyUI-Manager\config.ini
    python_embeded\
        python.exe
        libs\                      ← installed by setup_python_libs
        include\                   ← installed by setup_python_libs
    update\
        update_comfyui.bat
```

## Model Data Structure (config/models.py)

```python
from dataclasses import dataclass

@dataclass
class ModelOption:
    name: str         # Display name: "Q4_K_S (GGUF, <12GB VRAM)"
    filename: str     # "flux1-dev-Q4_K_S.gguf"
    model_type: str   # See type→directory mapping below
    url: str          # Direct download URL

@dataclass
class ModelFamily:
    id: int                    # 01–21
    name: str                  # "FLUX-Dev"
    family_flag: str           # "FLUX"|"SD15"|"SDXL"|"SD3"|"QWEN"|"HIDREAM"|"WAN21"|"WAN22"
    options: list[ModelOption] # Quality tiers, index 0=Q4 … 5=Full/BF16
```

Quality tier mapping (by list index):

```
0 → Q4 GGUF     (~Q4_K_S, <12 GB VRAM)
1 → Q5 GGUF     (~Q5_K_S, 12–16 GB VRAM)
2 → Q6 GGUF     (~Q6_K,   ~16 GB VRAM)
3 → Q8 GGUF     (~Q8_0,   >16 GB VRAM)
4 → FP8         (SafeTensors, >24 GB VRAM)
5 → Full/BF16   (SafeTensors, >32 GB VRAM)
```

Not all families have all 6 tiers. Quality fallback: install highest tier ≤ user's selection.

Model type → destination directory:

```
"gguf"            → models\unet\
"gguf_flux"       → models\unet\  + also downloads matching T5 encoder
"checkpoint"      → models\checkpoints\
"checkpoints"     → models\checkpoints\
"diffusion_model" → models\diffusion_models\
"lora"            → models\loras\
```

## Model Families (21 total)

```
01  FLUX-Dev              FLUX    6 tiers
02  FLUX-Fill-Dev         FLUX    5 tiers
03  FLUX-Schnell          FLUX    6 tiers
04  FLUX-Kontext          FLUX    5 tiers
05  Qwen-Image            QWEN    6 tiers
06  Qwen-Edit             QWEN    6 tiers
07  HiDream               HIDREAM 6 tiers
08  SD1.5                 SD15    1 tier (checkpoint only)
09  SDXL                  SDXL    1 tier (base checkpoint)
10  SD3.5                 SD3     4 tiers
11  WAN2.1-T2V            WAN21   6 tiers
12  WAN2.1-I2V-480        WAN21   6 tiers
13  WAN2.1-I2V-720        WAN21   6 tiers
14  WAN2.1-T2V-FusionX    WAN21   4 tiers
15  WAN2.1-FusionX-Vace   WAN21   4 tiers
16  WAN2.1-Vace           WAN21   6 tiers
17  WAN2.2-I2V-L          WAN22   6 tiers
18  WAN2.2-I2V-H          WAN22   6 tiers
19  WAN2.2-T2V-L          WAN22   6 tiers
20  WAN2.2-T2V-H          WAN22   6 tiers
21  WAN2.2-TI2V           WAN22   5 tiers
```

## Shared/Extra Models (config/extras.py, 81 total)

```python
@dataclass
class ExtraModel:
    flag: str     # "FLUX"|"QWEN"|"HIDREAM"|"SD15"|"SDXL"|"SD3"|"WAN21"|"WAN22"|"ALWAYS"
    subdir: str   # subdirectory under models\ (e.g. "text_encoders", "vae")
    filename: str
    url: str      # direct download URL
```

Download logic: `flag == "ALWAYS"` → always download. Otherwise: download only when
corresponding model family is selected by the user.

Distribution by flag:

```
FLUX    001–017  (17): encoders, controlnets, redux, pulid, ipadapters, vae_approx
QWEN    018–027  (10): text encoders, vae, loras
HIDREAM 028–029   (2): clip_g, clip_l text encoders
SD15    030–031   (2): taesd vae_approx
SD3     032–039   (8): text encoders, vae, vae_approx, controlnets
SDXL    040–047   (8): vae, refiner, controlnets, vae_approx
WAN21   048–052   (5): vae, loras, ae, clip_vision
WAN22   053–062  (10): vae, loras, text encoders
ALWAYS  063–081  (19): upscalers, SAM, YOLO, LLM, CLIP models, Hermes LLM
```

Repo-based extras (git clone, not file download):

```
models\insightface          ← HF: Aitrepreneur/insightface
models\llm\Florence-2-base  ← HF: Aitrepreneur/Florence-2-base
models\llm\Florence-2-large ← HF: Aitrepreneur/Florence-2-large
```

## Custom Nodes (config/nodes.py, 48 repos)

```
Clone target: ComfyUI_windows_portable\ComfyUI\custom_nodes\
Post-clone:   pip install -r requirements.txt (if file exists), --no-warn-script-location
Skip if dir already exists (idempotent).
Final step:   pip install "numpy<2"  ← must come AFTER all 48 node installs
```

Key repos:

```
ltdrdata/ComfyUI-Manager                   ← node package manager
Gourieff/comfyui-reactor-node (codeberg)   ← face swap  (NOTE: codeberg.org, not GitHub)
ltdrdata/ComfyUI-Impact-Pack
Fannovel16/comfyui_controlnet_aux
city96/ComfyUI-GGUF                        ← GGUF model support
kijai/ComfyUI-WanVideoWrapper
mit-han-lab/ComfyUI-nunchaku
Draek2077/comfyui-draekz-nodez             ← author's custom nodes
Draek2077/comfyui-draekz-workflowz         ← author's workflows
```

## Python Package Installation

All via: `{INSTALL_DIR}\python_embeded\python.exe`

Core packages (installer/python_libs.py):

```
pip upgrade
cython
facexlib                       --use-pep517, git+https://github.com/xinntao/facexlib
filterpy                       from github: rodjjo/filterpy
onnxruntime
onnxruntime-gpu
insightface wheel              version-specific .whl (see pinned URLs below)
opencv-python                  remove + reinstall fresh
opencv-python-headless
xformers
torch, torchvision, torchaudio index: https://download.pytorch.org/whl/cu128
nunchaku                       pinned wheel (see pinned URLs below)
llama-cpp-python               pinned wheel (see pinned URLs below)
```

Triton + SageAttention (installer/triton.py):

```
triton-windows     --pre
sageattention      pinned wheel (see pinned URLs below)
```

Python include/libs (installer/python_libs.py):

```
Source: https://github.com/woct0rdho/triton-windows/releases/
File:   python_3.12.7_include_libs.zip
Target: {INSTALL_DIR}\python_embeded\  (extracts libs\ and include\ subdirs)
```

## Pinned Wheel URLs (update in config/settings.py)

```python
COMFY_VER   = "0.3.49"
GIT_VER     = "2.45.0.windows.1"
SEVEN_VER   = "22.01"

# insightface-0.7.3-cp{PY}-cp{PY}-win_amd64.whl  (detect Python version at runtime)
INSIGHTFACE_BASE_URL = "https://huggingface.co/hanamizuki-ai/insightface-releases/resolve/main/"

# nunchaku: v1.0.0dev20250823, torch2.8, cp312, cu128
# sageattention: v2.2.0-windows.post2, cu128/torch2.8.0.post2
# llama-cpp-python: v0.3.16, cp312
# (see full URLs in ComfyUI_Install_Wizard.bat lines 982-1028)
```

## Prerequisites (installer/prereqs.py)

```
winget        bootstrap: download .msixbundle from GitHub if `winget --version` fails
Git           silent .exe installer if `git --version` fails
7-Zip         silent .exe installer if not found in registry/PATH
VCRedist x64  via winget: Microsoft.VCRedist.2015+.x64
VCRedist x86  via winget: Microsoft.VCRedist.2015+.x86
VS Build Tools vs_BuildTools.exe --passive --downloadThenInstall
              workloads: NativeDesktop, VCTools, MSBuildTools
```

7-Zip discovery order:
1. Registry: `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe`
2. `%ProgramW6432%\7-Zip\7z.exe`
3. `%ProgramFiles(x86)%\7-Zip\7z.exe`
4. PATH lookup

## Downloader Utility (utils/downloader.py)

Pattern from batch `:grab` subroutine (lines 1615–1651 of the .bat):

- `curl -C - -# -L -o {dest} {url} --ssl-no-revoke`
- 3 retry attempts with delay between retries
- Create destination directory if missing
- Skip if file already exists at full size; resume if partial
- Return error on failure after all retries

```python
def download(url: str, dest: Path, retries: int = 3) -> bool:
    """Wraps curl with resume (-C -), progress (-#), and --ssl-no-revoke."""
```

## Installation Sequence (Full Install)

```
1. check_prereqs          → winget, git, 7zip, vcredist, build tools
2. install_comfyui
   a. download 7z archive (~6.5 GB)
   b. extract with 7-Zip (-bsp1 for progress output)
   c. run update\update_comfyui.bat
   d. write comfy.settings.json + ComfyUI-Manager/config.ini
   e. create Desktop + Start Menu shortcuts
   f. install_server_manager (MSI via msiexec /i /qb, if toggled)
   g. install_client_wrapper (MSI via msiexec /i /qb, if toggled)
3. install_core_python_packages
4. install_nodes           → 48 git clones + requirements.txt, then numpy<2
5. install_models          → selected main models + all relevant extras
6. setup_python_libs       → include + libs zip extraction
7. install_triton_sage     → pip installs + patch run scripts
8. verify_all              → check all expected files/packages exist
```

## ComfyUI Configuration Files (installer/configure.py)

### comfy.settings.json

```json
{
  "Comfy.Validation.Workflows": true,
  "Comfy.UseNewMenu": "Top",
  "Comfy.Minimap.Visible": false,
  "Comfy.Workflow.WorkflowTabsPosition": "Sidebar",
  "Comfy.Sidebar.Size": "small",
  "Comfy.SnapToGrid.GridSize": 20,
  "Comfy.Graph.CanvasZoomOptimization": true,
  "Comfy.LinkRenderMode": 0,
  "Comfy.TextareaWidget.FontSize": 12,
  "KJNodes.browserStatus": true,
  "Crystools.MonitorHeight": 28,
  "Crystools.ShowHdd": true,
  "Crystools.WhichHdd": "C:\\",
  "Comfy.DisabledExtension": [
    "pyssss.Locking", "pyssss.SnapToGrid", "pyssss.ImageFeed",
    "pyssss.ShowImageOnMenu", "rgthree.TopMenu"
  ]
}
```

### ComfyUI-Manager/config.ini

```ini
preview_method = taesd
use_uv = False
channel_url = https://raw.githubusercontent.com/ltdrdata/ComfyUI-Manager/main
share_option = all
bypass_ssl = False
update_policy = stable-comfyui
windows_selector_event_loop_policy = False
db_mode = cache
```

## Run Script Patching (installer/run_script_patcher.py)

Files patched:
- `run_nvidia_gpu.bat`
- `run_nvidia_gpu_fast_fp16_accumulation.bat`

Logic:
- Find line containing `ComfyUI\main.py`
- Append: `--use-sage-attention --highvram --dont-launch-browser`
- Idempotent: check for `--use-sage-attention` before appending

## Shortcuts (installer/shortcuts.py)

```
Server shortcut:
    Name:   ComfyUI Server
    Target: cmd.exe /c "{INSTALL_DIR}\run_nvidia_gpu_fast_fp16_accumulation.bat"
    Icon:   ComfyUI\Comfy_Logo.ico       (downloaded from GitHub during configure)
    Style:  WindowStyle = 7 (minimized)

Client shortcut:
    Name:   ComfyUI Client
    Target: msedge.exe --app=http://127.0.0.1:8188/
    Icon:   ComfyUI\Comfy_Client.ico     (downloaded from GitHub during configure)
```

Created at: Desktop and `%APPDATA%\Microsoft\Windows\Start Menu\Programs\`
Method: PowerShell `WScript.Shell` COM object
Suppressed: When Server Manager OR Client Wrapper MSI is installed (they create their own).

## Verification Logic (utils/verification.py)

```
STATUS_COMFYUI:  exists? ComfyUI_windows_portable\run_nvidia_gpu.bat
STATUS_NODES:    exists? custom_nodes\ComfyUI-Manager\
STATUS_MODELS:   all selected model files exist at correct paths
STATUS_TRITON:   pip list contains "triton-windows" AND "sageattention"
                 AND exists python_embeded\libs\ AND python_embeded\include\
```

Silent verification runs at startup and after each major operation to keep status indicators current.

## Size Estimation (utils/size_estimator.py)

- HTTP HEAD request per download URL → read `Content-Length` header
- Only count URLs where the local file does NOT already exist
- ComfyUI base contribution: 8.5 GB if not yet installed
- Available disk space: `Get-Volume -DriveLetter {X} | Select SizeRemaining`
- Display: green if space is sufficient, red if not

## Key External URLs

```
HuggingFace models:   https://huggingface.co/Aitrepreneur/
ComfyUI release:      https://github.com/comfyanonymous/ComfyUI/releases/
Server Manager MSI:   https://github.com/Draek2077/comfyui-server-manager/releases/
Client Wrapper MSI:   https://github.com/Draek2077/comfyui-client-wrapper/releases/
Draekz nodes:         https://github.com/Draek2077/comfyui-draekz-nodez
Draekz workflows:     https://github.com/Draek2077/comfyui-draekz-workflowz
```

## Known Gotchas

1. **numpy<2 constraint**: Must be pinned *after* all 48 node installs. Some nodes
   upgrade numpy to >=2 during their own requirements install.

2. **insightface wheel filename**: Must match exact Python version.
   Pattern: `insightface-0.7.3-cp{VER}-cp{VER}-win_amd64.whl`
   Detect Python minor version at runtime to construct the URL.

3. **gguf_flux model type**: Downloading a `gguf_flux` model also requires downloading
   an associated T5 text encoder (`t5-v1_1-xxl-encoder-{quality}.gguf`).

4. **ComfyUI already-exists check**: If `run_nvidia_gpu.bat` exists, skip download,
   extract, and core Python packages. Always re-run nodes/models/triton (idempotent).

5. **Shortcut suppression**: When Server Manager OR Client Wrapper MSI is installed,
   skip manual shortcut creation — the MSIs create their own shortcuts.

6. **VS Build Tools**: Runs `/passive` in background. User may see a UAC prompt or
   background window. Non-blocking — do not wait for completion.

7. **Model quality fallback**: If a model family has no option at tier N, install the
   highest available option at tier < N. SD1.5 has only 1 option and is always installed
   regardless of quality choice.

8. **curl --ssl-no-revoke**: Required for some HuggingFace download URLs on Windows.
   Must be included on all curl invocations.

9. **codeberg.org node**: `comfyui-reactor-node` is on codeberg.org, not GitHub.
   Clone URL: `https://codeberg.org/Gourieff/comfyui-reactor-node`

## Development Workflow

```bash
# Setup
pip install textual pyinstaller

# Run during development (no build step required)
python main.py

# Build distributable .exe
pyinstaller build/ComfyUI_Install_Wizard.spec
# Output: dist/ComfyUI_Install_Wizard.exe
```

**To add a new model family:**
1. Append a `ModelFamily(...)` to the list in `config/models.py`
2. Add any companion extras to `config/extras.py` with the correct `flag`
3. Update `utils/verification.py` if the family needs a new status flag

**To add a new custom node:**
1. Append the repo URL to `NODE_URLS` in `config/nodes.py`

**To update a pinned wheel version:**
1. Update the URL constant in `config/settings.py`

## Platform Constraints

```
OS:        Windows 11 (primary target), Windows 10 (likely works)
GPU:       NVIDIA only (ComfyUI portable nvidia edition)
CUDA:      12.8 (torch/xformers index, sageattention wheel)
Python:    3.12 (insightface, nunchaku, and llama-cpp-python wheels are cp312-specific)
Launch:    Runs from cmd.exe context (double-click .exe or .bat)
Network:   Requires internet throughout installation
Disk:      80–200+ GB depending on model selections
```
