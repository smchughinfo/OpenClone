from PIL import Image

def apply_portrait_mask(original_image_path, output_path, threshold):
    portrait_mask_path = output_path

    # Open the original image and the portrait mask
    original_image = Image.open(original_image_path).convert("RGBA")
    portrait_mask = Image.open(portrait_mask_path).convert("RGB")

    # Get the dimensions of the images (assuming they are the same)
    width, height = original_image.size

    # Create a new image for the output
    output_image = Image.new("RGBA", (width, height))

    # Process each pixel
    for y in range(height):
        for x in range(width):
            # Get the pixel values from the original image and the mask
            original_pixel = original_image.getpixel((x, y))
            mask_pixel = portrait_mask.getpixel((x, y))

            # Check if the mask pixel is less than (200, 200, 200)
            if mask_pixel < (threshold, threshold, threshold):
                # Set the pixel in the output image to be fully transparent
                output_image.putpixel((x, y), (0, 0, 0, 0))
            else:
                # Otherwise, keep the original pixel
                output_image.putpixel((x, y), original_pixel)

    # Save the output image
    output_image.save(output_path)

# Example usage
# apply_portrait_mask("path/to/original_image.png", "path/to/portrait_mask.png", "path/to/output_image.png")
