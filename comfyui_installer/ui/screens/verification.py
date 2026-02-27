"""
Verification screen — shows detailed status of each installation component.
"""

from __future__ import annotations

from textual.app import ComposeResult
from textual.screen import Screen
from textual.widgets import Header, Footer, Static, DataTable
from textual.binding import Binding
from rich.text import Text


class VerificationScreen(Screen):
    """Display a full verification report."""

    BINDINGS = [
        Binding("escape", "go_back", "Back"),
        Binding("r",      "refresh", "Refresh"),
    ]

    def compose(self) -> ComposeResult:
        yield Header()
        yield Static("\n [bold]Installation Verification[/]  [dim]R=refresh  Esc=back[/]\n", id="title")
        yield DataTable(id="verify_table")
        yield Static(id="summary")
        yield Footer()

    def on_mount(self) -> None:
        table = self.query_one("#verify_table", DataTable)
        table.add_columns("Component", "Status", "Details")
        self._run_checks()

    def _run_checks(self) -> None:
        from comfyui_installer.utils.verification import (
            verify_comfyui, verify_nodes, verify_triton, verify_libs,
        )
        from comfyui_installer.installer.models import get_all_download_pairs

        app = self.app
        install_dir = app.base_dir / "ComfyUI_windows_portable"
        python_exe  = install_dir / "python_embeded" / "python.exe"
        selected    = getattr(app, "selected_models", {})

        table = self.query_one("#verify_table", DataTable)
        table.clear()

        def row(name: str, ok: bool, detail: str = "") -> None:
            status = Text("✓ OK",     style="bold green") if ok else Text("✗ Missing", style="bold red")
            table.add_row(name, status, detail or ("Found" if ok else "Not found"))

        row("ComfyUI Core",        verify_comfyui(install_dir),
            str(install_dir / "run_nvidia_gpu.bat"))
        row("Custom Nodes",        verify_nodes(install_dir),
            str(install_dir / "ComfyUI" / "custom_nodes" / "ComfyUI-Manager"))
        row("Python Libs/Include", verify_libs(install_dir),
            str(install_dir / "python_embeded" / "libs"))
        row("Triton/SageAttention", verify_triton(python_exe, install_dir),
            "triton-windows + sageattention packages")

        # Model files
        pairs = get_all_download_pairs(install_dir, selected)
        missing = [(_, p) for _, p in pairs if not p.exists()]
        models_ok = len(missing) == 0
        detail = f"{len(pairs) - len(missing)}/{len(pairs)} files present"
        row("Models", models_ok, detail)

        if missing:
            for _, p in missing[:5]:
                table.add_row("  missing", Text("✗", style="red"), p.name)
            if len(missing) > 5:
                table.add_row("  ...", Text("", style="dim"), f"and {len(missing)-5} more")

        all_ok = models_ok and verify_comfyui(install_dir) and verify_nodes(install_dir) \
                 and verify_libs(install_dir) and verify_triton(python_exe, install_dir)

        summary = "[bold green]All components verified ✓[/]" if all_ok \
                  else "[bold yellow]Some components need attention — see table above.[/]"
        self.query_one("#summary", Static).update(f"\n {summary}\n")

    def action_refresh(self) -> None:
        self.query_one("#verify_table", DataTable).clear(columns=True)
        self.query_one("#verify_table", DataTable).add_columns("Component", "Status", "Details")
        self._run_checks()

    def action_go_back(self) -> None:
        self.app.pop_screen()
