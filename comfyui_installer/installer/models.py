"""
Download selected main models and all applicable extras.

Selection state is passed in as a dict:
  { family_id: quality_tier_index }  (0-based tier index)

Quality fallback: if the selected tier doesn't exist for a family,
installs the highest available tier below the selection.
"""

from __future__ import annotations

from pathlib import Path
from typing import Callable

from comfyui_installer.config.models import MODEL_FAMILIES, ModelFamily, ModelOption, T5_ENCODERS
from comfyui_installer.config.extras import EXTRA_MODELS, REPO_EXTRAS
from comfyui_installer.utils.downloader import download_if_missing, clone_repo

Log = Callable[[str], None]

# model_type → subdirectory under models\
TYPE_TO_SUBDIR: dict[str, str] = {
    "gguf":            "unet",
    "gguf_flux":       "unet",
    "checkpoint":      "checkpoints",
    "checkpoints":     "checkpoints",
    "diffusion_model": "diffusion_models",
    "lora":            "loras",
}


def resolve_option(family: ModelFamily, quality_index: int) -> ModelOption | None:
    """
    Return the best available option at or below quality_index.
    Uses each option's explicit .tier when set, otherwise falls back to list index.
    Returns None if the family has no options.
    """
    if not family.options:
        return None

    # Build global_tier → option mapping
    tier_map: dict[int, ModelOption] = {
        (opt.tier if opt.tier is not None else idx): opt
        for idx, opt in enumerate(family.options)
    }

    # Find highest available tier at or below quality_index
    for tier in range(quality_index, -1, -1):
        if tier in tier_map:
            return tier_map[tier]
    return family.options[0]  # always install at least the lowest available


def install_models(
    install_dir: Path,
    selected: dict[int, int],  # {family_id: quality_index}
    log: Log,
) -> bool:
    """
    Download all selected main models plus relevant extras.

    Args:
        install_dir: Root of ComfyUI_windows_portable.
        selected:    Maps family id → chosen quality tier index (0-based).
        log:         Progress callback.
    """
    if not selected:
        log("No models selected — skipping model download.")
        return True

    models_root = install_dir / "ComfyUI" / "models"
    active_flags: set[str] = set()

    # Collect which family flags are active
    for family in MODEL_FAMILIES:
        if family.id in selected:
            active_flags.add(family.family_flag)

    # ── Main model files ──────────────────────────────────────────────────────
    total = len(selected)
    for i, (family_id, quality_index) in enumerate(selected.items(), 1):
        family = next((f for f in MODEL_FAMILIES if f.id == family_id), None)
        if not family:
            continue

        option = resolve_option(family, quality_index)
        if not option:
            log(f"SKIP {family.name}: no options defined")
            continue

        subdir = TYPE_TO_SUBDIR.get(option.model_type, "checkpoints")
        dest   = models_root / subdir / option.filename
        log(f"[{i}/{total}] {family.name} → {option.name}")
        download_if_missing(option.url, dest, on_progress=log)

        # gguf_flux: also download T5 encoder companion
        if option.model_type == "gguf_flux":
            t5_filename, t5_url = T5_ENCODERS.get(quality_index, T5_ENCODERS[0])
            t5_dest = models_root / "text_encoders" / t5_filename
            log(f"  + T5 encoder: {t5_filename}")
            download_if_missing(t5_url, t5_dest, on_progress=log)

    # ── Extra/shared models ───────────────────────────────────────────────────
    log("Downloading shared/extra models...")
    for extra in EXTRA_MODELS:
        if extra.flag != "ALWAYS" and extra.flag not in active_flags:
            continue
        dest = models_root / extra.subdir / extra.filename
        log(f"  Extra [{extra.flag}]: {extra.filename}")
        download_if_missing(extra.url, dest, on_progress=log)

    # ── Repo-based extras (git clone) ─────────────────────────────────────────
    log("Cloning repo-based model extras...")
    for flag, subdir, repo_url in REPO_EXTRAS:
        if flag != "ALWAYS" and flag not in active_flags:
            continue
        dest = models_root / subdir
        clone_repo(repo_url, dest, on_progress=log)

    log("Model downloads complete.")
    return True


def detect_installed_models(install_dir: Path) -> dict[int, int]:
    """
    Scan the models directory for files matching known model families.

    Returns {family_id: highest_found_tier_index} for every family that has
    at least one model file present on disk.
    """
    models_root = install_dir / "ComfyUI" / "models"
    result: dict[int, int] = {}

    for family in MODEL_FAMILIES:
        for list_idx, option in enumerate(family.options):
            tier_idx = option.tier if option.tier is not None else list_idx
            subdir = TYPE_TO_SUBDIR.get(option.model_type, "checkpoints")
            if (models_root / subdir / option.filename).exists():
                if family.id not in result or tier_idx > result[family.id]:
                    result[family.id] = tier_idx

    return result


def get_all_download_pairs(
    install_dir: Path,
    selected: dict[int, int],
) -> list[tuple[str, Path]]:
    """
    Return (url, dest_path) for every file that would be downloaded
    for the given selection. Used by the size estimator.
    """
    models_root = install_dir / "ComfyUI" / "models"
    active_flags: set[str] = set()
    pairs: list[tuple[str, Path]] = []

    for family in MODEL_FAMILIES:
        if family.id in selected:
            active_flags.add(family.family_flag)

    for family_id, quality_index in selected.items():
        family = next((f for f in MODEL_FAMILIES if f.id == family_id), None)
        if not family:
            continue
        option = resolve_option(family, quality_index)
        if not option:
            continue
        subdir = TYPE_TO_SUBDIR.get(option.model_type, "checkpoints")
        pairs.append((option.url, models_root / subdir / option.filename))

        if option.model_type == "gguf_flux":
            t5_filename, t5_url = T5_ENCODERS.get(quality_index, T5_ENCODERS[0])
            pairs.append((t5_url, models_root / "text_encoders" / t5_filename))

    for extra in EXTRA_MODELS:
        if extra.flag != "ALWAYS" and extra.flag not in active_flags:
            continue
        pairs.append((extra.url, models_root / extra.subdir / extra.filename))

    return pairs
