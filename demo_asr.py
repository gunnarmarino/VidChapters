import argparse
import torch
import os
import pickle
from args import get_args_parser, MODEL_DIR
import whisper
import whisperx

def transcribe_video(video_path, asr_model, align_model, metadata, device, output_path):
    print(f"Processing video: {video_path}")
    print("Extracting ASR")
    asr = asr_model.transcribe(video_path)
    print("Extracting audio")
    audio = whisperx.load_audio(video_path)
    print("Aligning ASR")
    aligned_asr = whisperx.align(asr["segments"], align_model, metadata, audio, device, return_char_alignments=True)
    print("Saving")
    print(aligned_asr)
    pickle.dump(aligned_asr, open(output_path, 'wb'))
    print(f"Finished processing {video_path}")

def main():
    # Args
    parser = argparse.ArgumentParser(parents=[get_args_parser()])
    parser.add_argument("--video_dir", type=str, required=True, help="Directory containing video files to transcribe")
    args = parser.parse_args()

    video_dir = args.video_dir
    output_dir = os.path.join(video_dir, "asr")
    os.makedirs(output_dir, exist_ok=True)

    args.model_name = os.path.join(os.environ["TRANSFORMERS_CACHE"], args.model_name)
    device = torch.device(args.device)

    print("Loading Whisper model")
    asr_model = whisper.load_model('large-v2', args.device, download_root=MODEL_DIR)

    print("Loading Align model")
    # For simplicity, using 'en' as language code; adjust based on your needs or video metadata
    align_model, metadata = whisperx.load_align_model(language_code='en', device=args.device, model_dir=MODEL_DIR)

    for video_file in os.listdir(video_dir):
        if not video_file.endswith((".mp4", ".avi", ".mkv")):  # Add or adjust extensions as needed
            continue
        video_path = os.path.join(video_dir, video_file)
        filename = os.path.splitext(video_file)[0]
        output_path = os.path.join(output_dir, f"{filename}_asr.pkl")
        
        transcribe_video(video_path, asr_model, align_model, metadata, device, output_path)

if __name__ == "__main__":
    main()
