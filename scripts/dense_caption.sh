#!/bin/bash

# Default directory containing video files to be captioned
DEFAULT_VIDEO_DIR="/workspace/VidChapters/tiktok-vids"

# Prompt the user for the video directory
read -p "Enter the video directory path or press enter to use the default [$DEFAULT_VIDEO_DIR]: " VIDEO_DIR
VIDEO_DIR="${VIDEO_DIR:-$DEFAULT_VIDEO_DIR}"

# Set the ASR directory as a subdirectory of the video directory
ASR_DIR="${VIDEO_DIR}/asr"

# Path to the checkpoint directory
CHECKPOINT_DIR="/workspace/VidChapters/vid2seq_checkpoints"

# List all available checkpoints in the directory
echo "Available checkpoints:"
ls "$CHECKPOINT_DIR" | nl

# Prompt the user to enter comma-separated checkpoint numbers
read -p "Enter the comma-separated numbers of the checkpoints you want to use: " CHECKPOINT_NUMBERS

# Activate conda environment
source activateconda
conda activate vidchapters

# Loop through the selected checkpoint numbers
IFS=',' read -ra SELECTED_CHECKPOINT_NUMBERS <<< "$CHECKPOINT_NUMBERS"
for CHECKPOINT_NUMBER in "${SELECTED_CHECKPOINT_NUMBERS[@]}"; do
    # Get the selected checkpoint name
    SELECTED_CHECKPOINT=$(ls "$CHECKPOINT_DIR" | sed -n "${CHECKPOINT_NUMBER}p")

    echo "Running with checkpoint ${SELECTED_CHECKPOINT}"
    
    # Set the full path to the selected checkpoint
    CHECKPOINT_PATH="${CHECKPOINT_DIR}/${SELECTED_CHECKPOINT}"

    # Remove the file extension from the selected checkpoint to use as the output folder name
    OUTPUT_FOLDER_NAME="${VIDEO_DIR}/${SELECTED_CHECKPOINT%.*}"

    # Create the output directory if it doesn't exist
    mkdir -p "$OUTPUT_FOLDER_NAME"

    # Run the demo script
    python /workspace/VidChapters/demo_vid2seq.py \
        --load="${CHECKPOINT_PATH}" \
        --video_dir=$VIDEO_DIR \
        --asr_dir=$ASR_DIR \
        --output_dir=$OUTPUT_FOLDER_NAME \
        --combine_datasets chapters | tee /dev/tty > "${OUTPUT_FOLDER_NAME}/output.txt"
done

conda deactivate