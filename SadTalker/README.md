# SadTalker - AI Deepfake Video Generation

![SadTalker Overview](Documentation/sadtalker.png)

## What is this?

This is the deepfake video generation service for OpenClone, based on the open-source SadTalker project. It generates talking head videos by combining a static image with audio input through a Flask REST API. The service includes custom M3U8 HLS streaming for real-time playback, comprehensive logging via LogWeaver, and GPU acceleration support.

The implementation wraps the core SadTalker functionality with OpenClone-specific enhancements including dual output formats (MP4 and M3U8), animation parameter caching, and integration with the shared OpenCloneFS file system.

## Setup

**Linux Container (Recommended):**
Build container: `docker build --no-cache -t openclone-sadtalker:1.0 .`
Run using script: `/StartStopScripts/SadTalker/start.bat`

**Windows Development:**
1. Install VS Code Theme [Shades of Purple](https://vscodethemes.com/e/ahmadawais.shades-of-purple/shades-of-purple)
2. [Install Python 3.8.8](https://www.python.org/downloads/release/python-388/)
3. [Install CUDA Toolkit 11.8](https://developer.nvidia.com/cuda-11-8-0-download-archive?target_os=Windows&target_arch=x86_64&target_version=11&target_type=exe_local)
4. `git clone https://github.com/smchughinfo/SadTalker.git`
5. `cd SadTalker`
6. `code .`
7. `ctrl+shift+p > Python: Create Environment > Venv > Python 3.8.8rc 64-bit`
8. `pip install torch==2.1.0 torchvision==0.16.0 torchaudio==2.1.0 --index-url https://download.pytorch.org/whl/cu118`
9. `pip install -r SadTalker/requirements.txt`

**Note:** torchvision==0.17.0+ removes functions required by SadTalker. GeForce drivers must support CUDA 11.8.

## How to run it

Set required environment variables (see root README.md for complete list). The service runs as a Flask API on port 5001. Send POST requests to `/generate-deepfake` with parameters for image path, audio path, and output format (mp4Path or m3u8Path). Use `cpu=1` parameter to force CPU processing instead of GPU.

For more technical details and API documentation, see [CLAUDE.md](CLAUDE.md).