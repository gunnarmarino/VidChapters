#!/bin/bash

# Default directory containing video files to be transcribed
DEFAULT_VIDEO_DIR="/workspace/VidChapters/tiktok-vids"

# Prompt the user for the video directory
read -p "Enter the video directory path or press enter to use the default [$DEFAULT_VIDEO_DIR]: " VIDEO_DIR
VIDEO_DIR="${VIDEO_DIR:-$DEFAULT_VIDEO_DIR}"

# Set the ASR output directory as a subdirectory of the video directory
OUTPUT_ASR_DIR="${VIDEO_DIR}/asr"

# Create the ASR directory if it doesn't exist
mkdir -p "$OUTPUT_ASR_DIR"

# Activate conda environment
source activateconda
conda activate whisperx

python /workspace/VidChapters/demo_asr.py --video_dir=$VIDEO_DIR --combine_datasets chapters

conda deactivate
