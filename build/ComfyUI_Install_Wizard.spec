# PyInstaller spec file
# Build with:  pyinstaller build/ComfyUI_Install_Wizard.spec
# Output:      dist/ComfyUI_Install_Wizard.exe  (~15-25 MB, no dependencies)

import os
from pathlib import Path

# Root of the project (one level up from build/)
ROOT = Path(SPECPATH).parent

block_cipher = None

a = Analysis(
    [str(ROOT / "comfyui_installer" / "main.py")],
    pathex=[str(ROOT)],
    binaries=[],
    datas=[
        # Include Textual's CSS/assets (required for rendering)
        (str(Path(os.environ.get("TEXTUAL", "")) or __import__("textual").__path__[0]),
         "textual"),
    ],
    hiddenimports=[
        "textual",
        "textual.app",
        "textual.screen",
        "textual.widgets",
        "textual.binding",
        "textual.reactive",
        "textual.worker",
        "rich",
        "rich.text",
        "rich.panel",
        "comfyui_installer.config.models",
        "comfyui_installer.config.extras",
        "comfyui_installer.config.nodes",
        "comfyui_installer.config.settings",
        "comfyui_installer.installer.comfyui",
        "comfyui_installer.installer.models",
        "comfyui_installer.installer.nodes",
        "comfyui_installer.installer.python_libs",
        "comfyui_installer.installer.triton",
        "comfyui_installer.installer.prereqs",
        "comfyui_installer.installer.configure",
        "comfyui_installer.installer.run_script_patcher",
        "comfyui_installer.utils.downloader",
        "comfyui_installer.utils.verification",
        "comfyui_installer.utils.size_estimator",
        "comfyui_installer.ui.screens.main_menu",
        "comfyui_installer.ui.screens.model_selection",
        "comfyui_installer.ui.screens.install_progress",
        "comfyui_installer.ui.screens.verification",
        "winreg",
        "zipfile",
        "shutil",
        "subprocess",
        "urllib.request",
        "concurrent.futures",
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=["tkinter", "matplotlib", "numpy", "PIL"],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name="ComfyUI_Install_Wizard",
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=True,       # Keep console visible — this is a terminal app
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon=None,          # Set to path of .ico file to add an icon
)
