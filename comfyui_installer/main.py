"""
ComfyUI Ultimate Installer — Textual TUI entry point.

Usage:
    python -m comfyui_installer.main
    or via the built .exe: ComfyUI_Install_Wizard.exe
"""

from __future__ import annotations

import sys
from pathlib import Path

from textual.app import App, ComposeResult
from textual.widgets import Header, Footer

from comfyui_installer.ui.screens.main_menu import MainMenuScreen
from comfyui_installer.utils.verification import run_silent_verify, InstallStatus
from comfyui_installer.utils.size_estimator import estimate_downloads, free_space_gb
from comfyui_installer.config.settings import COMFYUI_DIR


class InstallerApp(App):
    """Root application."""

    CSS = """
    Screen {
        background: #0d1117;
        color: #c9d1d9;
    }
    Header {
        background: #161b22;
        color: #58a6ff;
    }
    Footer {
        background: #161b22;
        color: #8b949e;
    }
    Static {
        padding: 0 1;
    }
    ListView {
        border: solid #30363d;
        background: #0d1117;
        height: 1fr;
    }
    ListItem {
        padding: 0 1;
    }
    ListItem:hover {
        background: #1c2128;
    }
    ListItem.-selected {
        background: #1f6feb;
        color: #ffffff;
    }
    DataTable {
        border: solid #30363d;
        height: 1fr;
    }
    Log {
        border: solid #30363d;
        background: #0d1117;
        height: 1fr;
    }
    ProgressBar {
        margin: 0 1;
    }
    """

    TITLE = "Draekz ComfyUI Ultimate Installer"

    # Application state shared across screens
    selected_models: dict[int, int] = {}   # {family_id: quality_tier_index}
    install_server: bool = True
    install_client: bool = True

    @property
    def base_dir(self) -> Path:
        """Directory where the .exe (or main.py) lives."""
        if getattr(sys, "frozen", False):
            return Path(sys.executable).parent
        return Path(__file__).parent.parent

    @property
    def install_dir(self) -> Path:
        return self.base_dir / COMFYUI_DIR

    @property
    def python_exe(self) -> Path:
        return self.install_dir / "python_embeded" / "python.exe"

    def on_mount(self) -> None:
        # Run startup verification and size estimation in background
        self.run_worker(self._startup_checks, thread=True)

    def _startup_checks(self) -> None:
        """Run silently on startup to populate status indicators."""
        install_dir = self.install_dir
        python_exe  = self.python_exe

        # Verify existing state
        status = run_silent_verify(install_dir, python_exe, selected_files=[])
        self.call_from_thread(self._apply_status, status)

        # Disk space
        free = free_space_gb(self.base_dir)
        self.call_from_thread(self._apply_free_gb, free)

        # Initial size estimate: count ComfyUI if not yet installed
        comfyui_not_installed = not (install_dir / "run_nvidia_gpu.bat").exists()
        if comfyui_not_installed:
            from comfyui_installer.utils.size_estimator import COMFYUI_EXTRACTED_GB
            self.call_from_thread(self._apply_total_gb, COMFYUI_EXTRACTED_GB)

    def estimate_sizes_for_selection(self, selected: dict[int, int]) -> None:
        """Trigger a background worker to re-estimate download size after model selection."""
        self.run_worker(lambda: self._estimate_sizes(selected), thread=True)

    def _estimate_sizes(self, selected: dict[int, int]) -> None:
        """Background: compute total download size and push to main menu."""
        install_dir = self.install_dir
        comfyui_not_installed = not (install_dir / "run_nvidia_gpu.bat").exists()

        from comfyui_installer.installer.models import get_all_download_pairs
        pairs = get_all_download_pairs(install_dir, selected)
        total_gb, _ = estimate_downloads(
            pairs, include_comfyui=comfyui_not_installed
        )
        self.call_from_thread(self._apply_total_gb, total_gb)

    def _apply_status(self, status: InstallStatus) -> None:
        try:
            main = self.query_one(MainMenuScreen)
            main.status = status
        except Exception:
            pass

    def _apply_free_gb(self, free: float | None) -> None:
        try:
            main = self.query_one(MainMenuScreen)
            main.free_gb = free
        except Exception:
            pass

    def _apply_total_gb(self, total: float) -> None:
        try:
            main = self.query_one(MainMenuScreen)
            main.total_gb = total
        except Exception:
            pass

    def compose(self) -> ComposeResult:
        yield MainMenuScreen()


def main() -> None:
    app = InstallerApp()
    app.run()


if __name__ == "__main__":
    main()
