# Session Memory - June 18, 2025

## Key Technical Solutions Implemented

### 1. Fixed SadTalker Requirements.txt Encoding Issue
**Problem**: SadTalker requirements.txt had UTF-16 encoding with null bytes between characters, causing pip install errors
**Root Cause**: File was saved with wrong encoding, showing pattern like `a\x00b\x00s\x00l\x00-\x00p\x00y`
**Solution**: Rewrote the file at `/mnt/c/Users/seanm/Desktop/OpenClone/SadTalker/SadTalker/requirements.txt` with proper UTF-8 encoding
**Key Learning**: UTF-16 encoding issues commonly occur when copying files between Windows/Linux systems

### 2. Resolved U-2-Net GPU Detection Problems (Local Development)
**Problem**: U-2-Net was falling back to CPU processing instead of using available GPUs
**Investigation**: Found two separate issues:
   - **Environment Variable**: `OpenClone_CUDA_VISIBLE_DEVICES` was not set, causing `CUDA_VISIBLE_DEVICES` to be set to `None`
   - **PyTorch Installation**: Had CPU-only version (`torch==2.3.1+cpu`) instead of CUDA-enabled version

**Solutions Applied**:
   1. **Immediate Fix**: Hard-coded `os.environ["CUDA_VISIBLE_DEVICES"] = "0,1"` in `/mnt/c/Users/seanm/Desktop/OpenClone/U-2-Net/GlobalVariables.py`
   2. **PyTorch CUDA Installation**: Installed proper CUDA-enabled PyTorch using:
      ```bash
      pip install torch==2.3.1 torchvision==0.18.1 torchaudio==2.3.1 --index-url https://download.pytorch.org/whl/cu118
      pip install -r U-2-Net/requirements.txt
      ```

### 3. Infrastructure Environment Variable Discovery
**Critical Finding**: In IAC Terraform configuration `/mnt/c/Users/seanm/Desktop/OpenClone/IAC/terraform/u-2-net.tf` line 54:
- `OpenClone_CUDA_VISIBLE_DEVICES` was set to empty string (`value = ""`)
- This would cause containerized deployments to fall back to CPU processing
- **Action Required**: Change to `value = "0,1"` for GPU acceleration in deployed containers

### 4. Updated U-2-Net Dockerfile for CUDA Support
**Enhancement**: User updated U-2-Net Dockerfile to install PyTorch with CUDA support first:
```dockerfile
RUN pip install torch==2.3.1 torchvision==0.18.1 torchaudio==2.3.1 --index-url https://download.pytorch.org/whl/cu118
RUN pip install -r ./U-2-Net/requirements.txt
```
**Pattern**: Mirrors the successful local development approach - install CUDA PyTorch first, then remaining requirements

### 5. Enhanced SadTalker Documentation
**Addition**: Updated SadTalker README.md with critical checkpoint download step:
- Added step 11 requiring users to download AI model checkpoints
- Provided both original Google Drive link and backup mirror
- Specified exact directory structure: `SadTalker/checkpoints/`
- **Links Provided**:
  - Official: https://drive.google.com/file/d/1gwWh45pF7aelNP_P78uDJL8Sycep-K7j/view
  - Mirror: https://drive.google.com/file/d/1DyeiBYmVTiwXQIzCIGqFA8Kc86iL6d1I/view?usp=sharing

## Technical Insights & Patterns

### Environment Variable Strategies
**For GPU Flexibility**: Setting `CUDA_VISIBLE_DEVICES` to empty string (`""`) allows:
- GPU usage when available
- Automatic CPU fallback when GPUs not detected
- More flexible than hard-coding specific GPU indices

**Current Setup**: `"0,1"` restricts to specific GPUs but ensures consistent behavior

### PyTorch Installation Best Practices
**Key Learning**: Always install PyTorch with CUDA support BEFORE other requirements
**Pattern Applied Successfully**:
1. Install CUDA-enabled PyTorch with index URL
2. Install remaining requirements (will skip PyTorch since already satisfied)
3. Verify with `torch.cuda.is_available()` and `torch.version.cuda`

### Container Build Progress
**SadTalker Container**: Successfully initiated build with corrected requirements.txt
- Build was transferring large context (400+ MB) due to model files
- Expected completion after context transfer

## Files Modified
1. `/mnt/c/Users/seanm/Desktop/OpenClone/SadTalker/SadTalker/requirements.txt` - Fixed encoding
2. `/mnt/c/Users/seanm/Desktop/OpenClone/U-2-Net/GlobalVariables.py` - Hard-coded CUDA_VISIBLE_DEVICES
3. `/mnt/c/Users/seanm/Desktop/OpenClone/SadTalker/README.md` - Added checkpoint download instructions
4. `/mnt/c/Users/seanm/Desktop/OpenClone/U-2-Net/Dockerfile` - Added CUDA PyTorch installation (user-modified)

## Outstanding Items for Future Sessions
1. **IAC Terraform Fix**: Update `OpenClone_CUDA_VISIBLE_DEVICES` from `""` to `"0,1"` in u-2-net.tf
2. **SadTalker IAC Review**: Check if SadTalker Terraform has similar environment variable issues
3. **Container Testing**: Verify rebuilt containers properly detect and use GPU acceleration
4. **Environment Variable Strategy**: Consider implementing flexible GPU detection across all services

## Development Environment Context
- **Platform**: Windows with WSL2 for Linux compatibility
- **GPU Setup**: NVIDIA GPUs with CUDA 11.8 support
- **Development Pattern**: Local Python environments with VS Code, containerized deployment via Docker
- **File System**: Shared OpenCloneFS for cross-container file access