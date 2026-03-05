"""
Folder selection screen — lets the user type or paste an installation path.

ComfyUI_windows_portable will be created inside whatever folder is chosen.
"""

from __future__ import annotations

from pathlib import Path

from textual.app import ComposeResult
from textual.binding import Binding
from textual.screen import Screen
from textual.widgets import Header, Footer, Static, Input


class FolderSelectionScreen(Screen):
    """Let the user choose the installation base directory."""

    BINDINGS = [
        Binding("escape", "go_back", "Cancel"),
    ]

    def __init__(self, current_path: str) -> None:
        super().__init__()
        self._current = current_path

    def compose(self) -> ComposeResult:
        yield Header()
        yield Static(
            "\n [bold]Set Installation Folder[/]\n\n"
            " [dim]ComfyUI_windows_portable will be created inside this folder.[/]\n"
            " [dim]Type or paste a path, then press Enter to confirm.  Esc to cancel.[/]\n",
            id="instructions",
        )
        yield Input(
            value=self._current,
            placeholder=r"C:\path\to\install\folder",
            id="path_input",
        )
        yield Static("", id="error_msg")
        yield Footer()

    def on_mount(self) -> None:
        self.query_one("#path_input", Input).focus()

    def on_input_submitted(self, event: Input.Submitted) -> None:
        path_str = event.value.strip()
        if not path_str:
            self.query_one("#error_msg", Static).update(
                " [bold red]Path cannot be empty.[/]"
            )
            return
        self.dismiss(Path(path_str))

    def action_go_back(self) -> None:
        self.dismiss(None)
