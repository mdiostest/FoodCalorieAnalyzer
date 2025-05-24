import UIKit

class ImageCompressor {
    static func compressImage(_ image: UIImage, maxSize: CGFloat = 1024, quality: CGFloat = 0.7) -> Data? {
        // Calculate new size
        let originalSize = image.size
        var newSize = originalSize
        
        if originalSize.width > maxSize || originalSize.height > maxSize {
            if originalSize.width > originalSize.height {
                newSize = CGSize(width: maxSize, height: maxSize * originalSize.height / originalSize.width)
            } else {
                newSize = CGSize(width: maxSize * originalSize.width / originalSize.height, height: maxSize)
            }
        }
        
        // Resize image
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Compress image
        return resizedImage?.jpegData(compressionQuality: quality)
    }
    
    static func compressImageForAPI(_ image: UIImage) -> Data? {
        return compressImage(image, maxSize: Config.maxImageSize, quality: Config.imageCompressionQuality)
    }
} 