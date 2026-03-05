"""
Verification screen — shows detailed status of each installation component.
"""

from __future__ import annotations

from pathlib import Path

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
        self.run_worker(self._run_checks, thread=True)

    def _run_checks(self) -> None:
        from comfyui_installer.utils.verification import (
            verify_comfyui, verify_nodes, verify_triton, verify_libs,
        )
        from comfyui_installer.installer.models import get_all_download_pairs

        app         = self.app
        install_dir = app.install_dir
        install_base = getattr(app, "install_base_dir", install_dir.parent)
        python_exe  = app.python_exe
        selected    = getattr(app, "selected_models", {})

        rows: list[tuple[str, Text, str]] = []

        def short(path: Path) -> str:
            """Show path relative to install_base to reduce horizontal clutter."""
            try:
                return str(path.relative_to(install_base))
            except ValueError:
                return str(path)

        def add(name: str, ok: bool, detail: str = "") -> None:
            status = Text("✓ OK",      style="bold green") if ok \
                else Text("✗ Missing", style="bold red")
            rows.append((name, status, detail or ("Found" if ok else "Not found")))

        # ── Core components ───────────────────────────────────────────────────
        add("ComfyUI Core",
            verify_comfyui(install_dir),
            short(install_dir / "run_nvidia_gpu.bat"))

        add("Custom Nodes",
            verify_nodes(install_dir),
            short(install_dir / "ComfyUI" / "custom_nodes" / "ComfyUI-Manager"))

        add("Python Libs/Include",
            verify_libs(install_dir),
            short(install_dir / "python_embeded" / "libs"))

        add("Triton/SageAttention",
            verify_triton(python_exe, install_dir),
            "triton-windows + sageattention packages")

        # ── Model files ───────────────────────────────────────────────────────
        if selected:
            pairs   = get_all_download_pairs(install_dir, selected)
            total   = len(pairs)
            present = sum(1 for _, p in pairs if p.exists())
            missing = total - present
            models_ok = missing == 0

            add("Models", models_ok, f"{present}/{total} files present")

            for _, path in pairs:
                exists = path.exists()
                status = Text("✓ OK",      style="green") if exists \
                    else Text("✗ Missing", style="red")
                rows.append((f"  {path.name}", status, short(path)))
        else:
            rows.append(("Models", Text("— none selected", style="dim"),
                         "Press Esc, then S to select models"))
            models_ok = True  # not applicable

        # ── Push to UI on main thread ─────────────────────────────────────────
        self.app.call_from_thread(self._apply_rows, rows)

    def _apply_rows(self, rows: list[tuple[str, Text, str]]) -> None:
        table = self.query_one("#verify_table", DataTable)
        table.clear()
        for name, status, detail in rows:
            table.add_row(name, status, detail)

        # Summary — derive from rows (anything with ✗ in status)
        has_missing = any("✗" in s.plain for _, s, _ in rows)
        summary = "[bold yellow]Some components need attention — see table above.[/]" \
            if has_missing else "[bold green]All components verified ✓[/]"
        self.query_one("#summary", Static).update(f"\n {summary}\n")

    def action_refresh(self) -> None:
        self.query_one("#verify_table", DataTable).clear(columns=True)
        self.query_one("#verify_table", DataTable).add_columns("Component", "Status", "Details")
        self.run_worker(self._run_checks, thread=True)

    def action_go_back(self) -> None:
        self.app.pop_screen()
