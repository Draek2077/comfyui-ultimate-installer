"""
Build script — produces dist/ComfyUI_Install_Wizard.exe

Run from PyCharm (use the "Build EXE" run configuration) or from a terminal:
    python build.py

Options:
    --clean     Wipe previous build artefacts before building (recommended on first run)
    --no-upx    Disable UPX compression (faster build, slightly larger exe)
"""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).parent
SPEC = ROOT / "build" / "ComfyUI_Install_Wizard.spec"
DIST = ROOT / "dist" / "ComfyUI_Install_Wizard.exe"


def _ensure_pyinstaller() -> None:
    try:
        import PyInstaller  # noqa: F401
    except ImportError:
        print("PyInstaller not found — installing...")
        subprocess.run(
            [sys.executable, "-m", "pip", "install", "pyinstaller>=6.0"],
            check=True,
        )


def main() -> None:
    _ensure_pyinstaller()

    clean   = "--clean"   in sys.argv
    no_upx  = "--no-upx"  in sys.argv

    cmd = [sys.executable, "-m", "PyInstaller", str(SPEC)]
    if clean:
        cmd.append("--clean")
    if no_upx:
        cmd.append("--noupx")

    print(f"\nBuilding: {SPEC.name}")
    print(f"Command:  {' '.join(cmd)}\n")

    result = subprocess.run(cmd, cwd=str(ROOT))

    if result.returncode == 0:
        size_mb = DIST.stat().st_size / 1_048_576 if DIST.exists() else 0
        print(f"\n✓ Build complete!  {DIST}  ({size_mb:.1f} MB)")
    else:
        print("\n✗ Build failed — check the output above for errors.")
        sys.exit(result.returncode)


if __name__ == "__main__":
    main()
