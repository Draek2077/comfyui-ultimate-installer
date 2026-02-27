"""
Estimate total download size by issuing HTTP HEAD requests to each URL
and reading Content-Length, skipping files that already exist locally.

Matches the PowerShell size-calculation logic in the batch file.
"""

from __future__ import annotations

import concurrent.futures
from pathlib import Path
from typing import Iterable

import urllib.request
import urllib.error


COMFYUI_EXTRACTED_GB = 8.5  # conservative post-extraction estimate


def head_size_bytes(url: str, timeout: int = 5) -> int | None:
    """
    Issue an HTTP HEAD request and return Content-Length in bytes, or None.
    Uses urllib to avoid a requests dependency at installer runtime.
    """
    try:
        req = urllib.request.Request(url, method="HEAD")
        req.add_header("User-Agent", "Mozilla/5.0")
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            cl = resp.headers.get("Content-Length")
            if cl:
                return int(cl)
    except Exception:
        pass
    return None


def estimate_downloads(
    url_dest_pairs: Iterable[tuple[str, Path]],
    include_comfyui: bool = False,
    max_workers: int = 8,
) -> tuple[float, float]:
    """
    Estimate total missing download size in GB.

    Args:
        url_dest_pairs:  (url, local_path) for each file to potentially download.
        include_comfyui: Add COMFYUI_EXTRACTED_GB if ComfyUI is not yet installed.
        max_workers:     Concurrent HEAD requests.

    Returns:
        (total_gb, comfyui_gb) — comfyui_gb is 0 if already installed.
    """
    pairs = [(url, Path(dest)) for url, dest in url_dest_pairs if not Path(dest).exists()]

    total_bytes = 0

    def fetch(url: str) -> int:
        return head_size_bytes(url) or 0

    with concurrent.futures.ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = {executor.submit(fetch, url): url for url, _ in pairs}
        for future in concurrent.futures.as_completed(futures):
            total_bytes += future.result()

    models_gb = round(total_bytes / (1024 ** 3), 1)
    comfyui_gb = COMFYUI_EXTRACTED_GB if include_comfyui else 0.0

    return round(models_gb + comfyui_gb, 1), comfyui_gb


def free_space_gb(path: Path) -> float | None:
    """
    Return free disk space in GB for the drive containing path.
    Uses shutil which works on Windows without PowerShell.
    """
    import shutil
    try:
        total, used, free = shutil.disk_usage(path)
        return round(free / (1024 ** 3), 1)
    except Exception:
        return None
