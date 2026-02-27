"""
Main menu screen — the first thing the user sees.

Layout:
  ┌─────────────────────────────────────────────────────┐
  │  Draekz ComfyUI Ultimate Installer  v3.0            │
  ├─────────────────────────────────────────────────────┤
  │  [✓] 1. ComfyUI Core     [✓] 2. Models              │
  │  [ ] 3. Custom Nodes     [ ] 4. Triton / Sage        │
  │  [ ] 5. Python Libs                                  │
  ├─────────────────────────────────────────────────────┤
  │  Download: ~45.2 GB  |  Free: 210.4 GB ✓            │
  ├─────────────────────────────────────────────────────┤
  │  > S  Select Models & Quality                        │
  │    I  Install Everything                             │
  │    V  Verify Installation                            │
  │   ──  ─────────────────────                          │
  │    1  Install ComfyUI Core                           │
  │    2  Download Models                                │
  │    3  Install Custom Nodes                           │
  │    4  Install Triton / Sage Attention                │
  │    5  Setup Python Libs                              │
  │   ──  ─────────────────────                          │
  │    6  Toggle Server Manager  [ON]                    │
  │    7  Toggle Client Wrapper  [ON]                    │
  │   ──  ─────────────────────                          │
  │    Q  Quit                                           │
  └─────────────────────────────────────────────────────┘
  Last action: Welcome! Select an option to begin.
"""

from __future__ import annotations

from pathlib import Path
from textual.app import ComposeResult
from textual.screen import Screen
from textual.widgets import Header, Footer, Static, ListView, ListItem, Label
from textual.binding import Binding
from textual.reactive import reactive
from rich.text import Text
from rich.table import Table
from rich.panel import Panel

from comfyui_installer.utils.verification import InstallStatus


TITLE = "Draekz ComfyUI Ultimate Installer"
VERSION = "4.0.0"


