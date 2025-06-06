using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using OpenClone.Services.Services;
using OpenClone.UI.Configuration.Services;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Metadata.Profiles.Exif;
using SixLabors.ImageSharp.Processing;

namespace OpenClone.UI.Extensions
{
    public static class IFormFileExtensions
    {
        public static async Task<Image> ToPngImage(this IFormFile iFormFile)
        {
            using (var memoryStream = new MemoryStream())
            {
                // Copy the input file to the memory stream
                await iFormFile.CopyToAsync(memoryStream);
                memoryStream.Position = 0; // Reset stream position for reading

                // Load the image using ImageSharp
                using (var image = await Image.LoadAsync(memoryStream))
                {
                    // Check if the image has Exif data and correct orientation if necessary
                    if (image.Metadata.ExifProfile != null)
                    {
                        if (image.Metadata.ExifProfile.TryGetValue(SixLabors.ImageSharp.Metadata.Profiles.Exif.ExifTag.Orientation, out IExifValue<ushort> orientationValue))
                        {
                            RotateImage(image, (int)orientationValue.Value);
                            image.Metadata.ExifProfile = null;
                        }
                    }

                    // Save the image as PNG to a new memory stream
                    using (var pngMemoryStream = new MemoryStream())
                    {
                        await image.SaveAsPngAsync(pngMemoryStream); // Save as PNG
                        pngMemoryStream.Position = 0; // Reset position for reading

                        // Return the PNG image (you can further modify or return the stream if needed)
                        var pngImage = await Image.LoadAsync(pngMemoryStream);
                        return pngImage;
                    }
                }
            }
        }

        private static void RotateImage(Image image, int orientation)
        {
            switch (orientation)
            {
                case 3:
                    image.Mutate(x => x.Rotate(180)); // Rotate by 180 degrees
                    break;
                case 6:
                    image.Mutate(x => x.Rotate(90)); // Rotate by 90 degrees
                    break;
                case 8:
                    image.Mutate(x => x.Rotate(-90)); // Rotate by 270 degrees
                    break;
                default:
                    // Optionally log or handle other orientations
                    break;
            }
        }

        public static async Task<Stream> ToWav(this IFormFile iFormFile)
        {
            using (var scope = StaticServiceProvider.ServiceProvider.CreateScope())
            {
                var path = Path.Combine(Path.GetTempPath(), iFormFile.FileName);
                try
                {
                    using (var fileStream = new FileStream(path, FileMode.Create))
                    {
                        await iFormFile.CopyToAsync(fileStream);
                    }

                    var audioService = scope.ServiceProvider.GetService<AudioService>();
                    return await audioService.ConvertToWav(path);
                }
                finally
                {
                    if (File.Exists(path))
                    {
                        File.Delete(path);
                    }
                }
            }
        }
    }
}
