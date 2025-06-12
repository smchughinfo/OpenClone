# U-2-Net - AI Background Removal

![U-2-Net Overview](Documentation/u2net.png)

## What is this?

This is the background removal service for OpenClone, based on the open-source U-2-Net project. It processes clone photos to remove backgrounds through a Flask REST API, enabling clean portraits with transparent backgrounds for deepfake generation. The service includes custom post-processing with configurable threshold parameters and GPU acceleration support.

The implementation wraps the core U-2-Net neural network with OpenClone-specific enhancements including custom mask application logic, LogWeaver integration, and OpenCloneFS file system access.

## Setup

**Linux Container (Recommended):**
Build container: `docker build --no-cache -t openclone-u-2-net:1.0 .`
Run using script: `/StartStopScripts/U-2-Net/start.bat`

**Windows Development:**
1. Install VS Code Theme [Candy](https://vscodethemes.com/e/meganrogge.candy-theme/candy?language=javascript)
2. [Install Python 3.8.8](https://www.python.org/downloads/release/python-388/) (Container uses 3.10.12)
3. [Install CUDA Toolkit 11.8](https://developer.nvidia.com/cuda-11-8-0-download-archive?target_os=Windows&target_arch=x86_64&target_version=11&target_type=exe_local) (Container uses 11.2.2)
4. `git clone https://github.com/smchughinfo/U-2-Net`
5. `cd U-2-Net`
6. `code .`
7. `ctrl+shift+p > Python: Create Environment > Venv > Python 3.8.8rc 64-bit`
8. `pip install -r U-2-Net/requirements.txt`

**Note:** GeForce drivers must support the CUDA version being used.

## How to run it

Set required environment variables (see root README.md for complete list). The service runs as a Flask API on port 5002. Send POST requests to `/remove-background` with parameters for source image path, output image path, and threshold value (0-255, higher = more aggressive background removal).

For more technical details and API documentation, see [CLAUDE.md](CLAUDE.md).