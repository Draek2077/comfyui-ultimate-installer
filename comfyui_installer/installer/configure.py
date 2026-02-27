"""
Write ComfyUI configuration files and create Desktop/Start Menu shortcuts.
"""

from __future__ import annotations

import json
import subprocess
from pathlib import Path
from typing import Callable

from comfyui_installer.config.settings import (
    COMFY_LOGO_URL,
    COMFY_CLIENT_URL,
    SERVER_MANAGER_URL,
    SERVER_MANAGER_MSI_NAME,
    CLIENT_WRAPPER_URL,
    CLIENT_WRAPPER_MSI_NAME,
)
from comfyui_installer.utils.downloader import download

Log = Callable[[str], None]

COMFY_SETTINGS = {
    "Comfy.Validation.Workflows": True,
    "Comfy.UseNewMenu": "Top",
    "Comfy.Minimap.Visible": False,
    "Comfy.Workflow.WorkflowTabsPosition": "Sidebar",
    "Comfy.Sidebar.Size": "small",
    "Comfy.SnapToGrid.GridSize": 20,
    "Comfy.Graph.CanvasZoomOptimization": True,
    "Comfy.LinkRenderMode": 0,
    "Comfy.TextareaWidget.FontSize": 12,
    "KJNodes.browserStatus": True,
    "Crystools.MonitorHeight": 28,
    "Crystools.ShowHdd": True,
    "Crystools.WhichHdd": "C:\\",
    "Comfy.DisabledExtension": [
        "pyssss.Locking",
        "pyssss.SnapToGrid",
        "pyssss.ImageFeed",
        "pyssss.ShowImageOnMenu",
        "rgthree.TopMenu",
    ],
}

MANAGER_CONFIG = """\
[config]
preview_method = taesd
use_uv = False
channel_url = https://raw.githubusercontent.com/ltdrdata/ComfyUI-Manager/main
share_option = all
bypass_ssl = False
update_policy = stable-comfyui
windows_selector_event_loop_policy = False
db_mode = cache
"""


def write_settings(install_dir: Path, log: Log) -> None:
    user_default = install_dir / "ComfyUI" / "user" / "default"
    user_default.mkdir(parents=True, exist_ok=True)

    settings_file = user_default / "comfy.settings.json"
    settings_file.write_text(json.dumps(COMFY_SETTINGS, indent=2))
    log(f"Written: {settings_file.name}")

    manager_config_dir = user_default / "ComfyUI-Manager"
    manager_config_dir.mkdir(parents=True, exist_ok=True)
    (manager_config_dir / "config.ini").write_text(MANAGER_CONFIG)
    log("Written: ComfyUI-Manager/config.ini")


def download_icons(install_dir: Path, log: Log) -> tuple[Path, Path]:
    comfyui_dir = install_dir / "ComfyUI"
    logo_path   = comfyui_dir / "Comfy_Logo.ico"
    client_path = comfyui_dir / "Comfy_Client.ico"

    download(COMFY_LOGO_URL,   logo_path,   on_progress=log)
    download(COMFY_CLIENT_URL, client_path, on_progress=log)

    return logo_path, client_path


def create_shortcuts(install_dir: Path, log: Log) -> None:
    logo_path, client_path = download_icons(install_dir, log)

    run_bat = install_dir / "run_nvidia_gpu_fast_fp16_accumulation.bat"

    _create_shortcut(
        name="ComfyUI Server",
        target=f'cmd.exe /c "{run_bat}"',
        icon=str(logo_path),
        window_style=7,  # minimized
        log=log,
    )
    _create_shortcut(
        name="ComfyUI Client",
        target="msedge.exe",
        arguments="--app=http://127.0.0.1:8188/",
        icon=str(client_path),
        log=log,
    )


def _create_shortcut(
    name: str,
    target: str,
    icon: str,
    arguments: str = "",
    window_style: int = 1,
    log: Log | None = None,
) -> None:
    import os
    desktop = Path(os.environ.get("USERPROFILE", "")) / "Desktop"
    start_menu = Path(os.environ.get("APPDATA", "")) / "Microsoft" / "Windows" / "Start Menu" / "Programs"

    ps_template = """
$WshShell = New-Object -ComObject WScript.Shell
$lnk = $WshShell.CreateShortcut("{path}")
$lnk.TargetPath = "{target}"
$lnk.Arguments = "{args}"
$lnk.IconLocation = "{icon}"
$lnk.WindowStyle = {style}
$lnk.Save()
"""
    for folder in (desktop, start_menu):
        folder.mkdir(parents=True, exist_ok=True)
        lnk_path = folder / f"{name}.lnk"
        ps_script = ps_template.format(
            path=str(lnk_path).replace("\\", "\\\\"),
            target=target.replace("\\", "\\\\"),
            args=arguments,
            icon=icon.replace("\\", "\\\\"),
            style=window_style,
        )
        subprocess.run(
            ["powershell", "-NoProfile", "-Command", ps_script],
            check=False,
        )
        if log:
            log(f"Shortcut created: {lnk_path.name}")


def install_server_manager(install_dir: Path, log: Log) -> bool:
    dest = install_dir / SERVER_MANAGER_MSI_NAME
    if not download(SERVER_MANAGER_URL, dest, on_progress=log):
        log("ERROR: Could not download Server Manager installer.")
        return False
    log("Launching Server Manager installer (UAC required)...")
    subprocess.run(["msiexec", "/i", str(dest), "/qb"], check=False)
    dest.unlink(missing_ok=True)
    return True


def install_client_wrapper(install_dir: Path, log: Log) -> bool:
    dest = install_dir / CLIENT_WRAPPER_MSI_NAME
    if not download(CLIENT_WRAPPER_URL, dest, on_progress=log):
        log("ERROR: Could not download Client Wrapper installer.")
        return False
    log("Launching Client Wrapper installer (UAC required)...")
    subprocess.run(["msiexec", "/i", str(dest), "/qb"], check=False)
    dest.unlink(missing_ok=True)
    return True
