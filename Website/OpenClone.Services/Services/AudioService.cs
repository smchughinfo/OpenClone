using NAudio.Wave;
using System;
using System.Diagnostics;
using System.IO;
using System.Threading.Tasks;
using Xabe.FFmpeg;

namespace OpenClone.Services.Services
{
    public class AudioService
    {
        public AudioService()
        {
        }

        public async Task<Stream> ConvertToWav(string inputFilePath)
        {
            // Generate a temporary output file path
            string tempOutputFilePath = Path.GetTempFileName().Replace(".tmp", ".wav");

            try
            {
                // Convert the file to WAV using Xabe.FFmpeg
                var conversion = await FFmpeg.Conversions.FromSnippet.Convert(inputFilePath, tempOutputFilePath);
                await conversion.Start();

                // Check if the output file exists after conversion
                if (!File.Exists(tempOutputFilePath))
                {
                    throw new FileNotFoundException("The output WAV file was not created.");
                }
            }
            catch (Exception ex)
            {
                throw new Exception("An error occurred while converting the audio file to WAV format using Xabe.FFmpeg.", ex);
            }

            // Create a FileStream to read the file and delete the file afterward
            FileStream outputStream = new FileStream(tempOutputFilePath, FileMode.Open, FileAccess.Read, FileShare.None, 4096, FileOptions.DeleteOnClose);

            return outputStream;
        }

        public async Task ConvertMp3ToWav(byte[] mp3Bytes, string outputWavFilePath)
        {
            if(File.Exists(outputWavFilePath))
            {
                File.Delete(outputWavFilePath);
            }

            string tempMp3File = Path.GetTempFileName() + ".mp3";

            // Save the byte array to a temporary MP3 file
            File.WriteAllBytes(tempMp3File, mp3Bytes);

            // Create the conversion
            var conversion = FFmpeg.Conversions.New()
                .AddParameter($"-i \"{tempMp3File}\" \"{outputWavFilePath}\"");

            // Run the conversion
            await conversion.Start();

            // Clean up the temporary MP3 file
            File.Delete(tempMp3File);
        }
    }
}
