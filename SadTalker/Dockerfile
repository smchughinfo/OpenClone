# Use a CUDA runtime image as a parent image
FROM nvidia/cuda:11.8.0-runtime-ubuntu22.04

# Set the working directory in the container to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install Python, pip, and git --- TODO: are libgl1 and libglib2 necessary
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    git \
    libgl1 \
    libglib2.0-0 \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install required Python packages from requirements.txt
RUN python3 -m pip install --upgrade pip \
    && python3 -m pip install torch==2.1.0+cu118 torchvision==0.16 torchaudio --index-url https://download.pytorch.org/whl/cu118 \
    && python3 -m pip install --no-cache-dir -r ./SadTalker/requirements-docker.txt

EXPOSE 5001

# Run API.py when the container launches
CMD ["python3", "API.py"]
