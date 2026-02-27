"""
Install all 48 custom node repositories.
"""

from __future__ import annotations

import subprocess
from pathlib import Path
from typing import Callable

from comfyui_installer.config.nodes import NODE_URLS
from comfyui_installer.utils.downloader import clone_repo

Log = Callable[[str], None]


def install_nodes(install_dir: Path, python_exe: Path, log: Log) -> bool:
    custom_nodes = install_dir / "ComfyUI" / "custom_nodes"
    if not custom_nodes.exists():
        log("ERROR: custom_nodes directory not found. Is ComfyUI installed?")
        return False

    total = len(NODE_URLS)
    for i, url in enumerate(NODE_URLS, 1):
        repo_name = url.rstrip("/").rstrip(".git").split("/")[-1]
        dest = custom_nodes / repo_name
        log(f"[{i}/{total}] {repo_name}")
        clone_repo(url, dest, on_progress=log)

    # Apply numpy version constraint AFTER all nodes are installed
    log("Applying numpy<2 constraint...")
    subprocess.run(
        [str(python_exe), "-m", "pip", "install", "numpy<2"],
        check=False,
    )

    log("Custom node installation complete.")
    return True
