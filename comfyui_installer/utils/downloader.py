"""
Generic file downloader wrapping curl.

Matches the :grab subroutine in the original batch file:
  - curl -C - (resume partial downloads)
  - -# (progress bar)
  - -L (follow redirects)
  - --ssl-no-revoke (required for some HuggingFace URLs on Windows)
  - 3 retry attempts
  - Creates destination directory if missing
  - Skips download if file already exists at expected size
"""

from __future__ import annotations

import subprocess
import time
from pathlib import Path
from typing import Callable


def run_logged(
    cmd: list[str],
    log: Callable[[str], None] | None = None,
    **kwargs,
) -> int:
    """
    Run a subprocess, stream output to log, return exit code.
    stdin is always DEVNULL so interactive prompts (e.g. 'pause') never block.

    Line routing:
      \\n-terminated lines  → log(line)        — appended to scrolling log
      \\r-terminated lines  → log("\\r" + line) — caller treats as an in-place status update
    """
    proc = subprocess.Popen(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        stdin=subprocess.DEVNULL,
        **kwargs,
    )

    buf = b""
    for chunk in iter(lambda: proc.stdout.read(512), b""):
        buf += chunk
        while True:
            nl = buf.find(b"\n")
            cr = buf.find(b"\r")
            if nl == -1 and cr == -1:
                break
            if nl != -1 and (cr == -1 or nl < cr):
                # \n first — normal log line (strip any stray \r)
                line = buf[:nl].rstrip(b"\r").decode("utf-8", errors="replace")
                buf = buf[nl + 1:]
                if line.strip() and log:
                    log(line)
            elif cr + 1 < len(buf) and buf[cr + 1] == ord("\n"):
                # \r\n — Windows line ending, treat as normal log line
                line = buf[:cr].decode("utf-8", errors="replace")
                buf = buf[cr + 2:]
                if line.strip() and log:
                    log(line)
            else:
                # \r alone — progress/status update (curl %, git receiving %, etc.)
                line = buf[:cr].decode("utf-8", errors="replace")
                buf = buf[cr + 1:]
                if line.strip() and log:
                    log("\r" + line)

    if buf.strip() and log:
        log(buf.decode("utf-8", errors="replace").strip())

    proc.wait()
    return proc.returncode


def download(
    url: str,
    dest: Path,
    retries: int = 3,
    on_progress: Callable[[str], None] | None = None,
) -> bool:
    """
    Download url to dest using curl with resume support.

    Args:
        url:         Direct download URL.
        dest:        Destination file path (directory created automatically).
        retries:     Number of retry attempts on failure.
        on_progress: Optional callback for status strings like "Downloading foo.bin…"

    Returns:
        True on success, False after all retries are exhausted.
    """
    dest = Path(dest)
    dest.parent.mkdir(parents=True, exist_ok=True)

    filename = dest.name

    for attempt in range(1, retries + 1):
        if attempt == 1:
            status = f"Downloading {filename}..."
        else:
            status = f"Retrying {filename} (attempt {attempt}/{retries})..."

        if on_progress:
            on_progress(status)

        cmd = [
            "curl",
            "-C", "-",          # resume partial
            "--fail",           # non-zero exit on HTTP errors (4xx/5xx)
            "-#",               # progress bar (works in piped/non-tty mode)
            "-L",               # follow redirects
            "--ssl-no-revoke",  # bypass SSL revocation check (needed for some HF URLs)
            "-o", str(dest),
            url,
        ]

        try:
            rc = run_logged(cmd, log=on_progress)
            if rc == 0:
                return True
        except FileNotFoundError:
            if on_progress:
                on_progress("ERROR: curl not found. Please install curl and retry.")
            return False

        if on_progress:
            on_progress(f"Download failed (attempt {attempt}). {'Retrying in 3s...' if attempt < retries else 'Giving up.'}")

        if attempt < retries:
            time.sleep(3)
        else:
            # Clean up partial file on final failure
            if dest.exists():
                dest.unlink(missing_ok=True)

    return False


def download_if_missing(
    url: str,
    dest: Path,
    on_progress: Callable[[str], None] | None = None,
) -> bool:
    """
    Download url to dest only if dest does not already exist.
    Returns True if file exists (either already present or just downloaded).
    """
    if dest.exists():
        if on_progress:
            on_progress(f"Already exists, skipping: {dest.name}")
        return True
    return download(url, dest, on_progress=on_progress)


def clone_repo(
    url: str,
    dest: Path,
    python_exe: Path | None = None,
    on_progress: Callable[[str], None] | None = None,
) -> bool:
    """
    Git clone url to dest. Skips if dest already exists.
    Installs requirements.txt afterward using python_exe (embedded Python).
    Returns True on success.
    """
    dest = Path(dest)

    if dest.exists():
        if on_progress:
            on_progress(f"Already cloned, skipping: {dest.name}")
        return True

    repo_name = url.rstrip("/").rstrip(".git").split("/")[-1]
    if on_progress:
        on_progress(f"Cloning {repo_name}...")

    rc = run_logged(
        ["git", "clone", url, str(dest)],
        log=on_progress,
    )
    if rc != 0:
        if on_progress:
            on_progress(f"ERROR: Failed to clone {repo_name}")
        return False

    reqs = dest / "requirements.txt"
    if reqs.exists():
        if on_progress:
            on_progress(f"Installing requirements for {repo_name}...")
        pip_cmd = (
            [str(python_exe), "-m", "pip"] if python_exe
            else ["pip"]
        )
        run_logged(
            pip_cmd + [
                "install", "-r", str(reqs),
                "--no-warn-script-location",
                "--no-color", "--progress-bar", "off", "-q",
            ],
            log=on_progress,
        )

    return True
