"""
Two-step model selection screen:
  Step 1: Toggle model families on/off (arrow keys + Space)
  Step 2: Choose quality tier (1-6 / arrow keys + Enter)
"""

from __future__ import annotations

from textual.app import ComposeResult
from textual.screen import Screen
from textual.widgets import Header, Footer, ListView, ListItem, Label, Static, Button
from textual.binding import Binding
from textual.reactive import reactive
from textual.message import Message

from comfyui_installer.config.models import MODEL_FAMILIES, ModelFamily

QUALITY_TIERS = [
    (0, "Q4 GGUF  — Lowest VRAM  (<12 GB)"),
    (1, "Q5 GGUF  — Balanced     (12-16 GB)"),
    (2, "Q6 GGUF  — Good Balance (~16 GB)"),
    (3, "Q8 GGUF  — High Quality (>16 GB)"),
    (4, "FP8      — Very High    (>24 GB, SafeTensors)"),
    (5, "Full/BF16 — Maximum     (>32 GB, SafeTensors)"),
]


class ModelSelectionScreen(Screen):
    """Step 1: Select which model families to install."""

    BINDINGS = [
        Binding("space", "toggle_selected", "Toggle"),
        Binding("a",     "select_all",      "All"),
        Binding("n",     "select_none",     "None"),
        Binding("enter", "next_step",       "Next: Quality"),
        Binding("escape","go_back",         "Back"),
    ]

    def __init__(self) -> None:
        super().__init__()
        # Selected families: family_id → bool
        self._selected: dict[int, bool] = {f.id: False for f in MODEL_FAMILIES}

    def compose(self) -> ComposeResult:
        yield Header()
        yield Static(
            "\n [bold]Select model families[/]  "
            "[dim]Space=toggle  A=all  N=none  Enter=choose quality  Esc=back[/]\n",
            id="instructions",
        )
        items = []
        for family in MODEL_FAMILIES:
            items.append(ListItem(Label(self._label(family)), id=f"family_{family.id}"))
        yield ListView(*items, id="family_list")
        yield Footer()

    def _label(self, family: ModelFamily) -> str:
        check = "[bold green]✓[/] " if self._selected[family.id] else "[ ] "
        tiers = len(family.options)
        return f"{check}{family.name}  [dim]({tiers} quality tier{'s' if tiers != 1 else ''})[/]"

    def _refresh_labels(self) -> None:
        lv = self.query_one("#family_list", ListView)
        for family in MODEL_FAMILIES:
            item = self.query_one(f"#family_{family.id}", ListItem)
            item.query_one(Label).update(self._label(family))

    def action_toggle_selected(self) -> None:
        lv = self.query_one("#family_list", ListView)
        if lv.index is not None and lv.index < len(MODEL_FAMILIES):
            fid = MODEL_FAMILIES[lv.index].id
            self._selected[fid] = not self._selected[fid]
            self._refresh_labels()

    def action_select_all(self) -> None:
        for fid in self._selected:
            self._selected[fid] = True
        self._refresh_labels()

    def action_select_none(self) -> None:
        for fid in self._selected:
            self._selected[fid] = False
        self._refresh_labels()

    def action_next_step(self) -> None:
        chosen = [fid for fid, v in self._selected.items() if v]
        self.app.push_screen(
            QualitySelectionScreen(selected_family_ids=chosen),
            callback=self._on_quality_chosen,
        )

    def _on_quality_chosen(self, result: dict[int, int] | None) -> None:
        if result is not None:
            # Store in app state and go back
            self.app.selected_models = result
            # Update main menu quality name and last action
            from comfyui_installer.ui.screens.main_menu import MainMenuScreen
            main = self.app.query_one(MainMenuScreen)
            tier_names = {0: "Q4", 1: "Q5", 2: "Q6", 3: "Q8", 4: "FP8", 5: "Full"}
            if result:
                first_tier = next(iter(result.values()))
                main.quality_name = tier_names.get(first_tier, "Custom")
            main.last_action = f"Selected {len(result)} model families. Estimating download size..."
            # Kick off background size estimation
            self.app.estimate_sizes_for_selection(result)
        self.app.pop_screen()

    def action_go_back(self) -> None:
        self.app.pop_screen()


class QualitySelectionScreen(Screen):
    """Step 2: Choose quality tier to apply to all selected families."""

    BINDINGS = [
        Binding("enter",  "confirm",  "Confirm"),
        Binding("escape", "go_back",  "Back"),
    ]

    def __init__(self, selected_family_ids: list[int]) -> None:
        super().__init__()
        self._family_ids = selected_family_ids

    def compose(self) -> ComposeResult:
        count = len(self._family_ids)
        yield Header()
        yield Static(
            f"\n [bold]Choose quality tier[/] for [bold cyan]{count}[/] selected families.\n"
            " [dim]Arrow keys to navigate, Enter to confirm, Esc to go back.[/]\n",
            id="instructions",
        )
        items = [
            ListItem(Label(f" {i+1}. {name}"), id=f"tier_{idx}")
            for idx, name in QUALITY_TIERS
        ]
        yield ListView(*items, id="tier_list")
        yield Footer()

    def action_confirm(self) -> None:
        lv = self.query_one("#tier_list", ListView)
        if lv.index is None:
            return
        chosen_tier = QUALITY_TIERS[lv.index][0]
        result = {fid: chosen_tier for fid in self._family_ids}
        self.dismiss(result)

    def action_go_back(self) -> None:
        self.dismiss(None)