class MainMenuScreen(Screen):
    """Primary installer menu with arrow key navigation."""

    BINDINGS = [
        Binding("s", "select_models",   "Select Models"),
        Binding("i", "install_all",     "Install All"),
        Binding("v", "verify",          "Verify"),
        Binding("1", "install_step_1",  "ComfyUI Core"),
        Binding("2", "install_step_2",  "Models"),
        Binding("3", "install_step_3",  "Nodes"),
        Binding("4", "install_step_4",  "Triton/Sage"),
        Binding("5", "install_step_5",  "Python Libs"),
        Binding("6", "toggle_server",   "Toggle Server Mgr"),
        Binding("7", "toggle_client",   "Toggle Client Wrap"),
        Binding("q", "quit_app",        "Quit"),
    ]

    status: reactive[InstallStatus] = reactive(InstallStatus())
    last_action: reactive[str]       = reactive("Welcome! Select an option to begin.")
    install_server: reactive[bool]   = reactive(True)
    install_client: reactive[bool]   = reactive(True)
    total_gb: reactive[float]        = reactive(0.0)
    free_gb: reactive[float | None]  = reactive(None)
    quality_name: reactive[str]      = reactive("Not selected")

    def compose(self) -> ComposeResult:
        yield Header(show_clock=False)
        yield Static(id="status_bar")
        yield Static(id="disk_bar")
        yield Static(id="menu_body")
        yield Static(id="last_action_bar")
        yield Footer()

    def on_mount(self) -> None:
        self._refresh_display()

    def watch_status(self, _: InstallStatus) -> None:
        self._refresh_display()

    def watch_last_action(self, _: str) -> None:
        self._refresh_display()

    def watch_total_gb(self, _: float) -> None:
        self._refresh_display()

    def watch_free_gb(self, _: float | None) -> None:
        self._refresh_display()

    def _check(self, flag: bool) -> str:
        return "[bold green]✓[/]" if flag else "[dim]·[/]"

    def _toggle_label(self, flag: bool) -> str:
        return "[bold green]ON[/]" if flag else "[bold red]OFF[/]"

    def _refresh_display(self) -> None:
        s = self.status

        # ── Status bar ─────────────────────────────────────────────────────────
        status_text = (
            f" {self._check(s.comfyui)} ComfyUI  "
            f"{self._check(s.nodes)} Nodes  "
            f"{self._check(s.models)} Models  "
            f"{self._check(s.triton)} Triton/Sage  "
            f"{self._check(s.libs)} Python Libs"
        )
        self.query_one("#status_bar", Static).update(
            Panel(status_text, title=f"[bold cyan]{TITLE}[/] [dim]v{VERSION}[/]", padding=(0, 1))
        )

        # ── Disk bar ───────────────────────────────────────────────────────────
        total_str = f"[bold]{self.total_gb:.1f} GB[/] to download"
        if self.free_gb is not None:
            color = "green" if self.free_gb > self.total_gb else "red"
            free_str = f"[{color}]{self.free_gb:.1f} GB free[/]"
        else:
            free_str = "[dim]? GB free[/]"
        quality_str = f"Quality: [bold]{self.quality_name}[/]"
        self.query_one("#disk_bar", Static).update(
            f" {total_str}  │  {free_str}  │  {quality_str}"
        )

        # ── Menu body ──────────────────────────────────────────────────────────
        menu = (
            "\n"
            " [bold cyan]S[/]  Select Models & Quality\n"
            " [bold cyan]I[/]  Install Everything\n"
            " [bold cyan]V[/]  Verify Installation\n"
            " [dim]───────────────────────────────[/]\n"
            " [bold cyan]1[/]  Install ComfyUI Core\n"
            " [bold cyan]2[/]  Download Models\n"
            " [bold cyan]3[/]  Install Custom Nodes\n"
            " [bold cyan]4[/]  Install Triton / Sage Attention\n"
            " [bold cyan]5[/]  Setup Python Libs (include/libs)\n"
            " [dim]───────────────────────────────[/]\n"
            f" [bold cyan]6[/]  Toggle Server Manager  [{self._toggle_label(self.install_server)}]\n"
            f" [bold cyan]7[/]  Toggle Client Wrapper  [{self._toggle_label(self.install_client)}]\n"
            " [dim]───────────────────────────────[/]\n"
            " [bold cyan]Q[/]  Quit\n"
        )
        self.query_one("#menu_body", Static).update(menu)

        # ── Last action bar ────────────────────────────────────────────────────
        self.query_one("#last_action_bar", Static).update(
            f"\n [dim]Last:[/] {self.last_action}"
        )

    # ── Actions ────────────────────────────────────────────────────────────────

    def action_select_models(self) -> None:
        from comfyui_installer.ui.screens.model_selection import ModelSelectionScreen
        self.app.push_screen(ModelSelectionScreen())

    def action_install_all(self) -> None:
        from comfyui_installer.ui.screens.install_progress import InstallProgressScreen
        self.app.push_screen(InstallProgressScreen(mode="all"))

    def action_verify(self) -> None:
        from comfyui_installer.ui.screens.verification import VerificationScreen
        self.app.push_screen(VerificationScreen())

    def action_install_step_1(self) -> None:
        from comfyui_installer.ui.screens.install_progress import InstallProgressScreen
        self.app.push_screen(InstallProgressScreen(mode="comfyui"))

    def action_install_step_2(self) -> None:
        from comfyui_installer.ui.screens.install_progress import InstallProgressScreen
        self.app.push_screen(InstallProgressScreen(mode="models"))

    def action_install_step_3(self) -> None:
        from comfyui_installer.ui.screens.install_progress import InstallProgressScreen
        self.app.push_screen(InstallProgressScreen(mode="nodes"))

    def action_install_step_4(self) -> None:
        from comfyui_installer.ui.screens.install_progress import InstallProgressScreen
        self.app.push_screen(InstallProgressScreen(mode="triton"))

    def action_install_step_5(self) -> None:
        from comfyui_installer.ui.screens.install_progress import InstallProgressScreen
        self.app.push_screen(InstallProgressScreen(mode="libs"))

    def action_toggle_server(self) -> None:
        self.install_server = not self.install_server
        state = "ON" if self.install_server else "OFF"
        self.last_action = f"Server Manager toggled {state}"
        self._refresh_display()

    def action_toggle_client(self) -> None:
        self.install_client = not self.install_client
        state = "ON" if self.install_client else "OFF"
        self.last_action = f"Client Wrapper toggled {state}"
        self._refresh_display()

    def action_quit_app(self) -> None:
        self.app.exit()
