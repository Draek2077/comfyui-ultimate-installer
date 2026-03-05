# -*- mode: python ; coding: utf-8 -*-
# PyInstaller spec — build with:  python build.py
# Output:  dist/ComfyUI_Install_Wizard.exe  (~15-30 MB, self-contained, no Python required)

from pathlib import Path
from PyInstaller.utils.hooks import collect_data_files, collect_submodules

ROOT = Path(SPECPATH).parent   # repo root (one level up from build/)

# ── Data files ────────────────────────────────────────────────────────────────
# collect_data_files picks up Textual's built-in CSS, icons, and templates
datas = collect_data_files("textual")

# ── Hidden imports ────────────────────────────────────────────────────────────
# collect_submodules discovers every subpackage so we never miss a lazy import
hiddenimports = (
    collect_submodules("textual")
    + collect_submodules("rich")
    + collect_submodules("comfyui_installer")
    + [
        "winreg",
        "zipfile",
        "urllib.request",
        "concurrent.futures",
    ]
)

# ── Analysis ──────────────────────────────────────────────────────────────────
a = Analysis(
    [str(ROOT / "main.py")],
    pathex=[str(ROOT)],
    binaries=[],
    datas=datas,
    hiddenimports=hiddenimports,
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[
        "tkinter", "matplotlib", "numpy", "PIL",
        "_pytest", "doctest", "unittest",
    ],
    noarchive=False,
)

pyz = PYZ(a.pure)

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
    console=True,           # Textual needs a console window
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon=None,              # Replace with path to a .ico file if desired
    uac_admin=False,        # Individual tools (winget, git) handle their own UAC
)
