"""
ComfyUI Ultimate Installer — Textual TUI entry point.

Usage:
    python -m comfyui_installer.main
    or via the built .exe: ComfyUI_Install_Wizard.exe
"""

from __future__ import annotations

import sys
from pathlib import Path

from textual.app import App
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

    TITLE = "Draekz ComfyUI Ultimate Installer  v4.0.0"

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
        base = getattr(self, "install_base_dir", self.base_dir)
        return base / COMFYUI_DIR

    @property
    def python_exe(self) -> Path:
        return self.install_dir / "python_embeded" / "python.exe"

    def on_mount(self) -> None:
        self.install_base_dir: Path = self.base_dir
        self.push_screen(MainMenuScreen())
        # Run startup verification and size estimation in background
        self.run_worker(self._startup_checks, thread=True)

    def _startup_checks(self) -> None:
        """Run silently on startup to populate status indicators."""
        from comfyui_installer.installer.models import detect_installed_models

        install_dir = self.install_dir
        python_exe  = self.python_exe

        # Push current install path to UI
        self.call_from_thread(self._apply_install_path, self.install_base_dir)

        # Verify existing state
        self.call_from_thread(self._apply_bg_progress, "Verifying", "starting...")
        def on_verify(step: str) -> None:
            self.call_from_thread(self._apply_bg_progress, "Verifying", step)
        status = run_silent_verify(install_dir, python_exe, selected_files=[], on_progress=on_verify)

        # Detect which model files are actually on disk and override models flag
        self.call_from_thread(self._apply_bg_progress, "Verifying", "Models")
        detected = detect_installed_models(install_dir)
        status.models = len(detected) > 0

        self.call_from_thread(self._apply_status, status)
        self.call_from_thread(self._apply_bg_progress, "", "")

        # Auto-select detected models so the menu reflects what's installed
        if detected:
            self.call_from_thread(self._apply_detected_models, detected)

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

        def on_progress(completed: int, total: int) -> None:
            self.call_from_thread(self._apply_bg_progress, "Estimating", f"{completed}/{total} files")

        self.call_from_thread(self._apply_bg_progress, "Estimating", "0/? files")
        total_gb, _ = estimate_downloads(
            pairs, include_comfyui=comfyui_not_installed, on_progress=on_progress
        )
        self.call_from_thread(self._apply_total_gb, total_gb)
        self.call_from_thread(self._apply_bg_progress, "", "")

    def _main_menu(self) -> MainMenuScreen | None:
        return next((s for s in self.screen_stack if isinstance(s, MainMenuScreen)), None)

    def _apply_status(self, status: InstallStatus) -> None:
        main = self._main_menu()
        if main is not None:
            main.status = status

    def _apply_free_gb(self, free: float | None) -> None:
        main = self._main_menu()
        if main is not None:
            main.free_gb = free

    def _apply_total_gb(self, total: float) -> None:
        main = self._main_menu()
        if main is not None:
            main.total_gb = total

    def _apply_install_path(self, path: Path) -> None:
        menu = self._main_menu()
        if menu is not None:
            menu.install_path = str(path)

    def _apply_bg_progress(self, task: str, detail: str) -> None:
        main = self._main_menu()
        if main is not None:
            main.bg_task = task
            main.bg_detail = detail

    def _apply_detected_models(self, detected: dict[int, int]) -> None:
        """Populate app selection state from models found on disk at startup."""
        from comfyui_installer.config.models import MODEL_FAMILIES
        # Only auto-fill if the user hasn't made a selection yet this session
        if not self.selected_models:
            self.selected_models = detected
        main = self._main_menu()
        if main is not None:
            tier_names = {0: "Q4", 1: "Q5", 2: "Q6", 3: "Q8", 4: "FP8", 5: "Full"}
            names = [f.name for f in MODEL_FAMILIES if f.id in detected]
            main.selected_model_names = ", ".join(names)
            tiers = set(detected.values())
            if len(tiers) == 1:
                main.quality_name = tier_names.get(next(iter(tiers)), "Custom")
            elif tiers:
                main.quality_name = "Mixed"

def main() -> None:
    app = InstallerApp()
    app.run()


if __name__ == "__main__":
    main()
