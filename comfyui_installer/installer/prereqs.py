"""
Prerequisites installer: winget, Git, 7-Zip, VC++ Redistributables, VS Build Tools.
"""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path
from typing import Callable

from comfyui_installer.config.settings import GIT_VER, SEVEN_VER
from comfyui_installer.utils.downloader import download
from comfyui_installer.utils.verification import git_installed, seven_zip_path


Log = Callable[[str], None]


def ensure_winget(log: Log) -> bool:
    try:
        subprocess.run(["winget", "--version"], capture_output=True, check=True)
        log("winget is available.")
        return True
    except (FileNotFoundError, subprocess.CalledProcessError):
        pass

    log("winget not found, downloading installer...")
    msi_url = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    dest = Path("winget-installer.msixbundle")
    if not download(msi_url, dest, on_progress=log):
        log("ERROR: Could not download winget installer.")
        return False
    subprocess.run(["explorer", str(dest)], check=False)
    log("Winget installer launched. Please complete the installation, then retry.")
    dest.unlink(missing_ok=True)
    return False


def ensure_git(log: Log) -> bool:
    if git_installed():
        log("Git is available.")
        return True

    log("Git not found, downloading installer...")
    url = f"https://github.com/git-for-windows/git/releases/download/v{GIT_VER}/Git-{GIT_VER}-64-bit.exe"
    dest = Path("git-installer.exe")
    if not download(url, dest, on_progress=log):
        log("ERROR: Could not download Git installer.")
        return False

    log("Installing Git silently...")
    subprocess.run([str(dest), "/VERYSILENT", "/NORESTART"],
                   check=False, stdin=subprocess.DEVNULL, capture_output=True)
    dest.unlink(missing_ok=True)

    if git_installed():
        log("Git installed successfully.")
        return True
    log("ERROR: Git installation failed.")
    return False


def ensure_7zip(log: Log) -> bool:
    if seven_zip_path():
        log("7-Zip is available.")
        return True

    log("7-Zip not found, downloading installer...")
    url = f"https://www.7-zip.org/a/7z{SEVEN_VER.replace('.', '')}-x64.exe"
    dest = Path("7zip-installer.exe")
    if not download(url, dest, on_progress=log):
        log("ERROR: Could not download 7-Zip installer.")
        return False

    log("Installing 7-Zip silently...")
    subprocess.run([str(dest), "/S"],
                   check=False, stdin=subprocess.DEVNULL, capture_output=True)
    dest.unlink(missing_ok=True)

    if seven_zip_path():
        log("7-Zip installed successfully.")
        return True
    log("ERROR: 7-Zip installation failed.")
    return False


def ensure_vcredist(log: Log) -> bool:
    log("Installing Visual C++ Redistributables via winget...")
    for pkg in ("Microsoft.VCRedist.2015+.x64", "Microsoft.VCRedist.2015+.x86"):
        result = subprocess.run(
            ["winget", "install", "--id", pkg, "-e", "--silent",
             "--accept-package-agreements", "--accept-source-agreements"],
            check=False, stdin=subprocess.DEVNULL, capture_output=True,
        )
        if result.returncode not in (0, -1978335189):  # 0 = success, -1978335189 = already installed
            log(f"WARNING: winget install {pkg} returned {result.returncode}")
    log("VC++ Redistributables install complete.")
    return True


def ensure_build_tools(log: Log) -> bool:
    log("Downloading Visual Studio Build Tools...")
    url = "https://aka.ms/vs/17/release/vs_BuildTools.exe"
    dest = Path("vs_BuildTools.exe")
    if not download(url, dest, on_progress=log):
        log("ERROR: Could not download VS Build Tools.")
        return False

    log("Launching VS Build Tools installer (non-blocking, user may see UAC prompt)...")
    subprocess.Popen(
        [
            str(dest),
            "--norestart", "--passive", "--downloadThenInstall",
            "--includeRecommended",
            "--add", "Microsoft.VisualStudio.Workload.NativeDesktop",
            "--add", "Microsoft.VisualStudio.Component.VC.Tools.x86.x64",
            "--add", "Microsoft.VisualStudio.Workload.MSBuildTools",
        ],
        stdin=subprocess.DEVNULL,
    )
    # Non-blocking: installer continues in background
    log("VS Build Tools installer launched in background.")
    return True


def install_all_prereqs(log: Log) -> bool:
    ok = True
    ok = ensure_winget(log) and ok
    ok = ensure_git(log) and ok
    ok = ensure_7zip(log) and ok
    ok = ensure_vcredist(log) and ok
    ensure_build_tools(log)  # non-blocking, always proceed
    return ok
