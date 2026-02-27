"""
Installation progress screen with a live scrolling log.
Runs the installer in a background worker thread so the UI stays responsive.
"""

from __future__ import annotations

from pathlib import Path
from typing import Callable

from textual.app import ComposeResult
from textual.screen import Screen
from textual.widgets import Header, Footer, Log as TextualLog, Static, ProgressBar
from textual.binding import Binding
from textual.worker import Worker, WorkerState

INSTALL_MODES = {
    "all":     "Full Installation",
    "comfyui": "ComfyUI Core",
    "models":  "Download Models",
    "nodes":   "Custom Nodes",
    "triton":  "Triton / Sage Attention",
    "libs":    "Python Libs",
    "prereqs": "Prerequisites",
}


class InstallProgressScreen(Screen):
    """Shows live installation log; runs work in a background thread."""

    BINDINGS = [
        Binding("escape", "go_back", "Back (when done)", show=True),
    ]

    def __init__(self, mode: str = "all") -> None:
        super().__init__()
        self._mode = mode
        self._done = False

    def compose(self) -> ComposeResult:
        title = INSTALL_MODES.get(self._mode, self._mode)
        yield Header()
        yield Static(f"\n [bold]{title}[/]  [dim]Esc to return when complete[/]\n", id="title")
        yield ProgressBar(total=100, show_eta=False, id="progress")
        yield TextualLog(id="log_view", highlight=True, markup=True)
        yield Footer()

    def on_mount(self) -> None:
        self._worker = self.run_worker(self._run_install, thread=True)

    def _log(self, msg: str) -> None:
        """Thread-safe log append."""
        self.call_from_thread(self._append_log, msg)

    def _append_log(self, msg: str) -> None:
        log_widget = self.query_one("#log_view", TextualLog)
        log_widget.write_line(msg)

    def _set_progress(self, pct: int) -> None:
        self.call_from_thread(self._update_progress, pct)

    def _update_progress(self, pct: int) -> None:
        pb = self.query_one("#progress", ProgressBar)
        pb.progress = pct

    def _run_install(self) -> None:
        """Runs in worker thread. Imports installers lazily to keep startup fast."""
        app = self.app
        install_dir = app.install_dir
        python_exe  = app.python_exe
        selected    = getattr(app, "selected_models", {})
        mode        = self._mode

        try:
            if mode in ("prereqs", "all"):
                self._log("[bold cyan]── Prerequisites ──[/]")
                from comfyui_installer.installer.prereqs import install_all_prereqs
                install_all_prereqs(self._log)
                self._set_progress(10)

            if mode in ("comfyui", "all"):
                self._log("[bold cyan]── ComfyUI Core ──[/]")
                from comfyui_installer.installer.comfyui import install_comfyui
                install_comfyui(
                    base_dir, self._log,
                    install_server_manager=getattr(app, "install_server", True),
                    install_client_wrapper=getattr(app, "install_client", True),
                )
                self._set_progress(25)

                self._log("[bold cyan]── Core Python Packages ──[/]")
                from comfyui_installer.installer.python_libs import install_core_packages
                install_core_packages(python_exe, base_dir, self._log)
                self._set_progress(45)

            if mode in ("nodes", "all"):
                self._log("[bold cyan]── Custom Nodes ──[/]")
                from comfyui_installer.installer.nodes import install_nodes
                install_nodes(install_dir, python_exe, self._log)
                self._set_progress(60)

            if mode in ("models", "all"):
                self._log("[bold cyan]── Models ──[/]")
                from comfyui_installer.installer.models import install_models
                install_models(install_dir, selected, self._log)
                self._set_progress(80)

            if mode in ("libs", "all"):
                self._log("[bold cyan]── Python Include/Libs ──[/]")
                from comfyui_installer.installer.python_libs import setup_python_libs
                setup_python_libs(install_dir, self._log)
                self._set_progress(90)

            if mode in ("triton", "all"):
                self._log("[bold cyan]── Triton / Sage Attention ──[/]")
                from comfyui_installer.installer.triton import install_triton_sage
                install_triton_sage(install_dir, python_exe, self._log)
                self._set_progress(100)

        except Exception as exc:
            self._log(f"[bold red]UNEXPECTED ERROR: {exc}[/]")
            raise

        self._done = True
        self._log("\n[bold green]✓ Complete![/] Press Esc to return to the menu.")
        self._set_progress(100)

        # Refresh verification status on main menu
        self.call_from_thread(self._refresh_main_status)

    def _refresh_main_status(self) -> None:
        from comfyui_installer.utils.verification import run_silent_verify
        from comfyui_installer.ui.screens.main_menu import MainMenuScreen
        app = self.app
        install_dir = app.install_dir
        python_exe  = app.python_exe
        selected    = getattr(app, "selected_models", {})

        from comfyui_installer.installer.models import get_all_download_pairs
        pairs = get_all_download_pairs(install_dir, selected)
        selected_files = [(p.parent.name, p.name) for _, p in pairs]

        status = run_silent_verify(install_dir, python_exe, selected_files)
        try:
            main = app.query_one(MainMenuScreen)
            main.status = status
            main.last_action = f"{INSTALL_MODES.get(self._mode, self._mode)} finished."
        except Exception:
            pass

    def action_go_back(self) -> None:
        if self._done:
            self.app.pop_screen()
        else:
            self.app.pop_screen()  # Allow back even during install for safety
