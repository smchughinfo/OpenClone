# OpenVoice

## Setup

**Linux Container (Recommended):**

**Windows Development:**




https://github.com/Alienpups/OpenVoice/blob/main/docs/USAGE_WINDOWS.md


1. Install VS Code Theme [Dracula Theme](https://vscodethemes.com/e/dracula-theme.theme-dracula/dracula-theme)
2. [Install Python 3.9.13](https://www.python.org/downloads/release/python-3913/)
3. [Install CUDA Toolkit 11.8](https://developer.nvidia.com/cuda-11-8-0-download-archive?target_os=Windows&target_arch=x86_64&target_version=11&target_type=exe_local)
4. `git clone https://github.com/smchughinfo/SadTalker.git`
5. `cd SadTalker`
6. `code .`
7. `ctrl+shift+p > Python: Create Environment > Venv > Python 3.8.8rc 64-bit`
8. .\.venv\Scripts\activate
9. `pip install torch==2.1.0 torchvision==0.16.0 torchaudio==2.1.0 --index-url https://download.pytorch.org/whl/cu118`
10. `pip install -r SadTalker/requirements.txt`
11. **Download AI Model Checkpoints**: Extract and place in `SadTalker/checkpoints/` directory
    - **Official**: [SadTalker Models](https://drive.google.com/file/d/1gwWh45pF7aelNP_P78uDJL8Sycep-K7j/view) (Original from SadTalker GitHub)
    - **Mirror**: [Backup Models](https://drive.google.com/file/d/1DyeiBYmVTiwXQIzCIGqFA8Kc86iL6d1I/view?usp=sharing) (OpenClone mirror)
