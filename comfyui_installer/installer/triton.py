"""
Install Triton Windows and SageAttention, then patch run scripts.
"""

from __future__ import annotations

from pathlib import Path
from typing import Callable

from comfyui_installer.config.settings import SAGEATTENTION_WHL_URL
from comfyui_installer.installer.run_script_patcher import patch_run_scripts
from comfyui_installer.utils.downloader import run_logged

Log = Callable[[str], None]


def _pip(python_exe: Path, args: list[str], log: Log) -> bool:
    cmd = [str(python_exe), "-m", "pip"] + args + ["--no-color"]
    log(f"pip {' '.join(args[:3])}...")
    return run_logged(cmd, log=log) == 0


def install_triton_sage(install_dir: Path, python_exe: Path, log: Log) -> bool:
    """
    Install triton-windows (--pre) and SageAttention, then patch run scripts.
    VC++ Redistributable must be present (checked in prereqs).
    """
    log("Upgrading pip...")
    _pip(python_exe, ["install", "--upgrade", "pip"], log)

    log("Installing Triton Windows (--pre)...")
    ok = _pip(python_exe, ["install", "-U", "--pre", "triton-windows"], log)
    if not ok:
        log("ERROR: Triton installation failed. Ensure VC++ Redistributable is installed.")
        return False

    log("Installing SageAttention...")
    ok = _pip(python_exe, ["install", "-U", SAGEATTENTION_WHL_URL], log)
    if not ok:
        log("ERROR: SageAttention installation failed.")
        return False

    log("Patching run scripts with --use-sage-attention...")
    patch_run_scripts(install_dir, log)

    log("Triton and SageAttention installed and enabled.")
    return True
