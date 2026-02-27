"""
Download, extract, and configure the ComfyUI portable installation.
"""

from __future__ import annotations

import subprocess
from pathlib import Path
from typing import Callable

from comfyui_installer.config.settings import COMFY_RELEASE_URL, COMFYUI_DIR
from comfyui_installer.utils.downloader import download
from comfyui_installer.utils.verification import seven_zip_path
from comfyui_installer.installer.configure import write_settings, create_shortcuts
from comfyui_installer.installer.run_script_patcher import patch_run_scripts

Log = Callable[[str], None]

ARCHIVE_NAME = "ComfyUI_windows_portable_nvidia.7z"


def install_comfyui(
    base_dir: Path,
    log: Log,
    install_server_manager: bool = False,
    install_client_wrapper: bool = False,
) -> bool:
    """
    Full ComfyUI install sequence:
      1. Download portable archive
      2. Extract with 7-Zip
      3. Run auto-updater
      4. Write settings files
      5. Create shortcuts (unless MSI tools are being installed)
      6. Optionally install Server Manager / Client Wrapper

    Args:
        base_dir:              Directory next to the .exe (where ComfyUI_windows_portable goes).
        log:                   Progress callback.
        install_server_manager: Install the Server Manager MSI.
        install_client_wrapper: Install the Client Wrapper MSI.

    Returns:
        True on success.
    """
    install_dir = base_dir / COMFYUI_DIR
    archive     = base_dir / ARCHIVE_NAME

    # ── 1. Download ────────────────────────────────────────────────────────────
    if not (install_dir / "run_nvidia_gpu.bat").exists():
        log("Downloading ComfyUI portable archive (~6.5 GB)...")
        if not download(COMFY_RELEASE_URL, archive, on_progress=log):
            log("ERROR: ComfyUI download failed.")
            return False

        # ── 2. Extract ─────────────────────────────────────────────────────────
        seven = seven_zip_path()
        if not seven:
            log("ERROR: 7-Zip not found. Please install prerequisites first.")
            return False

        log("Extracting ComfyUI archive (this takes a few minutes)...")
        result = subprocess.run(
            [str(seven), "x", str(archive), f"-o{base_dir}", "-aoa", "-bsp1"],
            check=False,
        )
        if result.returncode != 0:
            log("ERROR: Extraction failed.")
            return False

        archive.unlink(missing_ok=True)
        log("ComfyUI extracted successfully.")
    else:
        log("ComfyUI already installed, skipping download/extract.")

    # ── 3. Run updater ────────────────────────────────────────────────────────
    updater = install_dir / "update" / "update_comfyui.bat"
    if updater.exists():
        log("Running ComfyUI auto-updater...")
        subprocess.run([str(updater)], check=False, cwd=str(install_dir / "update"))

    # ── 4. Write settings ─────────────────────────────────────────────────────
    log("Writing ComfyUI settings files...")
    write_settings(install_dir, log)

    # ── 5. Shortcuts ──────────────────────────────────────────────────────────
    if not install_server_manager and not install_client_wrapper:
        log("Creating desktop and start menu shortcuts...")
        create_shortcuts(install_dir, log)

    # ── 6. Optional MSI tools ─────────────────────────────────────────────────
    if install_server_manager:
        from comfyui_installer.installer.configure import install_server_manager as _sm
        _sm(install_dir, log)

    if install_client_wrapper:
        from comfyui_installer.installer.configure import install_client_wrapper as _cw
        _cw(install_dir, log)

    log("ComfyUI installation complete.")
    return True
