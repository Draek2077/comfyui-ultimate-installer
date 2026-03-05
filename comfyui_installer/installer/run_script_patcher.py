"""
Patch ComfyUI run scripts to add performance flags.

Target files:
  - run_nvidia_gpu.bat
  - run_nvidia_gpu_fast_fp16_accumulation.bat

Appends --use-sage-attention --highvram --dont-launch-browser to the line
that launches ComfyUI\\main.py. Idempotent.
"""

from __future__ import annotations

from pathlib import Path
from typing import Callable

SAGE_FLAG      = "--use-sage-attention"
EXTRA_FLAGS    = f"{SAGE_FLAG} --highvram --dont-launch-browser"
MARKER         = "ComfyUI\\main.py"
TARGET_SCRIPTS = [
    "run_nvidia_gpu.bat",
    "run_nvidia_gpu_fast_fp16_accumulation.bat",
]

Log = Callable[[str], None]


def patch_run_scripts(install_dir: Path, log: Log) -> None:
    for script_name in TARGET_SCRIPTS:
        script = install_dir / script_name
        if not script.exists():
            log(f"SKIP (not found): {script_name}")
            continue

        lines = script.read_text(encoding="utf-8", errors="replace").splitlines(keepends=True)
        changed = False
        new_lines = []

        for line in lines:
            if MARKER in line and SAGE_FLAG not in line:
                line = line.rstrip("\r\n") + f" {EXTRA_FLAGS}\r\n"
                changed = True
            new_lines.append(line)

        if changed:
            script.write_text("".join(new_lines), encoding="utf-8")
            log(f"Patched: {script_name}")
        else:
            log(f"Already patched (skipped): {script_name}")
