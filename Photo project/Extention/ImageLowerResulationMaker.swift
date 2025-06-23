
import UIKit

extension UIImage {
    func resized(to targetSize: CGSize) -> UIImage? {
        let widthRatio  = targetSize.width  / self.size.width
        let heightRatio = targetSize.height / self.size.height

        let newSize = CGSize(width: self.size.width * widthRatio, height: self.size.height * heightRatio)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        print("new size : \(newSize)")
        let resizedImage = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return resizedImage
    }
}

