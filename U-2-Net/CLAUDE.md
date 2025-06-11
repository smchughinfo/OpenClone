# U-2-Net - Background Removal Service

## Overview
U-2-Net is the background removal service in OpenClone, based on the open-source U-2-Net project from https://github.com/xuebinqin/U-2-Net. It processes clone photos to remove backgrounds, enabling custom deepfake backgrounds.

**Workflow Integration**:
1. User uploads clone photo with background
2. Website calls U-2-Net API for background removal
3. U-2-Net returns clean portrait with transparent background

## Technical Architecture

### OpenClone Integration Layer
**Wrapper Structure**: Lightweight Flask API around stock U-2-Net

**Key Components**:
- `API.py`: Flask REST service wrapper
- `GlobalVariables.py`: Environment setup and LogWeaver integration
- `Image_PostProcesser.py`: Custom post-processing for mask application
- `u2net_human_seg.py`: Core U-2-Net model interface

## REST API Service

### Flask Web Service
**Endpoint**: `POST /remove-background`
**Port**: 5002

### API Example
```json
POST http://127.0.0.1:5002/remove-background
{
  "sourceImagePath": "/Clones/4/clone-image-with-bg.png",
  "outputImagePath": "/Clones/2/clone-image-no-bg.png",
  "threshold": 254
}
```

**Parameter Details**:
- **sourceImagePath**: Input image with background (relative to OpenCloneFS)
- **outputImagePath**: Output path for background-removed image (relative to OpenCloneFS)
- **threshold**: Mask sensitivity (0-255, higher = more aggressive removal)

## Processing Pipeline

### Stage 1: AI Model Processing
```python
from u2net_human_seg import process_image
process_image(sourceImagePath, outputImagePath)
```
- **Input**: Original image with background
- **Processing**: U-2-Net neural network generates grayscale mask
- **Output**: Mask image (white = keep, black = remove)

### Stage 2: Custom Post-Processing
```python
Image_PostProcesser.apply_portrait_mask(sourceImagePath, outputImagePath, threshold)
```
- **Input**: Original image + generated mask
- **Processing**: Pixel-by-pixel threshold application
- **Logic**: If mask pixel < threshold → transparent, else → keep original
- **Output**: RGBA image with transparent background

**Threshold Behavior**:
- **Low values (e.g., 100)**: Conservative removal, keeps more detail
- **High values (e.g., 254)**: Aggressive removal, removes more background
- **Default**: 254 for clean background elimination

## Model Quality Considerations

### Current Limitations
**Distributed Model Issues**:
- **Subpar Quality**: Pretrained model produces inferior results compared to commercial solutions
- **Edge Artifacts**: Rough edges and color bleeding around subject boundaries
- **Inconsistent Results**: Works adequately sometimes but not consistently enough for production

**Comparison Benchmark**: 
- **Commercial Standard**: https://silueta.me/ produces significantly better results
- **Quality Gap**: Current model appears partially trained rather than production-ready

### Root Cause Analysis
**Suspected Issues**:
- **Incomplete Training**: Distributed model may be partially trained checkpoint
- **Wrong model**: A better model may be out there if you dig through the documentation.

**Need Better Model**:
- U-2-Net repository provides complete training framework. Could keep training existing model.
- Could just beg someone for a better model. Annoying that backgrounds aren't always perfectly removed but would likely be fixed by just dropping in a better trained model file, Which isn't high on the list. Getting the whole infrastructure in place has been higher priority.

## Environment Integration

### Required Host Environment Variables
The following environment variables must be set on the host system for the U-2-Net component:

### Container Deployment
**Docker Integration**:
- Containerized service running on port 5002
- GPU passthrough for model acceleration
- Volume mounts for OpenCloneFS access
- Environment variable injection

## File Structure
```
U-2-Net/
├── API.py                      # Flask REST API wrapper
├── GlobalVariables.py          # Environment setup and logging
├── Image_PostProcesser.py      # Custom mask post-processing
├── Dockerfile                 # Container configuration
├── requirements.txt           # Python dependencies (includes LogWeaver)
├── U-2-Net/                   # Core U-2-Net project
│   ├── u2net_human_seg.py    # Human segmentation interface
│   ├── model/                # Neural network architecture
│   ├── saved_models/         # Model weights and checkpoints
│   ├── test_data/           # Example images and results
│   └── u2net_train.py       # Training scripts
└── README.md                 # Setup and usage instructions
```

## Use Cases & Integration

### Website Integration
1. User uploads clone photo with background
2. Website calls U-2-Net API with source image path
3. U-2-Net processes image and saves background-removed version