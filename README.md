# Draekz ComfyUI Ultimate Installer

_NOTE: I have no relation or connection to the ComfyUI team. This is a personal quality of life project that i use to install and manage ComfyUI installations, and I share it with others._

This installer aims to allow the installation of ComfyUI for NVIDIA on Windows (including Sage Attention, Triton Windows, xFormers) and all the accellerations enabled out of the box. It supports installing commonly used nodes, as well as multiple levels of quality of all of the best models available today.

**It currently supports: SD1.5, SDXL, SD3.5, HiDream, Flux Dev, Flux Kontext, Qwen Image, Qwen Image Edit, WAN 2.1 and WAN 2.2** and it attempts to let you choose your VRAM levels to install the appropriate models for the best quality for your hardware. It also installs all related models one would need for a variety of tasks. It leverages Huggingface to download all of the models, and github to download all of the nodes.

**Installer Menu:**

<img width="1182" height="624" alt="image" src="https://github.com/user-attachments/assets/ca434751-e397-49ca-9c71-c12bd136d4d0" />
<br/>
<br/>
I use the installation of ComfyUI 0.3.49 then automatically upgrades from there. The installer ensures a Python 3.12 environment and a full compatibility with all the nodes I install. It adds several customizations to initial ComfyUI configuration, as well as a convenient ComfyUI frontend launcher for the start menu. The ComfyUI Server Manager project is also installed automatically if requested in the install process, and it will provide an easy to use tray interface to run and manage the ComfyUI Server in Windows environments.

Once the base ComfyUI installation is complete, you can re-use the installer to add models easily without having to re-download or re-install parts that were already installed before.

The project was written entirely using Gemini 2.5 Pro.

_If you are interested in ComfyUI please visit:_

https://github.com/comfyanonymous/ComfyUI
