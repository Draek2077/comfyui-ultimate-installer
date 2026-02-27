"""
Verification helpers that check whether each installation step is complete.
Returns a simple InstallStatus dataclass consumed by the UI status panel.
"""

from __future__ import annotations

import subprocess
import winreg
from dataclasses import dataclass, field
from pathlib import Path


@dataclass
class InstallStatus:
    comfyui: bool = False
    nodes: bool = False
    models: bool = False   # True when ALL selected model files are present
    triton: bool = False   # includes sageattention + libs/include dirs
    libs: bool = False

    @property
    def all_done(self) -> bool:
        return self.comfyui and self.nodes and self.models and self.triton and self.libs


def verify_comfyui(install_dir: Path) -> bool:
    """ComfyUI is installed if run_nvidia_gpu.bat exists."""
    return (install_dir / "run_nvidia_gpu.bat").exists()


def verify_nodes(install_dir: Path) -> bool:
    """Nodes are considered installed if ComfyUI-Manager directory exists."""
    manager_dir = install_dir / "ComfyUI" / "custom_nodes" / "ComfyUI-Manager"
    return manager_dir.exists()


def verify_models(install_dir: Path, selected_files: list[tuple[str, str]]) -> bool:
    """
    Check that every selected model file exists at its destination.

    Args:
        install_dir:     Root of ComfyUI_windows_portable.
        selected_files:  List of (subdir, filename) pairs for selected models.
    """
    models_root = install_dir / "ComfyUI" / "models"
    for subdir, filename in selected_files:
        if not (models_root / subdir / filename).exists():
            return False
    return True


def verify_triton(python_exe: Path, install_dir: Path) -> bool:
    """
    Triton is ready when:
      - triton-windows package is installed
      - sageattention package is installed
      - python_embeded/libs and python_embeded/include directories exist
    """
    embeded = install_dir / "python_embeded"
    if not (embeded / "libs").exists():
        return False
    if not (embeded / "include").exists():
        return False

    try:
        result = subprocess.run(
            [str(python_exe), "-m", "pip", "show", "triton-windows"],
            capture_output=True, text=True, check=False,
        )
        if result.returncode != 0:
            return False
        result = subprocess.run(
            [str(python_exe), "-m", "pip", "show", "sageattention"],
            capture_output=True, text=True, check=False,
        )
        return result.returncode == 0
    except FileNotFoundError:
        return False


def verify_libs(install_dir: Path) -> bool:
    """Python include/libs dirs exist."""
    embeded = install_dir / "python_embeded"
    return (embeded / "libs").exists() and (embeded / "include").exists()


def vcredist_installed() -> bool:
    """Check if Visual C++ 2015+ x64 redistributable is installed."""
    try:
        winreg.OpenKey(
            winreg.HKEY_LOCAL_MACHINE,
            r"SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64",
        )
        return True
    except FileNotFoundError:
        return False


def git_installed() -> bool:
    try:
        subprocess.run(["git", "--version"], capture_output=True, check=True)
        return True
    except (FileNotFoundError, subprocess.CalledProcessError):
        return False


def seven_zip_path() -> Path | None:
    """
    Find 7-Zip executable. Discovery order matches the batch file:
    1. Registry
    2. %ProgramW6432%\7-Zip\7z.exe
    3. %ProgramFiles(x86)%\7-Zip\7z.exe
    4. PATH
    """
    import os
    import shutil

    # Registry
    try:
        key = winreg.OpenKey(
            winreg.HKEY_LOCAL_MACHINE,
            r"SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\7zFM.exe",
        )
        fm_path = winreg.QueryValue(key, None)
        candidate = Path(fm_path).parent / "7z.exe"
        if candidate.exists():
            return candidate
    except FileNotFoundError:
        pass

    # Standard paths
    for env_var in ("ProgramW6432", "ProgramFiles", "ProgramFiles(x86)"):
        base = os.environ.get(env_var)
        if base:
            candidate = Path(base) / "7-Zip" / "7z.exe"
            if candidate.exists():
                return candidate

    # PATH
    found = shutil.which("7z")
    if found:
        return Path(found)

    return None


def run_silent_verify(install_dir: Path, python_exe: Path, selected_files: list[tuple[str, str]]) -> InstallStatus:
    """Run all checks and return a fresh InstallStatus."""
    return InstallStatus(
        comfyui=verify_comfyui(install_dir),
        nodes=verify_nodes(install_dir),
        models=verify_models(install_dir, selected_files),
        triton=verify_triton(python_exe, install_dir),
        libs=verify_libs(install_dir),
    )
