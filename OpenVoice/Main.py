import os
import sys
import torch

# GPU Configuration (following SadTalker pattern)
cuda_visible_devices = os.getenv("OpenClone_CUDA_VISIBLE_DEVICES", "0")
os.environ["CUDA_VISIBLE_DEVICES"] = cuda_visible_devices
print(f"CUDA_VISIBLE_DEVICES set to: {cuda_visible_devices}")

# Add OpenVoice source to Python path
openvoice_path = os.path.join(os.path.dirname(__file__), 'OpenVoice')
if openvoice_path not in sys.path:
    sys.path.append(openvoice_path)

from openvoice import se_extractor
from openvoice.api import BaseSpeakerTTS, ToneColorConverter

def openvoice_tts(text, reference_audio_path, output_path, language='English', speaker='default', speed=1.0):
    """
    Generate speech using OpenVoice with voice cloning
    
    Args:
        text (str): Text to convert to speech
        reference_audio_path (str): Path to reference audio for voice cloning
        output_path (str): Where to save the generated audio
        language (str): Language for TTS ('English', 'Chinese', etc.)
        speaker (str): Speaker style ('default', 'whispering', 'cheerful', etc.)
        speed (float): Speech speed (1.0 = normal)
    """
    
    # Setup paths and device
    ckpt_base = 'OpenVoice/checkpoints/base_speakers/EN'
    ckpt_converter = 'OpenVoice/checkpoints/converter'
    
    # GPU Detection and Setup
    if torch.cuda.is_available():
        device = "cuda:0"
        gpu_name = torch.cuda.get_device_name(0)
        print(f"🚀 Using GPU: {gpu_name}")
        print(f"GPU Memory: {torch.cuda.get_device_properties(0).total_memory / 1024**3:.1f} GB")
    else:
        device = "cpu"
        print("⚠️  Using CPU (GPU not available)")
    
    print(f"Using device: {device}")
    print(f"Processing text: {text[:50]}...")
    
    # Initialize models
    print("Loading base speaker TTS model...")
    base_speaker_tts = BaseSpeakerTTS(f'{ckpt_base}/config.json', device=device)
    base_speaker_tts.load_ckpt(f'{ckpt_base}/checkpoint.pth')
    
    print("Loading tone color converter...")
    tone_color_converter = ToneColorConverter(f'{ckpt_converter}/config.json', device=device)
    tone_color_converter.load_ckpt(f'{ckpt_converter}/checkpoint.pth')
    
    # Get voice embeddings
    print("Loading source voice embedding...")
    source_se = torch.load(f'{ckpt_base}/en_default_se.pth').to(device)
    
    print(f"Extracting target voice from: {reference_audio_path}")
    target_se, audio_name = se_extractor.get_se(reference_audio_path, tone_color_converter, target_dir='processed', vad=True)
    
    # Generate speech
    print("Generating base speech...")
    tmp_path = 'tmp.wav'
    base_speaker_tts.tts(text, tmp_path, speaker=speaker, language=language, speed=speed)
    
    # Apply voice conversion
    print("Applying voice conversion...")
    tone_color_converter.convert(
        audio_src_path=tmp_path,
        src_se=source_se,
        tgt_se=target_se,
        output_path=output_path,
        message="@MyShell"
    )
    
    # Cleanup
    if os.path.exists(tmp_path):
        os.remove(tmp_path)
    
    print(f"✅ Generated audio saved to: {output_path}")
    return output_path

def test_openvoice():
    """
    Test function to verify OpenVoice is working
    """
    print("🔊 Testing OpenVoice...")
    
    # Check if checkpoints exist
    if not os.path.exists('OpenVoice/checkpoints'):
        print("❌ Checkpoints directory not found!")
        print("Please download and extract checkpoints from:")
        print("https://myshell-public-repo-host.s3.amazonaws.com/openvoice/checkpoints_1226.zip")
        return False
    
    # Use example reference audio
    reference_audio = 'OpenVoice/resources/example_reference.mp3'
    if not os.path.exists(reference_audio):
        print(f"❌ Reference audio not found: {reference_audio}")
        return False
    
    # Test generation
    test_text = "Hello! This is a test of OpenVoice text-to-speech."
    output_path = 'test_output.wav'
    
    try:
        openvoice_tts(test_text, reference_audio, output_path)
        print("✅ OpenVoice test completed successfully!")
        return True
    except Exception as e:
        print(f"❌ OpenVoice test failed: {e}")
        return False

if __name__ == "__main__":
    # Run test
    test_openvoice()