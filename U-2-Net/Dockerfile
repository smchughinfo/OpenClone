# Use an official CUDA base image
FROM nvidia/cuda:11.2.2-cudnn8-devel-ubuntu20.04

# Set up environment variables
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

# Install basic dependencies with detailed logging and retries
RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils && \
    apt-get install -y python3.8 python3.8-dev python3-pip git wget && \
    if [ ! -e /usr/bin/python3 ]; then ln -s /usr/bin/python3.8 /usr/bin/python3; fi && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Upgrade pip
RUN python3 -m pip install --upgrade pip

# Set the working directory in the container to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Change to the u-2-net directory and install required Python packages
RUN pip install -r ./U-2-Net/requirements.txt

# Run app.py when the container launches
CMD ["python3", "API.py"]

# Expose any ports if needed (e.g., if running a web server or API)
EXPOSE 5002
