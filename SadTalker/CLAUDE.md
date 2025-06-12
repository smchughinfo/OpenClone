# SadTalker - Deepfake Video Generator

## Overview
SadTalker is the core deepfake video generation service in OpenClone, based on the open-source SadTalker project from https://github.com/OpenTalker/SadTalker. It generates talking head videos by combining a static image with audio input, eliminating the need for complex model training or face grafting onto 3D models.

## Historical Context & Evolution
**Original Vision (March 2023):**
- Game engine rendering (Unity → Blender → Omniverse Audio2Face)
- First-order-model for face mapping
- Coqui TTS for audio generation
- Complex pipeline: [Coqui](https://github.com/coqui-ai/TTS) → [Audio2Face](https://docs.omniverse.nvidia.com/audio2face/latest/overview.html) → [First-order-model](https://github.com/AliaksandrSiarohin/first-order-model)

**Problems with Original Approach:**
- Coqui TTS provided poor results ("more of a TTS test platform than a solution")
- Months of development for subpar deepfake quality
- Overly complex multi-stage pipeline

**Discovery of SadTalker:**
- Found through tracing breadcrumbs from HeyGen (commercial deepfake service)
- SadTalker performs similarly to HeyGen but is open source
- Simplified workflow: Still image + Audio → Talking head video
- No model training or face grafting required


## Technical Architecture

### Core Functionality
SadTalker takes two inputs and produces talking head videos:
1. **Static Image**: The clone's photograph
2. **Audio Input**: Generated speech (currently from ElevenLabs)
3. **Output**: Deepfake video of the clone speaking

### OpenClone Integration Layer
**Wrapper Structure**: Light wrapper around stock SadTalker with OpenClone-specific enhancements

**Comprehensive `inference.py` Modifications:**
The entire `inference.py` file has been extensively modified with OpenClone-specific code intermingled throughout, while preserving the core SadTalker logic.

**Key OpenClone Entry Point:**
```python
def generate_deepfake(image_path, audio_path, m3u8_path=None, mp4_path=None, 
                     remove_audio_fom_mp4=False, cpu=0, tsSegmentLength=5):
    # High-level interface serving as OpenClone's entry point into SadTalker
    # Provides easy image/audio switching for different clones
    # M3U8 streaming support for real-time playback
    # MP4 output for final video files
    # Hardware selection (GPU/CPU) control
```

**Major Architectural Changes:**
- **Animation Parameter Caching**: Extensive caching system for clone-specific 3DMM data
- **Dual Output Support**: Parallel M3U8 streaming and MP4 generation
- **LogWeaver Integration**: Comprehensive logging throughout the generation process
- **OpenCloneFS Integration**: All file operations routed through shared file system
- **Error Recovery**: Robust handling of stuck processes and cache conflicts

**Enhanced Features:**
- **Flexible Input Handling**: Easy switching between different clone images
- **Dual Output Formats**: MP4 for storage, M3U8 for streaming
- **CPU/GPU Selection**: Runtime hardware selection
- **Audio Removal**: Option to generate silent videos
- **Configurable Streaming**: Adjustable segment lengths for HLS streaming

## Real-Time Streaming Innovation

### M3U8 HLS Streaming (`m3u8_streamer.py`)
**Purpose**: Reduce perceived latency between user message and video response

**Implementation**:
- Uses FFmpeg to generate HLS (HTTP Live Streaming) segments
- Streams video frames as they're generated rather than waiting for completion
- Configurable segment duration (default: 5 seconds)
- Real-time frame-by-frame streaming to FFmpeg stdin

**Technical Details**:
```python
class m3u8Streamer:
    def __init__(self, audioFilePath, m3u8Path, tsSegmentLength):
        # Sets up FFmpeg process for HLS streaming
        # Combines generated frames with audio in real-time
        # Produces .m3u8 playlist + .ts segment files
```

**Benefits**:
- User sees video start playing while generation continues
- Improved perceived performance
- Better user experience for longer videos

## REST API Service (`API.py`)

### Flask Web Service
**Endpoint**: `POST /generate-deepfake`

### API Examples

**Example 1: MP4 Generation (CPU Mode)**
```json
POST http://127.0.0.1:5001/generate-deepfake
{
  "imagePath": "/Clones/2/clone-image-no-bg.png",
  "audioPath": "/quick-fake-audio.wav",
  "mp4Path": "/Clones/2/quick-fake.mp4",
  "removeAudioFromMp4": true,
  "cpu": 1
}
```

**Example 2: M3U8 Streaming Generation (GPU Mode)**
```json
POST http://127.0.0.1:5001/generate-deepfake
{
  "imagePath": "/Clones/2/clone-image-no-bg.png",
  "audioPath": "/quick-fake-audio.wav",
  "m3u8Path": "/Clones/2/Deepfake/Stream/stream.m3u8",
  "tsSegmentLength": 2
}
```

**Parameter Details**:
- **Hardware Selection**: 
  - Default: GPU processing (cpu=0 or omitted)
  - CPU Override: Set cpu=1 for CPU processing
- **Output Formats**:
  - mp4Path: Final video file for storage
  - m3u8Path: HLS streaming playlist for real-time playback
- **Streaming Optimization**:
  - tsSegmentLength: Controls HLS segment duration (seconds)
  - Shorter segments = lower latency, more segments
  - Future: Dynamic adjustment based on browser capabilities and network conditions

**Path Resolution**:
- All paths resolved relative to OpenCloneFS
- Automatic leading slash handling
- Centralized file system access

**Error Handling**:
- Comprehensive exception logging via LogWeaver
- Stack trace capture logged for debugging
- HTTP 500 responses with error details

## SadTalker Core Modifications

### Modified Components
**Files with OpenClone customizations**:
- `inference.py`: Main entry point with enhanced parameters
- `predict.py`: Modified for M3U8 streaming integration  
- `m3u8_streamer.py`: Custom HLS streaming implementation
- `audio_remover.py`: Utility for creating silent videos

**Original SadTalker Integration**:
- Preserved core AI model functionality
- Enhanced with OpenClone-specific features
- Maintained compatibility with base SadTalker capabilities

### Caching & Performance
**Animation Parameters Cache**:
- Stores preprocessed 3DMM data for clone images
- Reduces processing time for repeat generations
- Maintains consistency across sessions

## Environment Integration

### Required Host Environment Variables
The following environment variables must be set on the host system for the SadTalker component:

**File System:**
- `OpenClone_OpenCloneFS` - OpenCloneFS directory path for input/output files

**Database Configuration (for LogWeaver):**
- `OpenClone_DB_Host` - Database host address for logging
- `OpenClone_DB_Port` - Database port for logging
- `OpenClone_LogDB_Name` - Logging database name
- `OpenClone_LogDB_User` - Logging database username
- `OpenClone_LogDB_Password` - Logging database password

**GPU Configuration:**
- `OpenClone_CUDA_VISIBLE_DEVICES` - CUDA visible devices for GPU operations

### LogWeaver Integration (`GlobalVariables.py`)
**Logging Setup**:
- **applicationLog**: Main SadTalker application events (logger name: "SadTalker")
- **ffmpegLog**: FFmpeg streaming process monitoring (logger name: "ST_FFMPEG")
- **Run Number Tracking**: Session-based log organization
- **API Port**: Fixed at 5001 for service communication

**Note on ST_FFMPEG Logs**: The "ST_FFMPEG" logs visible in LogViewer come from SadTalker's FFmpeg integration points (particularly in `m3u8_streamer.py`). These logs use the `ffmpegLog` instance defined in `GlobalVariables.py` to monitor FFmpeg process output during HLS streaming generation.

### Container Deployment
**Docker Integration**:
- Containerized service running on port 5001
- GPU passthrough for CUDA acceleration
- Volume mounts for OpenCloneFS access
- Environment variable injection

## Use Cases & Integration

### Website Integration
1. User sends message to clone
2. Website generates speech via ElevenLabs
3. Website calls SadTalker API with clone image + audio
4. SadTalker returns M3U8 stream or MP4 de[ending on what the website asked for

## File Structure
```
SadTalker/
├── API.py                    # Flask REST API wrapper
├── GlobalVariables.py        # Environment setup and logging
├── Dockerfile               # Container configuration  
├── requirements.txt         # Python dependencies (includes LogWeaver)
├── SadTalker/              # Core SadTalker project
│   ├── inference.py        # Modified main interface  
│   ├── predict.py          # Modified for streaming
│   ├── m3u8_streamer.py   # Custom HLS streaming
│   ├── audio_remover.py   # Audio manipulation utility
│   ├── src/               # Original SadTalker source
│   ├── checkpoints/       # AI model weights
│   ├── examples/          # Sample input files
│   └── results/           # Generated output videos
└── README.md              # Setup and usage instructions
```

## Licensing Considerations

### Commercial Use Concerns
**SadTalker License**: Apache License (open source)

**Potential Restriction**: SadTalker references the One-Shot Free-View Neural Talking Head Synthesis project (https://github.com/zhanglonghao1992/One-Shot_Free-View_Neural_Talking_Head_Synthesis), which uses **Creative Commons Attribution-NonCommercial 4.0 International License**.

**Key Licensing Issues**:
- **NonCommercial Restriction**: The referenced project explicitly prohibits commercial use
- **Unclear Impact**: Whether this dependency invalidates commercial use of SadTalker itself
- **Legal Ambiguity**: Apache vs NonCommercial license conflict requires legal review

**Mitigation Strategy**:
- **Placeholder Status**: SadTalker serves as infrastructure placeholder during OpenClone development
- **Future Replacement**: Expected to be swapped out with commercially-clear alternatives anyways
- **Age Factor**: Referenced repositories are already semi-obsolete
- **Time Permitting**: Will be replaced when better solutions emerge or time allows

**Recommendation**: For commercial deployments, conduct legal review of licensing dependencies or plan for alternative deepfake generation solutions.

## Future Enhancements
- **OpenVoice Integration**: Replace ElevenLabs dependency
- **Self-hosted LLM**: Replace OpenAI dependency  
- **Commercial License Alternative**: Replace SadTalker with commercially-clear deepfake solution
- **Performance Optimization**: Faster generation times
- **Quality Improvements**: Enhanced video output quality
- **Batch Processing**: Multiple clone generation support