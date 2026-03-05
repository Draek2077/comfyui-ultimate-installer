"""
Install core Python packages into ComfyUI's embedded Python environment.
"""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path
from typing import Callable

from comfyui_installer.config.settings import (
    INSIGHTFACE_BASE_URL,
    INSIGHTFACE_VER,
    NUNCHAKU_WHL_URL,
    LLAMA_CPP_WHL_URL,
    TORCH_INDEX_URL,
    PYTHON_LIBS_ZIP_URL,
)
from comfyui_installer.utils.downloader import download, run_logged

Log = Callable[[str], None]


def _detect_python_version(python_exe: Path) -> str:
    """Return compact version string e.g. '312' for Python 3.12."""
    result = subprocess.run(
        [str(python_exe), "-c", "import sys; print(f'{sys.version_info.major}{sys.version_info.minor}')"],
        capture_output=True, text=True, check=False,
    )
    return result.stdout.strip() or "312"


def _pip(python_exe: Path, args: list[str], log: Log) -> bool:
    cmd = [str(python_exe), "-m", "pip"] + args + ["--no-color"]
    log(f"pip {' '.join(args[:3])}...")
    return run_logged(cmd, log=log) == 0


def install_core_packages(python_exe: Path, work_dir: Path, log: Log) -> bool:
    """
    Install all core Python packages into the embedded Python environment.

    Args:
        python_exe: Path to python_embeded/python.exe
        work_dir:   Directory to download wheel files to (cleaned up afterward)
        log:        Progress callback
    """
    py_ver = _detect_python_version(python_exe)
    log(f"Detected embedded Python version: {py_ver}")

    whl_filename = f"insightface-{INSIGHTFACE_VER}-cp{py_ver}-cp{py_ver}-win_amd64.whl"
    whl_url      = f"{INSIGHTFACE_BASE_URL}/{whl_filename}"
    whl_dest     = work_dir / whl_filename

    log(f"Downloading insightface wheel: {whl_filename}")
    if not download(whl_url, whl_dest, on_progress=log):
        log("WARNING: insightface wheel download failed, continuing without it.")
        whl_dest = None

    # pip upgrade
    _pip(python_exe, ["install", "--upgrade", "pip"], log)

    # cython
    _pip(python_exe, ["install", "cython"], log)

    # facexlib
    _pip(python_exe, ["install", "--use-pep517", "facexlib"], log)

    # filterpy (from GitHub fork)
    _pip(python_exe, ["install", "git+https://github.com/rodjjo/filterpy.git"], log)

    # onnxruntime
    _pip(python_exe, ["install", "onnxruntime", "onnxruntime-gpu"], log)

    # insightface wheel
    if whl_dest and whl_dest.exists():
        _pip(python_exe, ["install", str(whl_dest)], log)
        whl_dest.unlink(missing_ok=True)

    # opencv — remove and reinstall fresh
    _pip(python_exe, ["uninstall", "-y", "opencv-python", "opencv-python-headless"], log)
    _pip(python_exe, ["install", "opencv-python", "opencv-python-headless"], log)

    # torch stack (CUDA 12.8)
    _pip(python_exe, [
        "install", "xformers", "torch", "torchvision", "torchaudio",
        "--extra-index-url", TORCH_INDEX_URL,
    ], log)

    # nunchaku (pinned wheel)
    _pip(python_exe, ["install", NUNCHAKU_WHL_URL], log)

    # llama-cpp-python (pinned wheel)
    _pip(python_exe, ["install", LLAMA_CPP_WHL_URL], log)

    log("Core Python packages installed.")
    return True


def setup_python_libs(install_dir: Path, log: Log) -> bool:
    """
    Download and extract Python include/libs into python_embeded.
    Required for Triton and insightface compilation.
    """
    embeded = install_dir / "python_embeded"
    if (embeded / "libs").exists() and (embeded / "include").exists():
        log("Python libs/include already installed, skipping.")
        return True

    zip_dest = install_dir / "python_libs_include.zip"
    log("Downloading Python include/libs zip...")
    if not download(PYTHON_LIBS_ZIP_URL, zip_dest, on_progress=log):
        log("ERROR: Could not download Python libs zip.")
        return False

    log("Extracting Python include/libs...")
    import zipfile
    with zipfile.ZipFile(zip_dest, "r") as zf:
        zf.extractall(embeded)
    zip_dest.unlink(missing_ok=True)

    if (embeded / "libs").exists() and (embeded / "include").exists():
        log("Python include/libs installed successfully.")
        return True

    log("ERROR: Extraction succeeded but libs/include dirs not found.")
    return False
